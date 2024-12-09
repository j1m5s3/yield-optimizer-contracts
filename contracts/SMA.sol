// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import {
    ISMAManagerAdmin, 
    ISMAAddressProvider, 
    IERC20, 
    IManagementLogic, 
    IManagementRegistry
} from "./interfaces/SMAInterfaces.sol";
import {SMAUtils} from "./utils/SMAUtils.sol";
import {SMAStructs} from "./data_structs/SMAStructs.sol";

contract SMA {
    address public client;
    address public manager;
    address public smaAddressProvider;

    bool public subscriptionPaid; // Boolean describing if the client has paid their subscription
    bool public activelyManaged; // Boolean describing if the SMA is actively managed
    uint256 timeCreated; // Timestamp of when SMA was created
    uint256 nextPaymentDue; // Timestamp of when the next payment is due

    constructor(address _client, address _addressProvider) {
        client = _client;
        smaAddressProvider = _addressProvider;

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
        IERC20 token;
        SMAStructs.OperableToken[] memory allowedTokens;

        allowedTokens = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getAllowedTokens();

        bool isAllowedToken = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getIsAllowedToken(_asset);

        bool isAllowedInterestToken = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getIsAllowedInterestToken(_asset);

        bool isOperable = isAllowedToken || isAllowedInterestToken;

        require(isOperable, "Asset is not operable.");

        token = IERC20(_asset);

        require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance not enough. Please approve more tokens.");

        transferSuccess = token.transferFrom(client, address(this), _amount);
        require(transferSuccess, "Transfer failed. Please try again.");
    }

    /*
    Function to transfer assets from the SMA to allowed addresses (client, manager, admin)

    @param _asset: Address of the asset to transfer
    @param _amount: Amount of the asset to transfer
    */
    function transferFromSMA(address _asset, uint256 _amount) external onlyClient {
        bool transferSuccess;
        bool approved;
        IERC20 token;

        token = IERC20(_asset);

        approved = token.approve(address(this), _amount);
        require(approved, "Approval failed. Please try again.");


        transferSuccess = token.transfer(client, _amount);

        require(transferSuccess, "Transfer failed. Please try again.");
    }

    function invest(address _asset, string memory _fromProto, string memory _toProto) external onlyAllowed {        
        address mangementLogicAddress = ISMAAddressProvider(smaAddressProvider).getManagementLogic();
        uint256 currAssetBalanace = IERC20(_asset).balanceOf(address(this));

        require(currAssetBalanace > 0, "No assets to invest.");

        IERC20(_asset).approve(mangementLogicAddress, currAssetBalanace);
        IManagementLogic(
            mangementLogicAddress
        ).invest(_asset, currAssetBalanace, _fromProto, _toProto);
        IERC20(_asset).approve(mangementLogicAddress, 0);
    }

    function setActiveManagement(bool _active) external onlyClient {
        IManagementRegistry(
            ISMAAddressProvider(smaAddressProvider).getManagementRegistry()
        ).setIsActivelyManaged(address(this), _active);
    }

    /*
    function paySubscription() external onlyClient {
        bool transferSuccess;
        smaInterfaces.IERC20 token;

        require(subscriptionPaid == false, "Subscription already paid.");

        token = smaInterfaces.IERC20(UtilsLib.SMAUtils.allowedPayToken());
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
        address walletAdmin = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getWalletAdmin();
        require(msg.sender == walletAdmin, "Only admin can access this. You are not the admin.");
        _;
    }

    modifier onlyAllowed{
        require(msg.sender == client || msg.sender == manager,
        "Only ALLOWED users can access this. You are not an ALLOWED user."
        );
        _;
    }

}