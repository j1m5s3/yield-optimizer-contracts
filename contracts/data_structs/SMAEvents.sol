// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

library SMAEvents {

    event SMACreated(
        address indexed  _sma,
        address indexed _client,
        uint256 timestamp,
        string message
    );

    
}