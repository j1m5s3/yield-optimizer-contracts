// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;
/*
This contract will store the ETH denominated fee that clients will pay on creation of an SMA
*/


contract SMAFeeOracle {
    address public admin;
    address public smaAddressProvider;

    uint256 public fee;
    string public bestRateProtocolName;

    constructor(address _smaAddressProvider) {
        admin = msg.sender;
        smaAddressProvider = _smaAddressProvider;
    }

    function setETHFee(uint256 _fee) external onlyAdmin{
        fee = _fee;
    }

    function setBestRateProtocol(string memory _protocolName) external onlyAdmin{
        bestRateProtocolName = _protocolName;
    }

    function getFee() external view returns (uint256) {
        return fee;
    }

    function getBestRateProtocol() external view returns (string memory) {
        return bestRateProtocolName;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only Admin address can access");
        _;
    }
}