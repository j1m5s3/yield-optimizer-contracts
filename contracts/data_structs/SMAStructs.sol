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
    }

    struct SMA {
        address client; // address of the client wallet
        address manager; // address of the manager wallet
        address admin; // address of admin contract
        address payToken; // Token used to pay for the subscription
        address sma; // Address of the SMA contract

        bool subscriptionPaid; // Boolean describing if the client has paid their subscription
        uint256 timeCreated; // Timestamp of when SMA was created
        uint256 nextPaymentDue; // Timestamp of when the next payment is due
    }
}
