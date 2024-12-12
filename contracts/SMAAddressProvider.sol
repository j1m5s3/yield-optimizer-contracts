// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "./interfaces/SMAInterfaces.sol" as smaInterfaces;

contract SMAAddressProvider {
    address public smaFactory;
    address public smaManagerAdmin;
    address public smaManager;
    address public smaOracle;
    address public managementLogic;
    address public managementRegistry;

    mapping (string => address) PROTOCOL_ADDRESSES;

    constructor(address _smaManagerAdmin) {
        smaManagerAdmin = _smaManagerAdmin;
    }

    function getSMAFactory() external view returns (address) {
        return smaFactory;
    }

    function getSMAManagerAdmin() external view returns (address) {
        return smaManagerAdmin;
    }

    function getSMAManager() external view returns (address) {
        return smaManager;
    }

    function getOracle() external view returns (address) {
        return smaOracle;
    }

    function getProtocolAddress(string memory _protocolName) external view returns (address) {
        return PROTOCOL_ADDRESSES[_protocolName];
    }

    function getManagementLogic() external view returns (address) {
        return managementLogic;
    }

    function getManagementRegistry() external view returns (address) {
        return managementRegistry;
    }

    function setProtocolAddress(string memory _protocolName, address _protocolAddress) external onlyAdmin{
        PROTOCOL_ADDRESSES[_protocolName] = _protocolAddress;
    }

    function setSMAFactory(address _smaFactory) external onlyAdmin{
        smaFactory = _smaFactory;
    }

    function setSMAManagerAdmin(address _smaManagerAdmin) external onlyAdmin{
        smaManagerAdmin = _smaManagerAdmin;
    }

    function setSMAManager(address _smaManager) external onlyAdmin{
        smaManager = _smaManager;
    }

    function setOracle(address _smaFeeOracle) external onlyAdmin{
        smaOracle = _smaFeeOracle;
    }

    function setManagementLogic(address _managementLogic) external onlyAdmin{
        managementLogic = _managementLogic;
    }

    function setManagementRegistry(address _managementRegistry) external onlyAdmin{
        managementRegistry = _managementRegistry;
    }

    modifier onlyAdmin {
        require(
            msg.sender == smaInterfaces.ISMAManagerAdmin(smaManagerAdmin).getWalletAdmin(), 
            "Only Admin address can access");
        _;
    }

}