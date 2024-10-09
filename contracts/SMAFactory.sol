// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

import "./SMA.sol"; // SMA contract
import "./SMAStructs.sol"; // Various structs for the SMA contract to operate
import "./SMAInterfaces.sol"; // Various interfaces for the SMA contract to operate
/*
This contract will facilitate the deploy of new SMA contracts that the client and
the bots that will manage the protfolio, will share.
*/

contract SMAFactory {

    address public portfolioManager;
    address public adminContract;

    uint256 public NUM_SMAS_DEPLOYED;
    uint256 public MAX_ALLOWED_SMAS; // Max allowed SMAS to be deployed

    mapping(address => address) public USER_TO_SMA_MAPPING; // Mapping of user address to SMA address

    event SMACreated(
        address indexed  _sma,
        address indexed _client,
        uint256 timestamp,
        string message
    );

    constructor(address _portfolioManager, address _adminContract) {
        portfolioManager = _portfolioManager;
        adminContract = _adminContract;

        NUM_SMAS_DEPLOYED = 0;
    }

    // Writes

    /*
    Function to deploy new SMA contracts initiated by the prospective client

    @param _prospectiveClient: Wallet address of the client

    @return: None
    */
    function deploySMA (address _prospectiveClient) external payable {
        // Assert to ensure number of SMAs does not exceed the MAX_ALLOWED_SMAS
        require(NUM_SMAS_DEPLOYED < MAX_ALLOWED_SMAS, "MAX_ALLOWED_SMAS have been deployed");

        // Deploy SMA contract via this function
        SMA smaContract = new SMA(_prospectiveClient, adminContract);
        address contractAddress = address(smaContract);

        ISMAManagerAdmin admin = ISMAManagerAdmin(adminContract);

        address payToken = admin.getPayToken();
        uint256 payPeriod = admin.getPayPeriod();
        uint256 nextPaymentDue = block.timestamp + payPeriod * 1 days;

        SMAStructs.SMA memory newSma = SMAStructs.SMA(
        {
            client: _prospectiveClient,
            manager: portfolioManager,
            admin: adminContract,
            payToken: payToken,
            sma: contractAddress,
            subscriptionPaid: false,
            timeCreated: block.timestamp,
            nextPaymentDue: nextPaymentDue
        });

        admin.updateSMA(_prospectiveClient, newSma);

        USER_TO_SMA_MAPPING[_prospectiveClient] = contractAddress;

        emit SMACreated(
            contractAddress,
            _prospectiveClient,
            block.timestamp,
            "SMA created"
        );
    }

    /*
    Function to set MAX_ALLOWED_SMAS to given amount

    @param _maxAllowed: New value to be assigned to MAX_ALLOWED_SMAS

    @return: None
    */
    function setMaxAllowedSMA(uint256 _maxAllowed) external onlyManager {
        MAX_ALLOWED_SMAS = _maxAllowed;
    }

    /*
    Set the manager admin address

    @param _admin: Address of the manager admin

    @return: None
    */
    function setAdmin(address _admin) external onlyManager {
        adminContract = _admin;
    }

    // Reads

    /*
    Function to get the MAX_ALLOWED_SMAS

    @param: None

    @return: MAX_ALLOWED_SMAS
    */
    function getMaxAllowedSMA() external view returns (uint256) {
        return MAX_ALLOWED_SMAS;
    }

    /*
    Function to get the SMA contract address mapped to the given wallet address

    @param _clientAddress: Wallet address of the client

    @return: Address of the deployed SMA contract
    */
    function getClientSMAAddress(address _clientAddress) public view returns (address) {
        address smaContractAddress = USER_TO_SMA_MAPPING[_clientAddress];
        return smaContractAddress;
    }

    // Modifiers

    /*
    Modifier that prevents addresses that are != portfolioManager from accessing
    */
    modifier onlyManager {
        require(msg.sender == portfolioManager, "Only PM can access this. You are not the PM.");
        _;
    }

}