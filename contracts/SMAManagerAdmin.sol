// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import {SMAStructs} from "./data_structs/SMAStructs.sol";
/*
Admin contract that will control the subscription fees individually and
*/
contract SMAManagerAdmin {
    address public admin;
    address public factoryAddress; // Address of the factory contract
    address public allowedPayToken; // Allowed token for payment of subscription fees

    uint256 public payPeriod; // Pay period for the subscription
    uint256 public subscriptionFee; // Subscription fee for the client

    uint256 public MAX_ALLOWED_SMAS;

    uint256 public smaFeeUSD; // Fee in USD for the creation of an SMA

    SMAStructs.OperableToken[] public allowedBaseTokens; // Allowed base tokens that that user desires yield for
    mapping(address => bool) public isAllowedToken; // Mapping of allowed tokens

    SMAStructs.InterestTokens[] public allowedInterestTokens; // Allowed interest tokens
    mapping(address => bool) public isAllowedInterestToken; // Mapping of allowed interest tokens

    mapping(address => SMAStructs.SMA) public SMAs; // Mapping of client address to their SMA
    
    constructor(
        address _admin,
        address _allowedPayToken,
        uint256 _payPeriod,
        uint256 _subscriptionFee,
        uint256 _maxAllowedSMAS,
        uint256 _smaFeeUSD
    ){
        admin = _admin;
        allowedPayToken = _allowedPayToken;
        payPeriod = _payPeriod;
        subscriptionFee = _subscriptionFee;

        MAX_ALLOWED_SMAS = _maxAllowedSMAS;
        smaFeeUSD = _smaFeeUSD;
    }

    // Writes
    function addAllowedToken(address _tokenAddress, string memory _tokenSymbol) external onlyAdmin{
        allowedBaseTokens.push(SMAStructs.OperableToken(_tokenAddress, _tokenSymbol));
    }

    function setIsAllowedToken(address _tokenAddress, bool _isAllowed) external onlyAdmin{
        isAllowedToken[_tokenAddress] = _isAllowed;
    }

    function addAllowedInterestToken(address _tokenAddress, string memory _tokenSymbol, string memory _protocol, address _baseToken) external onlyAdmin{
        allowedInterestTokens.push(SMAStructs.InterestTokens(_tokenAddress, _tokenSymbol, _protocol, _baseToken));
    }

    function setIsAllowedInterestToken(address _tokenAddress, bool _isAllowed) external onlyAdmin{
        isAllowedInterestToken[_tokenAddress] = _isAllowed;
    }

    function setPayPeriod(uint256 _payPeriod) external onlyAdmin{
        payPeriod = _payPeriod;
    }

    function setSubscriptionFee(uint256 _subscriptionFee) external onlyAdmin{
        subscriptionFee = _subscriptionFee;
    }

    function setWalletAdmin(address _admin) external onlyAdmin{
        admin = _admin;
    }

    function addSMA(address _client, SMAStructs.SMA memory _sma) external onlyAdminOrFactory{
        SMAs[_client] = _sma;
    }

    function setFactoryAddress(address _factoryAddress) external onlyAdmin{
        factoryAddress = _factoryAddress;
    }

    function setMaxAllowedSMAs(uint256 _maxAllowed) external onlyAdmin{
        MAX_ALLOWED_SMAS = _maxAllowed;
    }

    function setSMAFeeUSD(uint256 _smaFeeUSD) external onlyAdmin{
        smaFeeUSD = _smaFeeUSD;
    }

    // Reads
    function getMaxAllowedSMAs() external view returns(uint256){
        return MAX_ALLOWED_SMAS;
    }

    function getAllowedBaseTokens() external view returns(SMAStructs.OperableToken[] memory){
        return allowedBaseTokens;
    }

    function getIsAllowedToken(address _token) external view returns(bool){
        return isAllowedToken[_token];
    }

    function getAllowedInterestTokens() external view returns(SMAStructs.InterestTokens[] memory){
        return allowedInterestTokens;
    }

    function getIsAllowedInterestToken(address _token) external view returns(bool){
        return isAllowedInterestToken[_token];
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

    function getSMA(address _client) external view returns(SMAStructs.SMA memory){
        return SMAs[_client];
    }

    function getWalletAdmin() external view returns(address){
        return admin;
    }

    function getSMAFeeUSD() external view returns(uint256){
        return smaFeeUSD;
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