// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

import "./interfaces/SMAInterfaces.sol" as Interfaces;
import "./utils/SMAUtils.sol" as UtilsLib;
import "./data_structs/SMAStructs.sol" as Structs;

contract SMA {
    address public client;
    address public manager;
    address public adminContract;

    bool public subscriptionPaid; // Boolean describing if the client has paid their subscription
    uint256 timeCreated; // Timestamp of when SMA was created
    uint256 nextPaymentDue; // Timestamp of when the next payment is due

    constructor(address _client, address _admin) {
        client = _client;
        adminContract = _admin;

        timeCreated = block.timestamp;
        nextPaymentDue = timeCreated + 30 days; // Pay periods are 30 days
        subscriptionPaid = false;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Writes

    /*
    Function to set the manager of the SMA. Only the admin can call this function

    @param _manager: Address of the new manager
    */
    function setManager(address _manager) external onlyAdmin {
        manager = _manager;
    }

    /*
    Function to transfer assets from client to the SMA. Only the client can call this function

    @param _asset: Address of the asset to transfer
    @param _amount: Amount of the asset to transfer
    */
    function transferFromClient(address _asset, uint256 _amount) external onlyClient {
        bool transferSuccess;
        Interfaces.IERC20 token;
        Structs.SMAStructs.OperableToken[] memory allowedTokens;

        allowedTokens = Interfaces.ISMAManagerAdmin(adminContract).getAllowedTokens();

        require(UtilsLib.SMAUtils.assetIsOperable(_asset, allowedTokens) == true, "Asset is not operable.");
        token = Interfaces.IERC20(_asset);

        require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance not enough. Please approve more tokens.");

        transferSuccess = token.transferFrom(client, address(this), _amount);
        require(transferSuccess, "Transfer failed. Please try again.");
    }

    /*
    Function to transfer assets from the SMA to allowed addresses (client, manager, admin)

    @param _asset: Address of the asset to transfer
    @param _amount: Amount of the asset to transfer
    */
    function transferFromSMA(address _asset, uint256 _amount) external onlyAllowed {
        bool transferSuccess;
        bool approved;
        Interfaces.IERC20 token;
        Structs.SMAStructs.OperableToken[] memory allowedTokens;

        allowedTokens = Interfaces.ISMAManagerAdmin(adminContract).getAllowedTokens();

        require(UtilsLib.SMAUtils.assetIsOperable(_asset, allowedTokens) == true, "Asset is not operable.");
        token = Interfaces.IERC20(_asset);

        approved = token.approve(address(this), _amount);
        require(approved, "Approval failed. Please try again.");

        address caller = msg.sender;
        if (caller == client) {
            transferSuccess = token.transfer(client, _amount);
        } else if (caller == manager) {
            transferSuccess = token.transfer(manager, _amount);
        }

        require(transferSuccess, "Transfer failed. Please try again.");
    }

    /*
    function paySubscription() external onlyClient {
        bool transferSuccess;
        Interfaces.IERC20 token;

        require(subscriptionPaid == false, "Subscription already paid.");

        token = Interfaces.IERC20(UtilsLib.SMAUtils.allowedPayToken());
        require(token.allowance(msg.sender, address(this)) >= SMAUtils.subscriptionFee(), "Allowance not enough. Please approve more tokens.");

        transferSuccess = token.transferFrom(client, address(this), SMAUtils.subscriptionFee());
        require(transferSuccess, "Transfer failed. Please try again.");

        subscriptionPaid = true;
        nextPaymentDue = nextPaymentDue + SMAUtils.payPeriod();
    }
    */
    // Reads

    // Modifiers
    modifier onlyManager {
        require(msg.sender == manager, "Only PM can access this. You are not the PM.");
        _;
    }

    modifier onlyClient {
        require(msg.sender == client, "Only client can access this. You are not the client.");
        _;
    }

    modifier onlyAdmin{
        require(msg.sender == adminContract, "Only admin can access this. You are not the admin.");
        _;
    }

    modifier onlyAllowed{
        require(msg.sender == adminContract || msg.sender == client || msg.sender == manager,
        "Only ALLOWED users can access this. You are not an ALLOWED user."
        );
        _;
    }

}