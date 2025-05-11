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
        activelyManaged = false;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Writes

    /**
    * Function to set the manager of the SMA. Only the admin can call this function
    *
    * @param _manager: Address of the new manager
    */
    function setManager(address _manager) external onlyAdmin {
        manager = _manager;
    }

    /**
    * Function to transfer assets from client to the SMA. Only the client can call this function
    *
    * @param _asset: Address of the asset to transfer
    * @param _amount: Amount of the asset to transfer
    */
    function transferFromClient(address _asset, uint256 _amount) external onlyClient {
        bool transferSuccess;
        IERC20 token;

        bool isAllowedToken = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getIsAllowedToken(_asset);

        bool isAllowedInterestToken = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getIsAllowedInterestToken(_asset);

        require(isAllowedToken || isAllowedInterestToken, "Asset is not operable.");

        token = IERC20(_asset);

        require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance not enough. Please approve more tokens.");

        transferSuccess = token.transferFrom(client, address(this), _amount);
        require(transferSuccess, "Transfer failed. Please try again.");
    }

    /**
    * Function to transfer assets from the SMA to allowed addresses (client, manager, admin)
    *
    * @param _asset: Address of the asset to transfer
    * @param _amount: Amount of the asset to transfer
    */
    function transferFromSMA(address _asset, uint256 _amount) external onlyClient {
        bool transferSuccess;
        // bool approved;
        IERC20 token;

        token = IERC20(_asset);

        // approved = token.approve(address(this), _amount);
        // require(approved, "Approval failed. Please try again.");


        transferSuccess = token.transfer(client, _amount);

        require(transferSuccess, "Transfer failed. Please try again.");
    }

    function invest(address _asset, string memory _fromProto, string memory _toProto) external onlyAllowed {        
        address mangementLogicAddress = ISMAAddressProvider(smaAddressProvider).getManagementLogic();
        uint256 currAssetBalanace = IERC20(_asset).balanceOf(address(this));

        require(currAssetBalanace > 0, "No assets to invest.");

        bool transferSuccess = IERC20(_asset).transfer(mangementLogicAddress, currAssetBalanace);
        require(transferSuccess, "Transfer failed. Please try again.");

        IManagementLogic(
            mangementLogicAddress
        ).invest(_asset, currAssetBalanace, _fromProto, _toProto);
    }

    /**
    *   Function to withdraw assets from the SMA
    *   @param _active: Boolean to set the active management status
    */
    function setActiveManagement(bool _active) external onlyClient {
        IManagementRegistry(
            ISMAAddressProvider(smaAddressProvider).getManagementRegistry()
        ).setIsActivelyManaged(address(this), _active);

        activelyManaged = _active;
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

    /**
    * Function to get the asset balances of the SMA
    */
    function getAssetBalances() external view returns (SMAStructs.Asset[] memory) {
        SMAStructs.OperableToken[] memory allowedBaseTokens;
        SMAStructs.InterestTokens[] memory allowedInterestTokens;

        allowedBaseTokens = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getAllowedBaseTokens();

        allowedInterestTokens = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getAllowedInterestTokens();

        uint256 balanceIterator = 0;
        SMAStructs.Asset[] memory assetBalances = new SMAStructs.Asset[](allowedBaseTokens.length + allowedInterestTokens.length);

        for (uint256 i = 0; i < allowedBaseTokens.length; i++) {
            assetBalances[balanceIterator] = SMAStructs.Asset({
                tokenAddress: allowedBaseTokens[i].tokenAddress,
                tokenSymbol: allowedBaseTokens[i].tokenSymbol,
                tokenBalance: IERC20(allowedBaseTokens[i].tokenAddress).balanceOf(address(this)),
                decimals: allowedBaseTokens[i].decimals
            });
            balanceIterator++;
        }

        for (uint256 i = 0; i < allowedInterestTokens.length; i++) {
            assetBalances[balanceIterator] = SMAStructs.Asset({
                tokenAddress: allowedInterestTokens[i].tokenAddress,
                tokenSymbol: allowedInterestTokens[i].tokenSymbol,
                tokenBalance: IERC20(allowedInterestTokens[i].tokenAddress).balanceOf(address(this)),
                decimals: allowedInterestTokens[i].decimals
            });
            balanceIterator++;
        }

        return assetBalances;
    }

    /**
     * Function to get the balance of a specific asset
     * 
     * @param _asset: Address of the asset
     */
    function getAssetBalance(address _asset) external view returns (SMAStructs.Asset memory) {
        SMAStructs.OperableToken[] memory allowedBaseTokens;
        SMAStructs.InterestTokens[] memory allowedInterestTokens;

        allowedBaseTokens = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getAllowedBaseTokens();

        allowedInterestTokens = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getAllowedInterestTokens();

        for (uint256 i = 0; i < allowedBaseTokens.length; i++) {
            if (allowedBaseTokens[i].tokenAddress == _asset) {
                return SMAStructs.Asset({
                    tokenAddress: allowedBaseTokens[i].tokenAddress,
                    tokenSymbol: allowedBaseTokens[i].tokenSymbol,
                    tokenBalance: IERC20(allowedBaseTokens[i].tokenAddress).balanceOf(address(this)),
                    decimals: allowedBaseTokens[i].decimals
                });
            }
        }

        for (uint256 i = 0; i < allowedInterestTokens.length; i++) {
            if (allowedInterestTokens[i].tokenAddress == _asset) {
                return SMAStructs.Asset({
                    tokenAddress: allowedInterestTokens[i].tokenAddress,
                    tokenSymbol: allowedInterestTokens[i].tokenSymbol,
                    tokenBalance: IERC20(allowedInterestTokens[i].tokenAddress).balanceOf(address(this)),
                    decimals: allowedInterestTokens[i].decimals
                });
            }
        }

        return SMAStructs.Asset({
            tokenAddress: address(0),
            tokenSymbol: "",
            tokenBalance: 0,
            decimals: 0
        });
    }

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