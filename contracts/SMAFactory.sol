// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import "./SMA.sol"; // SMA contract
import "./data_structs/SMAStructs.sol"; // Various structs for the SMA contract to operate
import {ISMAManagerAdmin, ISMAAddressProvider} from "./interfaces/SMAInterfaces.sol"; // Various interfaces for the SMA contract to operate
/*
This contract will facilitate the deploy of new SMA contracts that the client and
the bots that will manage the protfolio, will share.
*/

contract SMAFactory {
    address public smaAddressProvider;

    uint256 public NUM_SMAS_DEPLOYED;

    mapping(address => address) public USER_TO_SMA_MAPPING; // Mapping of user address to SMA address

    event SMACreated(
        address indexed  _sma,
        address indexed _client,
        uint256 timestamp,
        string message
    );

    constructor(address _smaAddressProvider) {
        smaAddressProvider = _smaAddressProvider;

        NUM_SMAS_DEPLOYED = 0;
    }

    // Writes

    /*
    Function to deploy new SMA contracts initiated by the prospective client

    @param _prospectiveClient: Wallet address of the client

    @return: None
    */
    function deploySMA (address _prospectiveClient) external payable {

        ISMAManagerAdmin admin = ISMAManagerAdmin(
            ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin()
        );

        // Assert to ensure number of SMAs does not exceed the MAX_ALLOWED_SMAS
        require(NUM_SMAS_DEPLOYED < admin.getMaxAllowedSMAs(), "MAX_ALLOWED_SMAS have been deployed");

        // Deploy SMA contract via this function
        SMA smaContract = new SMA(_prospectiveClient, smaAddressProvider);
        address contractAddress = address(smaContract);

        SMAStructs.SMA memory newSma = SMAStructs.SMA(
        {
            client: _prospectiveClient,
            sponsor: msg.sender,
            sma: contractAddress,
            timeCreated: block.timestamp
        });

        admin.addSMA(_prospectiveClient, newSma);

        USER_TO_SMA_MAPPING[_prospectiveClient] = contractAddress;

        emit SMACreated(
            contractAddress,
            _prospectiveClient,
            block.timestamp,
            "SMA created"
        );

        NUM_SMAS_DEPLOYED++;
    }

}