// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import {ISMAAddressProvider, ISMAManagerAdmin, IERC20, IManagementRegistry} from "./interfaces/SMAInterfaces.sol";
import {IAAVEPool, ICompoundPool} from "./interfaces/PoolInterfaces.sol";
import {SMAUtils} from "./utils/SMAUtils.sol";
import {SMAStructs} from "./data_structs/SMAStructs.sol";

contract ManagementLogic {
    address public smaAddressProvider;

    event InvestAction(
        address indexed sma,
        address indexed asset,
        string fromProto,
        string toProto,
        uint256 amount,
        uint256 timestamp
    );

    constructor(address _smaAddressProvider) {
        smaAddressProvider = _smaAddressProvider;
    }

    function setSMAAddressProvider(address _smaAddressProvider) external onlyAdmin {
        smaAddressProvider = _smaAddressProvider;
    }

    function invest(address _asset, uint256 _amount, string memory _fromProto, string memory _toProto) external onlySMA {
        address tokenToInvest;

        require(
            keccak256(abi.encodePacked(_fromProto)) != keccak256(abi.encodePacked(_toProto)), 
            "Cannot invest in the same protocol"
        );

        bool isAllowedBaseToken = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getIsAllowedToken(_asset);

        bool isAllowedInterestToken = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getIsAllowedInterestToken(_asset);

        require(isAllowedBaseToken || isAllowedInterestToken, "Asset is not operable.");

        tokenToInvest = _determineTxnToken(_asset);
        
        // Withdraw from the fromProto
        if (isAllowedInterestToken) {
            _withdraw(tokenToInvest, _amount, _fromProto);
        }
        

        // Deposit to the toProto
        _deposit(tokenToInvest, _amount, _toProto);
    }

    function _determineTxnToken(address _asset) internal view returns (address) {
        address interestTokenBase;
        
        SMAStructs.InterestTokens[] memory interestTokens = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getAllowedInterestTokens();

        interestTokenBase = SMAUtils.getInterestTokenBase(_asset, interestTokens);
        if (interestTokenBase != address(0)) {
            return interestTokenBase;
        }
        
        return _asset;
    }

    function _withdraw(address _asset, uint256 _amount, string memory _fromProto) internal {
        address fromProtoAddress = ISMAAddressProvider(smaAddressProvider).getProtocolAddress(_fromProto);

        require(fromProtoAddress != address(0), "Protocol not found");

        // Withdraw from the fromProto
        if(keccak256(abi.encodePacked(_fromProto)) == keccak256(abi.encodePacked("AAVE"))) {
            IAAVEPool(fromProtoAddress).withdraw(_asset, _amount, address(this));
        } else if(keccak256(abi.encodePacked(_fromProto)) == keccak256(abi.encodePacked("COMPOUND"))) {
            ICompoundPool(fromProtoAddress).withdraw(_asset, _amount);
        } else {
            revert("Protocol not found");
        }
    }

    function _deposit(address _asset, uint256 _amount, string memory _toProto) internal {
        address toProtoAddress = ISMAAddressProvider(smaAddressProvider).getProtocolAddress(_toProto);

        require(toProtoAddress != address(0), "Protocol not found");

        // Deposit to the toProto
        if(keccak256(abi.encodePacked(_toProto)) == keccak256(abi.encodePacked("AAVE"))) {
            IAAVEPool(toProtoAddress).supply(_asset, _amount, msg.sender, 0);
        } else if(keccak256(abi.encodePacked(_toProto)) == keccak256(abi.encodePacked("COMPOUND"))) {
            ICompoundPool(toProtoAddress).supplyTo(msg.sender, _asset, _amount);
        } else {
            revert("Protocol not found");
        }
    }

    function transferFromContract(address _asset, address _to, uint256 _amount) external onlyAdmin {
        IERC20(_asset).transfer(_to, _amount);
    }

    modifier onlyAdmin {
        address walletAdmin = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getWalletAdmin();
        require(msg.sender == walletAdmin, "Only Admin address can access");
        _;
    }

    modifier onlySMA {
        address managementRegistry = ISMAAddressProvider(smaAddressProvider).getManagementRegistry();
        require(IManagementRegistry(managementRegistry).getIsActiveSMA(msg.sender), "Only SMA contract can access");
        _;
    }
}