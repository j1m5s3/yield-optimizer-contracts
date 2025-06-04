// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "../interfaces/PoolInterfaces.sol";
import { IERC20 } from "../interfaces/SMAInterfaces.sol";
import "./MockcUSDC.sol";

contract MockCOMPComet is ICompoundPool {
    // Mapping to track total supply for each asset
    mapping(address => uint256) public totalSupply;

    // Mapping to track cToken addresses for each asset
    mapping(address => address) public cTokens;

    constructor(address _usdcAddr, address _cUSDCAddr) {
        cTokens[_usdcAddr] = _cUSDCAddr; // USDC mainnet address
    }

    function supply(address asset, uint amount) external override {
        // Check if the asset is supported
        address cToken = cTokens[asset];
        require(cToken != address(0), "Asset not supported");

        // Transfer tokens from the user to this contract
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        
        // Update balances
        totalSupply[asset] += amount;

        // Mint cTokens to the user
        MockcUSDC(cToken).mint(msg.sender, amount);
    }

    function supplyTo(address dst, address asset, uint amount) external override {
        // Check if the asset is supported
        address cToken = cTokens[asset];
        require(cToken != address(0), "Asset not supported");

        // Transfer tokens from the user to this contract
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        
        // Update balances for the destination address
        totalSupply[asset] += amount;

        // Mint cTokens to the destination address
        MockcUSDC(cToken).mint(dst, amount);
    }

    function withdraw(address asset, uint amount) external override {
        // Check if the asset is supported
        address cToken = cTokens[asset];
        require(cToken != address(0), "Asset not supported");

        require(MockcUSDC(cToken).balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        // Update balances
        totalSupply[asset] -= amount;
        
        // Burn cTokens from the user
        MockcUSDC(cToken).burn(msg.sender, amount);
        
        // Transfer tokens back to the user
        IERC20(asset).transfer(msg.sender, amount);
    }

    function withdrawTo(address dst, address asset, uint amount) external override {
        address cToken = cTokens[asset];
        require(cToken != address(0), "Asset not supported");

        require(MockcUSDC(cToken).balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        // Update balances
        totalSupply[asset] -= amount;

        // Burn cTokens from the user
        MockcUSDC(cToken).burn(msg.sender, amount);

        // Transfer tokens back to the destination address
        IERC20(asset).transfer(dst, amount);
    }
}
