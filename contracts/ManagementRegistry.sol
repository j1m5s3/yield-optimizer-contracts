// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import {ISMAAddressProvider, ISMAManagerAdmin} from "./interfaces/SMAInterfaces.sol";

contract ManagementRegistry {
    address public admin;
    address public smaAddressProvider;

    mapping(address => bool) public isActiveSMA;
    mapping(address => bool) public isActivelyManaged;
    mapping(address => bytes32) public managementRegistry;

    event ManagementStatusChanged(
        address indexed _contract, 
        bool indexed _isActivelyManaged
    );

    constructor(address _addressProvider) {
        smaAddressProvider = _addressProvider;
    }

    function setManagement(address _contract, bytes32 _botId) external onlyAdmin {
        managementRegistry[_contract] = _botId;
    }

    function setIsActivelyManaged(address _contract, bool _isActivelyManaged) external onlySMAOrAdmin() {
        isActivelyManaged[_contract] = _isActivelyManaged;
        emit ManagementStatusChanged(_contract, _isActivelyManaged);
    }

    function setIsActiveSMA(address _contract, bool _isSMA) external onlyAdminOrFactory {
        isActiveSMA[_contract] = _isSMA;
    }

    function getManagement(address _contract) external view returns (bytes32) {
        return managementRegistry[_contract];
    }

    function getIsActiveSMA(address _contract) external view returns (bool) {
        return isActiveSMA[_contract];
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only Admin address can access");
        _;
    }

    modifier onlyAdminOrFactory {
        address smaFactory = ISMAAddressProvider(smaAddressProvider).getSMAFactory();
        address walletAdmin = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getWalletAdmin();
        require(msg.sender == smaFactory || msg.sender == walletAdmin, "Only SMA contract can access");
        _;
    }

    modifier onlySMAOrAdmin {
        address walletAdmin = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getWalletAdmin();
        bool isSMA = isActiveSMA[msg.sender];
        require(isSMA || walletAdmin == msg.sender, "Only SMA contract can access");
        _;
    }
}