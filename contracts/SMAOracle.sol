// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;
/*
This contract will store the ETH denominated fee that clients will pay on creation of an SMA
*/
import {ISMAAddressProvider, ISMAManagerAdmin} from "./interfaces/SMAInterfaces.sol";

contract SMAOracle {
    address public admin;
    address public smaAddressProvider;

    uint256 public fee;
    string public bestRateProtocolName;

    mapping(address => string) public tokenBestRateProtocol;

    constructor(address _smaAddressProvider) {
        smaAddressProvider = _smaAddressProvider;
    }

    function setETHFee(uint256 _fee) external onlyAdmin{
        fee = _fee;
    }

    function setBestRateProtocol(address _asset, string memory _protocolName) external onlyAdmin{
        tokenBestRateProtocol[_asset] = _protocolName;
    }

    function getETHFee() external view returns (uint256) {
        return fee;
    }

    function getBestRateProtocol(address _asset) external view returns (string memory) {
        string memory protocolName = tokenBestRateProtocol[_asset];
        return protocolName;
    }

    modifier onlyAdmin {
        address walletAdmin = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        ).getWalletAdmin();
        require(msg.sender == walletAdmin, "Only Admin address can access");
        _;
    }
}