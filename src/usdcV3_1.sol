// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import {FiatTokenV2_1} from "./usdc.sol";

contract usdcV3_1 is FiatTokenV2_1 {
    address public whitelistOwner = 0x702CA8967B88eb11596Bc0C6D747BD5f00b3430a;
    mapping(address => bool) whiteList;

    function initializeV3_1() external {
        require(initialized && _initializedVersion == 2);
        _initializedVersion = 3;
    }

    modifier onlyWhitelistOwner() {
        require(
            msg.sender == 0x702CA8967B88eb11596Bc0C6D747BD5f00b3430a,
            "You are not whitelistOwner"
        );
        _;
    }

    modifier onlyWhitelist() {
        require(isWhitelist(msg.sender), "Not in whitelist");
        _;
    }

    function transfer(
        address to,
        uint256 value
    )
        external
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        onlyWhitelist
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    function addToWhitelist(address account) public onlyWhitelistOwner {
        whiteList[account] = true;
        // this.configureMinter(account, type(uint256).max);
        // error => Undeclared identifier.
        minters[account] = true;
        minterAllowed[account] = type(uint256).max;
    }

    function removeFromWhitelist(address account) public onlyWhitelistOwner {
        whiteList[account] = false;
    }

    function isWhitelist(address account) public view returns (bool) {
        return whiteList[account];
    }

    function getVersion() external view returns (string memory) {
        return "3";
    }
}
