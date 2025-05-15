// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "../interfaces/PoolInterfaces.sol";
import { IERC20 } from "../interfaces/SMAInterfaces.sol";
import "./MockaUSDC.sol";

contract MockAAVEPool is IAAVEPool {
    // Mapping to track user balances for each asset
    mapping(address => mapping(address => uint256)) public userBalances;
    
    // Mapping to track total supply for each asset
    mapping(address => uint256) public totalSupply;

    // Mapping to track aToken addresses for each asset
    mapping(address => address) public aTokens;

    constructor(address _usdcAddr, address _aUSDCAddr) {
        aTokens[_usdcAddr] = _aUSDCAddr; // USDC mainnet address
    }

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        // Transfer tokens from the user to this contract
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        
        // Update balances
        userBalances[onBehalfOf][asset] += amount;
        totalSupply[asset] += amount;

        // Mint aTokens to the user
        address aToken = aTokens[asset];
        require(aToken != address(0), "Asset not supported");
        MockaUSDC(aToken).mint(onBehalfOf, amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(userBalances[msg.sender][asset] >= amount, "Insufficient balance");
        
        // Update balances
        userBalances[msg.sender][asset] -= amount;
        totalSupply[asset] -= amount;
        
        // Burn aTokens from the user
        address aToken = aTokens[asset];
        require(aToken != address(0), "Asset not supported");
        MockaUSDC(aToken).burn(msg.sender, amount);
        
        // Transfer tokens to the specified address
        IERC20(asset).transfer(to, amount);
        
        return amount;
    }
}
