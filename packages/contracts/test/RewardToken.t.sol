// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {RewardToken} from "../src/RewardToken.sol";

contract RewardTokenTest is Test {
    RewardToken public token;

    address public owner = address(0xA11CE);
    address public alice = address(0xB0B);

    uint256 public constant INITIAL_SUPPLY = 10_000_000e18;

    function setUp() public {
        vm.prank(owner);
        token = new RewardToken(INITIAL_SUPPLY, owner);
    }

    function test_InitialSupplyMintedToOwner() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function test_Metadata() public view {
        assertEq(token.name(), "StakeFlow Reward Token");
        assertEq(token.symbol(), "rFLOW");
        assertEq(token.decimals(), 18);
    }

    function test_OwnerCanMint() public {
        vm.prank(owner);
        token.mint(alice, 1000e18);

        assertEq(token.balanceOf(alice), 1000e18);
    }

    function test_NonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 1000e18);
    }

    function test_AnyoneCanBurnOwnTokens() public {
        vm.prank(owner);
        token.transfer(alice, 500e18);

        vm.prank(alice);
        token.burn(200e18);

        assertEq(token.balanceOf(alice), 300e18);
    }
}
