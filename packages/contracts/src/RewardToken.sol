// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title RewardToken
/// @notice 奖励代币（StakeFlow 协议中用户质押后获得的奖励）
/// @dev 继承 OpenZeppelin ERC20，部署时铸造初始供应量给部署者
///      Staking 合约需要持有足够的 RewardToken 才能发放奖励
contract RewardToken is ERC20, Ownable {
    /// @notice 部署合约，铸造初始供应量给部署者
    /// @param initialSupply 初始供应量
    /// @param initialOwner 初始 owner
    constructor(
        uint256 initialSupply,
        address initialOwner
    ) ERC20("StakeFlow Reward Token", "rFLOW") Ownable(initialOwner) {
        _mint(initialOwner, initialSupply);
    }

    /// @notice 增发代币（仅 owner）
    /// @dev 用于补充奖励池
    /// @param to 接收地址
    /// @param amount 增发数量
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice 销毁代币
    /// @param amount 销毁数量
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
