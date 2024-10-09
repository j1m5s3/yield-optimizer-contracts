// SPDX-License-Identifier: GPL-3.0

//pragma solidity >=0.8.2 <0.9.0;
pragma solidity ^0.8.19;

import "./SMAStructs.sol" as Structs;
/*
Admin contract that will control the subscription fees individually and
*/
contract SMAManagerAdmin {
    address public admin;
    address public factoryAddress; // Address of the factory contract
    address allowedPayToken; // Allowed token for payment of subscription fees

    uint256 public payPeriod; // Pay period for the subscription
    uint256 public subscriptionFee; // Subscription fee for the client

    uint256 public MAX_ALLOWED_SMAS = 5;

    Structs.SMAStructs.OperableToken[] public allowedTokens; // Allowed base tokens that that user desires yield for
    Structs.SMAStructs.InterestTokens[] public allowedInterestTokens; // Allowed interest tokens

    mapping(address => Structs.SMAStructs.SMA) public SMAs; // Mapping of client address to their SMA

    constructor(
        address _admin,
        address _allowedPayToken,
        uint256 _payPeriod,
        uint256 _subscriptionFee
    ){
        admin = _admin;
        allowedPayToken = _allowedPayToken;
        payPeriod = _payPeriod;
        subscriptionFee = _subscriptionFee;
    }

    // Writes
    function addAllowedToken(address _tokenAddress, string memory _tokenSymbol) external onlyAdmin{
        allowedTokens.push(Structs.SMAStructs.OperableToken(_tokenAddress, _tokenSymbol));
    }

    function addAllowedInterestToken(address _tokenAddress, string memory _tokenSymbol, string memory _protocol) external onlyAdmin{
        allowedInterestTokens.push(Structs.SMAStructs.InterestTokens(_tokenAddress, _tokenSymbol, _protocol));
    }

    function setPayPeriod(uint256 _payPeriod) external onlyAdmin{
        payPeriod = _payPeriod;
    }

    function setSubscriptionFee(uint256 _subscriptionFee) external onlyAdmin{
        subscriptionFee = _subscriptionFee;
    }

    function updateSMA(address _client, Structs.SMAStructs.SMA memory _sma) external onlyAdminOrFactory{
        SMAs[_client] = _sma;
    }

    function setFactoryAddress(address _factoryAddress) external onlyAdmin{
        factoryAddress = _factoryAddress;
    }

    function setMaxAllowedSMAs(uint256 _maxAllowed) external onlyAdmin{
        MAX_ALLOWED_SMAS = _maxAllowed;
    }

    // Reads
    function getAllowedTokens() external view returns(Structs.SMAStructs.OperableToken[] memory){
        return allowedTokens;
    }

    function getAllowedInterestTokens() external view returns(Structs.SMAStructs.InterestTokens[] memory){
        return allowedInterestTokens;
    }

    function getSubscriptionFee() external view returns(uint256){
        return subscriptionFee;
    }

    function getPayPeriod() external view returns(uint256){
        return payPeriod;
    }

    function getPayToken() external view returns(address){
        return allowedPayToken;
    }

    function getFactoryAddress() external view returns(address){
        return factoryAddress;
    }

    function getSMA(address _client) external view returns(Structs.SMAStructs.SMA memory){
        return SMAs[_client];
    }

    // Modifiers
    modifier onlyAdmin{
        require(msg.sender == admin, "Only admin can access this. You are not the admin.");
        _;
    }

    modifier onlyAdminOrFactory{
        require(msg.sender == admin || msg.sender == factoryAddress, "Only admin or factory can access this.");
        _;
    }

    modifier onlySMAOrAdmin(address _client){
        require(msg.sender == SMAs[_client].sma || msg.sender == admin, "SMA does not exist for this client. Only the SMA can access this.");
        _;
    }
}