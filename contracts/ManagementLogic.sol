// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "./interfaces/PoolInterfaces.sol" as pool;
import "./interfaces/SMAInterfaces.sol" as smaInterfaces;

contract ManagementLogic {
    address public admin;
    address public smaAddressProvider;

    constructor(address _smaAddressProvider) {
        admin = msg.sender;
        smaAddressProvider = _smaAddressProvider;
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    function setSMAAddressProvider(address _smaAddressProvider) external onlyAdmin {
        smaAddressProvider = _smaAddressProvider;
    }

    function invest(address _asset, string memory _fromProto, string memory _toProto) external onlyAdmin {
        address fromProtoAddress = smaInterfaces.ISMAAddressProvider(smaAddressProvider).getProtocolAddress(_fromProto);
        address toProtoAddress = smaInterfaces.ISMAAddressProvider(smaAddressProvider).getProtocolAddress(_toProto);

        require(fromProtoAddress != address(0), "Protocol not found");
        require(toProtoAddress != address(0), "Protocol not found");
        require(fromProtoAddress != toProtoAddress, "Cannot invest in the same protocol");

        uint256 amount = smaInterfaces.IERC20(_asset).balanceOf(address(this));
        
        // Withdraw from the fromProto
        if(keccak256(abi.encodePacked(_fromProto)) == keccak256(abi.encodePacked("AAVE"))) {
            pool.IAAVEPool(fromProtoAddress).withdraw(_asset, amount, address(this));
        } else if(keccak256(abi.encodePacked(_fromProto)) == keccak256(abi.encodePacked("COMPOUND"))) {
            pool.ICompoundPool(fromProtoAddress).withdraw(_asset, amount);
        } else {
            revert("Protocol not found");
        }

        // Deposit to the toProto
        if(keccak256(abi.encodePacked(_toProto)) == keccak256(abi.encodePacked("AAVE"))) {
            pool.IAAVEPool(toProtoAddress).supply(_asset, amount, address(this), 0);
        } else if(keccak256(abi.encodePacked(_toProto)) == keccak256(abi.encodePacked("COMPOUND"))) {
            pool.ICompoundPool(toProtoAddress).supply(_asset, amount);
        } else {
            revert("Protocol not found");
        }
    }
    /*
    function clientInvest(address _asset, string memory _fromProto, string memory _toProto, address _client) external onlyAdmin {
        address fromProtoAddress = SMAAddressProvider(smaAddressProvider).getProtocolAddress(_fromProto);
        address toProtoAddress = SMAAddressProvider(smaAddressProvider).getProtocolAddress(_toProto);
        //address smaOracle = SMAAddressProvider(smaAddressProvider).getOracle();

        require(fromProtoAddress != address(0), "Protocol not found");
        require(toProtoAddress != address(0), "Protocol not found");
        require(fromProtoAddress != toProtoAddress, "Cannot invest in the same protocol");

        uint256 amount = smaInterfaces.IERC20(_asset).balanceOf(_client);

        require(amount > 0, "Client has no balance");

        //string memory bestRateProtocol = smaInterfaces.SMAOracle(smaOracle).getBestRateProtocol(_asset);
        
        // Withdraw from the fromProto
        if(keccak256(abi.encodePacked(_fromProto)) == keccak256(abi.encodePacked("AAVE"))) {
            pool.IAAVEPool(fromProtoAddress).withdraw(_asset, amount, _client);
        } else if(keccak256(abi.encodePacked(_fromProto)) == keccak256(abi.encodePacked("COMPOUND"))) {
            pool.ICompoundPool(fromProtoAddress).withdraw(_asset, amount);
        } else {
            revert("Protocol not found");
        }

        // Deposit to the toProto
        if(keccak256(abi.encodePacked(_toProto)) == keccak256(abi.encodePacked("AAVE"))) {
            pool.IAAVEPool(toProtoAddress).supply(_asset, amount, _client, 0);
        } else if(keccak256(abi.encodePacked(_toProto)) == keccak256(abi.encodePacked("COMPOUND"))) {
            pool.ICompoundPool(toProtoAddress).supply(_asset, amount);
        } else {
            revert("Protocol not found");
        }
    }
    */

    modifier onlyAdmin {
        require(msg.sender == admin, "Only Admin address can access");
        _;
    }
}