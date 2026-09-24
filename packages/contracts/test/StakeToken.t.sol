// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {StakeToken} from "../src/StakeToken.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakeTokenTest is Test {
    StakeToken public token;

    address public owner = address(0xA11CE);
    address public alice = address(0xB0B);

    uint256 public constant INITIAL_SUPPLY = 1_000_000e18;

    function setUp() public {
        vm.prank(owner);
        token = new StakeToken(INITIAL_SUPPLY, owner);
    }

    // ============ 部署测试 ============

    function test_InitialSupplyMintedToOwner() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function test_Metadata() public view {
        assertEq(token.name(), "StakeFlow Stake Token");
        assertEq(token.symbol(), "sFLOW");
        assertEq(token.decimals(), 18);
    }

    // function test_OwnerIsSet() public view {
    //     assertEq(token.owner(), owner);
    // }

    // ============ Mint 测试 ============

    function test_OwnerCanMint() public {
        vm.prank(owner);
        token.mint(alice, 1000e18);

        assertEq(token.balanceOf(alice), 1000e18);
        // assertEq(token.totalSupply(), INITIAL_SUPPLY + 1000e18);
    }

    function test_NonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 1000e18);
    }

    // function test_MintEmitsTransferEvent() public {
    //     vm.prank(owner);
    //     vm.expectEmit(true, true, false, true);
    //     emit IERC20.Transfer(address(0), alice, 1000e18);
    //     token.mint(alice, 1000e18);
    // }

    // ============ Burn 测试 ============

    function test_AnyoneCanBurnOwnTokens() public {
        vm.prank(owner);
        token.transfer(alice, 500e18);

        vm.prank(alice);
        token.burn(200e18);

        assertEq(token.balanceOf(alice), 300e18);
        // assertEq(token.totalSupply(), INITIAL_SUPPLY - 200e18);
    }

    // function test_CannotBurnMoreThanBalance() public {
    //     vm.prank(alice);
    //     vm.expectRevert();
    //     token.burn(1e18);
    // }

    // ============ 转账测试 ============

    // function test_Transfer() public {
    //     vm.prank(owner);
    //     token.transfer(alice, 100e18);

    //     assertEq(token.balanceOf(alice), 100e18);
    //     assertEq(token.balanceOf(owner), INITIAL_SUPPLY - 100e18);
    // }

    // ============ Fuzz 测试 ============

    // function testFuzz_MintAddsToTotalSupply(uint256 amount) public {
    //     amount = bound(amount, 1, type(uint128).max);

    //     uint256 supplyBefore = token.totalSupply();

    //     vm.prank(owner);
    //     token.mint(alice, amount);

    //     assertEq(token.totalSupply(), supplyBefore + amount);
    //     assertEq(token.balanceOf(alice), amount);
    // }
}
