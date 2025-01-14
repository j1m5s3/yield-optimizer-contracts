// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

library SMAStructs {

    struct OperableToken {
        address tokenAddress;
        string tokenSymbol;
    }

    struct InterestTokens {
        address tokenAddress;
        string tokenSymbol;
        string protocol;
        address baseToken;
    }

    struct SMA {
        address client; // address of the client wallet
        address sponsor; // address of the sponsor wallet
        address sma; // Address of the SMA contract
        uint256 timeCreated; // Timestamp of when SMA was created
    }

    struct Asset {
        address tokenAddress; // Address of the token
        string tokenSymbol; // Symbol of the token
        uint256 tokenBalance; // Balance of the token
    }
}
