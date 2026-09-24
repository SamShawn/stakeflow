// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {Staking} from "../src/Staking.sol";
import {StakeToken} from "../src/StakeToken.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract StakingTest is Test {
    Staking public staking;
    StakeToken public stakeToken;
    RewardToken public rewardToken;

    address public owner = address(0xA11CE);
    address public alice = address(0xB0B);
    address public bob = address(0xCAFE);

    uint256 public constant INITIAL_STAKE_SUPPLY = 1_000_000e18;
    uint256 public constant INITIAL_REWARD_SUPPLY = 10_000_000e18;
    uint256 public constant REWARD_RATE = 1e15; // 每秒 0.001 代币

    function setUp() public {
        stakeToken = new StakeToken(INITIAL_STAKE_SUPPLY, owner);
        rewardToken = new RewardToken(INITIAL_REWARD_SUPPLY, owner);

        Staking impl = new Staking();
        bytes memory initData = abi.encodeCall(
            Staking.initialize,
            (address(stakeToken), address(rewardToken), REWARD_RATE, owner)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        staking = Staking(address(proxy));

        vm.prank(owner);
        rewardToken.transfer(address(staking), 5_000_000e18);

        vm.startPrank(owner);
        stakeToken.transfer(alice, 100_000e18);
        stakeToken.transfer(bob, 100_000e18);
        vm.stopPrank();

        vm.prank(alice);
        stakeToken.approve(address(staking), type(uint256).max);
        vm.prank(bob);
        stakeToken.approve(address(staking), type(uint256).max);
    }

    // ============ 初始化测试 ============

    function test_Initialize_SetsState() public view {
        assertEq(address(staking.stakeToken()), address(stakeToken));
        assertEq(address(staking.rewardToken()), address(rewardToken));
        assertEq(staking.rewardRate(), REWARD_RATE);
        assertEq(staking.owner(), owner);
    }

    function test_Initialize_CannotReinitialize() public {
        vm.expectRevert();
        staking.initialize(address(stakeToken), address(rewardToken), REWARD_RATE, owner);
    }

    // ============ stake 测试 ============

    function test_Stake_UpdatesState() public {
        vm.prank(alice);
        staking.stake(1000e18);

        assertEq(staking.stakedBalance(alice), 1000e18);
        assertEq(staking.totalStaked(), 1000e18);
        assertEq(stakeToken.balanceOf(address(staking)), 1000e18);
    }

    function test_Stake_EmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Staking.Staked(alice, 1000e18);
        vm.prank(alice);
        staking.stake(1000e18);
    }

    function test_Stake_RevertsOnZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert(Staking.ZeroAmount.selector);
        staking.stake(0);
    }

    // ============ withdraw 测试 ============

    function test_Withdraw_ReturnsTokens() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(alice);
        staking.withdraw(400e18);

        assertEq(staking.stakedBalance(alice), 600e18);
        assertEq(staking.totalStaked(), 600e18);
    }

    function test_Withdraw_RevertsOnInsufficientBalance() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Staking.InsufficientStake.selector, 2000e18, 1000e18));
        staking.withdraw(2000e18);
    }

    // ============ earned 测试 ============

    function test_Earned_IncreasesOverTime() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.warp(block.timestamp + 100);

        // 1000e18 * 100 * 1e15 / 1e18 = 100e18
        assertEq(staking.earned(alice), 100e18);
    }

    // ============ claimReward 测试 ============

    function test_ClaimReward_TransfersRewards() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.warp(block.timestamp + 100);

        uint256 balanceBefore = rewardToken.balanceOf(alice);
        vm.prank(alice);
        staking.claimReward();

        assertEq(rewardToken.balanceOf(alice) - balanceBefore, 100e18);
        assertEq(staking.rewards(alice), 0);
    }

    function test_ClaimReward_RevertsWhenNoReward() public {
        vm.prank(alice);
        vm.expectRevert(Staking.ZeroAmount.selector);
        staking.claimReward();
    }

    // ============ setRewardRate 测试 ============

    function test_SetRewardRate_ByOwner() public {
        vm.prank(owner);
        staking.setRewardRate(2e15);
        assertEq(staking.rewardRate(), 2e15);
    }

    function test_SetRewardRate_RevertsWhenNotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        staking.setRewardRate(2e15);
    }

    // ============ Fuzz 测试 ============

    function testFuzz_Stake(uint256 amount) public {
        amount = bound(amount, 1, 100_000e18);
        vm.prank(alice);
        staking.stake(amount);
        assertEq(staking.stakedBalance(alice), amount);
    }

    function testFuzz_EarnedLinearInTime(uint256 timeElapsed) public {
        timeElapsed = bound(timeElapsed, 1, 365 days);

        vm.prank(alice);
        staking.stake(1000e18);
        vm.warp(block.timestamp + timeElapsed);

        assertEq(staking.earned(alice), timeElapsed * 1e18);
    }
}
