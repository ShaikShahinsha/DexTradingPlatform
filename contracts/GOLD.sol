// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract GOLD {
    
    uint256 private totalValue= 10000000000;
    constructor(string memory name, string memory symbol)ERC20(name,symbol){
        _mint(msg.sender, totalValue);
    }
}