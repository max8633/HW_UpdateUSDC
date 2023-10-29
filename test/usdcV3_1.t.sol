pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import {FiatTokenV2_1} from "../src/usdc.sol";
import {usdcV3_1} from "../src/usdcV3_1.sol";

contract usdcV3_1_Test is Test {
    address public usdcProxy = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public usdcAdmin = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
    address public whitelistOwner = 0x702CA8967B88eb11596Bc0C6D747BD5f00b3430a;
    address public user1;
    address public user2;
    usdcV3_1 public usdcV3;
    usdcV3_1 public usdcV3Proxy;
    uint256 mainnetFork;

    function setUp() public {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        mainnetFork = vm.createFork(
            "https://eth-mainnet.g.alchemy.com/v2/7PoPTGfoenTmJeA7UOf8qn0ROoS30b-U"
        );
        vm.selectFork(mainnetFork);
        usdcV3 = new usdcV3_1();
    }

    function testUpgradeToV3() public {
        vm.startPrank(usdcAdmin);
        (bool success, ) = usdcProxy.call(
            abi.encodeWithSignature("upgradeTo(address)", address(usdcV3))
        );
        require(success, "Upgrade To V3 failed");
        vm.stopPrank();

        vm.startPrank(user1);
        usdcV3Proxy = usdcV3_1(usdcProxy);
        assertEq(usdcV3Proxy.getVersion(), "3");

        vm.stopPrank();
    }

    function testAddToWhiteList() public {
        vm.startPrank(usdcAdmin);
        (bool success, ) = usdcProxy.call(
            abi.encodeWithSignature("upgradeTo(address)", address(usdcV3))
        );
        require(success, "Upgrade To V3 failed");
        vm.stopPrank();

        vm.startPrank(whitelistOwner);
        usdcV3Proxy = usdcV3_1(usdcProxy);
        usdcV3Proxy.addToWhitelist(user1);
        assertEq(usdcV3Proxy.isWhitelist(user1), true);
        vm.stopPrank();
    }

    function testRemoveFromWhiteList() public {
        vm.startPrank(usdcAdmin);
        (bool success, ) = usdcProxy.call(
            abi.encodeWithSignature("upgradeTo(address)", address(usdcV3))
        );
        require(success, "Upgrade To V3 failed");
        vm.stopPrank();

        vm.startPrank(whitelistOwner);
        usdcV3Proxy = usdcV3_1(usdcProxy);
        usdcV3Proxy.addToWhitelist(user1);
        assertEq(usdcV3Proxy.isWhitelist(user1), true);
        usdcV3Proxy = usdcV3_1(usdcProxy);
        usdcV3Proxy.removeFromWhitelist(user1);
        assertEq(usdcV3Proxy.isWhitelist(user1), false);
        vm.stopPrank();
    }

    function testInWhitelistCanTransfer() public {
        vm.startPrank(usdcAdmin);
        (bool success, ) = usdcProxy.call(
            abi.encodeWithSignature("upgradeTo(address)", address(usdcV3))
        );
        require(success, "Upgrade To V3 failed");
        vm.stopPrank();

        vm.startPrank(whitelistOwner);
        usdcV3Proxy = usdcV3_1(usdcProxy);
        usdcV3Proxy.addToWhitelist(user1);
        assertEq(usdcV3Proxy.isWhitelist(user1), true);
        vm.stopPrank();

        vm.startPrank(user1);
        deal(usdcProxy, user1, 50e18);
        usdcV3Proxy.transfer(user2, 1e18);
        assertEq(usdcV3Proxy.balanceOf(user2), 1e18);
        vm.stopPrank();
    }

    function testNotInWhitelistCannotTransfer() public {
        vm.startPrank(usdcAdmin);
        (bool success, ) = usdcProxy.call(
            abi.encodeWithSignature("upgradeTo(address)", address(usdcV3))
        );
        require(success, "Upgrade To V3 failed");
        vm.stopPrank();

        vm.startPrank(whitelistOwner);
        usdcV3Proxy = usdcV3_1(usdcProxy);
        usdcV3Proxy.addToWhitelist(user1);
        assertEq(usdcV3Proxy.isWhitelist(user1), true);
        vm.stopPrank();

        vm.startPrank(user2);
        deal(usdcProxy, user2, 50e18);
        vm.expectRevert("Not in whitelist");
        usdcV3Proxy.transfer(user1, 1e18);

        vm.stopPrank();
    }

    function testInWhitelistMintWithoutLimit() public {
        vm.startPrank(usdcAdmin);
        (bool success, ) = usdcProxy.call(
            abi.encodeWithSignature("upgradeTo(address)", address(usdcV3))
        );
        require(success, "Upgrade To V3 failed");
        vm.stopPrank();

        vm.startPrank(whitelistOwner);
        usdcV3Proxy = usdcV3_1(usdcProxy);
        usdcV3Proxy.addToWhitelist(user1);
        assertEq(usdcV3Proxy.isWhitelist(user1), true);
        vm.stopPrank();

        vm.startPrank(user1);
        usdcV3Proxy.mint(user1, 100e18);
        assertEq(usdcV3Proxy.balanceOf(user1), 100e18);
        vm.stopPrank();
    }
}
