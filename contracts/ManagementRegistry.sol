// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

contract ManagementRegistry {
    mapping(address => bytes32) public managementRegistry;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function setManagement(address _contract, bytes32 _botId) external onlyAdmin {
        managementRegistry[_contract] = _botId;
    }

    function getManagement(address _contract) external view returns (bytes32) {
        return managementRegistry[_contract];
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only Admin address can access");
        _;
    }
}