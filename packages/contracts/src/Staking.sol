// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Staking
/// @notice StakeFlow 协议的核心质押合约
/// @dev 用户质押 StakeToken，按时间线性累积 RewardToken 奖励
///      采用 UUPS 代理模式支持升级，使用 ReentrancyGuardTransient 防重入
contract Staking is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    // ============ 状态变量 ============

    /// @notice 质押代币（用户存入的资产）
    IERC20 public stakeToken;

    /// @notice 奖励代币（发放给用户的奖励）
    IERC20 public rewardToken;

    /// @notice 每个用户的质押余额
    mapping(address => uint256) public stakedBalance;

    /// @notice 每个用户上次结算奖励的时间戳
    mapping(address => uint256) public lastUpdateTime;

    /// @notice 每个用户已累积但未领取的奖励
    mapping(address => uint256) public rewards;

    /// @notice 每秒奖励率（以 1e18 为精度）
    uint256 public rewardRate;

    /// @notice 全网总质押量
    uint256 public totalStaked;

    // ============ 事件 ============

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 oldRate, uint256 newRate);

    // ============ 错误 ============

    error ZeroAmount();
    error ZeroAddress();
    error InsufficientStake(uint256 requested, uint256 available);
    error InsufficientRewardPool(uint256 requested, uint256 available);

    // ============ 初始化 ============

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice 初始化合约
    /// @param _stakeToken 质押代币地址
    /// @param _rewardToken 奖励代币地址
    /// @param _rate 每秒奖励率（1e18 精度）
    /// @param initialOwner 初始 owner
    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _rate,
        address initialOwner
    ) public initializer {
        if (_stakeToken == address(0) || _rewardToken == address(0)) revert ZeroAddress();
        if (initialOwner == address(0)) revert ZeroAddress();

        __Ownable_init(initialOwner);

        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rate;
    }

    // ============ 用户操作 ============

    /// @notice 质押代币
    /// @param amount 质押数量
    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        _updateReward(msg.sender);

        // Effects
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        // 先 emit（在外部调用前）
        emit Staked(msg.sender, amount);

        // Interactions
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    /// @notice 提取质押
    /// @param amount 提取数量
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        uint256 userBalance = stakedBalance[msg.sender];
        if (amount > userBalance) revert InsufficientStake(amount, userBalance);

        _updateReward(msg.sender);

        // Effects
        stakedBalance[msg.sender] = userBalance - amount;
        totalStaked -= amount;

        // 先 emit
        emit Unstaked(msg.sender, amount);

        // Interactions
        stakeToken.safeTransfer(msg.sender, amount);
    }

    /// @notice 领取累积奖励
    function claimReward() external nonReentrant {
        _updateReward(msg.sender);

        uint256 reward = rewards[msg.sender];
        if (reward == 0) revert ZeroAmount();

        uint256 poolBalance = rewardToken.balanceOf(address(this));
        if (reward > poolBalance) revert InsufficientRewardPool(reward, poolBalance);

        // Effects
        rewards[msg.sender] = 0;

        // 先 emit
        emit RewardClaimed(msg.sender, reward);

        // Interactions
        rewardToken.safeTransfer(msg.sender, reward);
    }

    // ============ 视图函数 ============

    /// @notice 查询某用户当前可领取的奖励
    function earned(address account) public view returns (uint256) {
        uint256 staked = stakedBalance[account];
        if (staked == 0) return rewards[account];

        uint256 pending = (staked * (block.timestamp - lastUpdateTime[account]) * rewardRate) / 1e18;
        return rewards[account] + pending;
    }

    // ============ 内部函数 ============

    function _updateReward(address account) internal {
        uint256 staked = stakedBalance[account];
        if (staked > 0) {
            uint256 pending = (staked * (block.timestamp - lastUpdateTime[account]) * rewardRate) / 1e18;
            rewards[account] += pending;
        }
        lastUpdateTime[account] = block.timestamp;
    }

    // ============ 管理员函数 ============

    function setRewardRate(uint256 newRate) external onlyOwner {
        uint256 oldRate = rewardRate;
        rewardRate = newRate;
        /// forge-lint: disable-next-line(reentrancy-events)
        emit RewardRateUpdated(oldRate, newRate); // 这个 emit 没有外部调用在它前面
    }

    function emergencyWithdrawReward(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        rewardToken.safeTransfer(to, amount);
    }

    // ============ UUPS 升级授权 ============

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
