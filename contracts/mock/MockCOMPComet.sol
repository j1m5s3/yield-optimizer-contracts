// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "../interfaces/PoolInterfaces.sol";
import { IERC20 } from "../interfaces/SMAInterfaces.sol";
import "./MockcUSDC.sol";

contract MockCOMPComet is ICompoundPool {
    // Mapping to track user balances for each asset
    mapping(address => mapping(address => uint256)) public userBalances;
    
    // Mapping to track total supply for each asset
    mapping(address => uint256) public totalSupply;

    // Mapping to track cToken addresses for each asset
    mapping(address => address) public cTokens;

    constructor(address _usdcAddr, address _cUSDCAddr) {
        cTokens[_usdcAddr] = _cUSDCAddr; // USDC mainnet address
    }

    function supply(address asset, uint amount) external override {
        // Transfer tokens from the user to this contract
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        
        // Update balances
        userBalances[msg.sender][asset] += amount;
        totalSupply[asset] += amount;

        // Mint cTokens to the user
        address cToken = cTokens[asset];
        require(cToken != address(0), "Asset not supported");
        MockcUSDC(cToken).mint(msg.sender, amount);
    }

    function supplyTo(address dst, address asset, uint amount) external override {
        // Transfer tokens from the user to this contract
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        
        // Update balances for the destination address
        userBalances[dst][asset] += amount;
        totalSupply[asset] += amount;

        // Mint cTokens to the destination address
        address cToken = cTokens[asset];
        require(cToken != address(0), "Asset not supported");
        MockcUSDC(cToken).mint(dst, amount);
    }

    function withdraw(address asset, uint amount) external override {
        require(userBalances[msg.sender][asset] >= amount, "Insufficient balance");
        
        // Update balances
        userBalances[msg.sender][asset] -= amount;
        totalSupply[asset] -= amount;
        
        // Burn cTokens from the user
        address cToken = cTokens[asset];
        require(cToken != address(0), "Asset not supported");
        MockcUSDC(cToken).burn(msg.sender, amount);
        
        // Transfer tokens back to the user
        IERC20(asset).transfer(msg.sender, amount);
    }
}
