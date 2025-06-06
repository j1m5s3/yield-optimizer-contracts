// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import { IERC20 } from "../interfaces/SMAInterfaces.sol";

contract MockcUSDC is IERC20 {
    string public constant name = "Mock Compound USDC";
    string public constant symbol = "mcUSDC";
    uint8 public constant decimals = 6; // Compound uses 8 decimals for cTokens
    uint256 private _totalSupply;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        require(_balances[msg.sender] >= value, "Insufficient balance");
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override returns (bool) {
        require(_balances[from] >= value, "Insufficient balance");
        require(_allowances[from][msg.sender] >= value, "Insufficient allowance");
        
        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;
        
        emit Transfer(from, to, value);
        return true;
    }

    // Function to mint new tokens (only callable by the Compound pool)
    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    // Function to burn tokens (only callable by the Compound pool)
    function burn(address from, uint256 amount) external {
        require(_balances[from] >= amount, "Insufficient balance");
        _balances[from] -= amount;
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}