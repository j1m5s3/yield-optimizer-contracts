// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

contract SMAAddressProvider {
    address public smaFactory;
    address public smaManagerAdmin;
    address public smaManager;
    address public smaFeeOracle;
    address public admin;
    mapping (string => address) PROTOCOL_ADDRESSES;

    constructor(address _smaFactory, address _smaManagerAdmin, address _smaManager, address _smaFeeOracle) {
        smaFactory = _smaFactory;
        smaManagerAdmin = _smaManagerAdmin;
        smaManager = _smaManager;
        smaFeeOracle = _smaFeeOracle;
        admin = msg.sender;
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

    function getProtocolAddress(string memory _protocolName) external view returns (address) {
        return PROTOCOL_ADDRESSES[_protocolName];
    }

    function setProtocolAddress(string memory _protocolName, address _protocolAddress) external {
        PROTOCOL_ADDRESSES[_protocolName] = _protocolAddress;
    }

}