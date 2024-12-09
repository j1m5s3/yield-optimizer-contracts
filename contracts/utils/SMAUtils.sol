// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.27;

import "../data_structs/SMAStructs.sol";

library SMAUtils {

    function assetIsOperable(address _asset, SMAStructs.OperableToken[] memory _allowedTokens) internal pure returns(bool){
        for(uint i = 0; i < _allowedTokens.length; i++){
            if(_asset == _allowedTokens[i].tokenAddress){
                return true;
            }
        }
        return false;
    }

    function assetIsInterestToken(address _asset, SMAStructs.InterestTokens[] memory _interestTokens) internal pure returns(bool){
        for(uint i = 0; i < _interestTokens.length; i++){
            if(_asset == _interestTokens[i].tokenAddress){
                return true;
            }
        }
        return false;
    }

    function getInterestTokenBase(address _asset, SMAStructs.InterestTokens[] memory _interestTokens) internal pure returns(address){
        for(uint i = 0; i < _interestTokens.length; i++){
            if(_asset == _interestTokens[i].tokenAddress){
                return _interestTokens[i].baseToken;
            }
        }
        return address(0);
    }
}
