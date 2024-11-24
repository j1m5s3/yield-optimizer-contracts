// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "./interfaces/PoolInterfaces.sol" as pool;
import "./interfaces/SMAInterfaces.sol" as smaInterfaces;
import "./SMAAddressProvider.sol";

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
        address fromProtoAddress = SMAAddressProvider(smaAddressProvider).getProtocolAddress(_fromProto);
        address toProtoAddress = SMAAddressProvider(smaAddressProvider).getProtocolAddress(_toProto);

        require(fromProtoAddress != address(0), "Protocol not found");
        require(toProtoAddress != address(0), "Protocol not found");
        require(fromProtoAddress != toProtoAddress, "Cannot invest in the same protocol");

        uint256 amount = smaInterfaces.IERC20(_asset).balanceOf(address(this));
        
        // Withdraw from the fromProto
        if(_fromProto == "AAVE") {
            pool.IAAVEPool(fromProtoAddress).withdraw(_asset, amount);
        } else if(_fromProto == "COMPOUND") {
            pool.ICompoundPool(fromProtoAddress).withdraw(_asset, amount);
        } else {
            revert("Protocol not found");
        }

        // Deposit to the toProto
        if(_toProto == "AAVE") {
            pool.IAAVEPool(toProtoAddress).supply(_asset, amount, address(this), 0);
        } else if(_toProto == "COMPOUND") {
            pool.ICompoundPool(toProtoAddress).supply(_asset, amount);
        } else {
            revert("Protocol not found");
        }
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only Admin address can access");
        _;
    }
}