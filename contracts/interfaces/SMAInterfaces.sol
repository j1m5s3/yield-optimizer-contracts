// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.27;

import {SMAStructs} from "../data_structs/SMAStructs.sol";

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 * @dev Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface ISMAManagerAdmin {

    //read
    function getAllowedBaseTokens() external view returns (SMAStructs.OperableToken[] memory);

    function getIsAllowedToken(address _token) external view returns(bool);

    function getAllowedInterestTokens() external view returns (SMAStructs.InterestTokens[] memory);

    function getIsAllowedInterestToken(address _token) external view returns(bool);

    function getSubscriptionFee() external view returns (uint256);

    function getPayPeriod() external view returns (uint256);

    function getPayToken() external view returns(address);

    function getWalletAdmin() external view returns(address);

    function getMaxAllowedSMAs() external view returns(uint256);

    //write
    function addSMA(address _client, SMAStructs.SMA memory _sma) external;
    function removeSMA(address _client) external;
}

interface ISMAOracle {
    function getETHFee() external view returns (uint256);

    function getBestRateProtocol(address _asset) external view returns (string memory);
}

interface IManagementLogic {
    function invest(address _asset, uint256 _amount, string memory _fromProto, string memory _toProto) external;
}

interface ISMAAddressProvider {
    function getSMAFactory() external view returns (address);

    function getSMAManagerAdmin() external view returns (address);

    function getSMAManager() external view returns (address);

    function getOracle() external view returns (address);

    function getProtocolAddress(string memory _protocolName) external view returns (address);

    function getManagementLogic() external view returns (address);

    function getManagementRegistry() external view returns (address);

    function getRevenuePool() external view returns (address);
}

interface IManagementRegistry {
    function setIsActiveSMA(address _contract, bool _isSMA) external;

    function setIsActivelyManaged(address _contract, bool _isActivelyManaged) external;

    function getManagement(address _contract) external view returns (bytes32);

    function getIsActiveSMA(address _contract) external view returns (bool);
}

interface ISMAFactory {
    function getNumSMAsDeployed() external view returns (uint256);

    function getClientSMAAddress(address _client) external view returns (address);

    function deleteClientSMAAddress(address _client) external;
}

interface IRevenuePool {
    function depositSubscription(address _client) external payable;
}
