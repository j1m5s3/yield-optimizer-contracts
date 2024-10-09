// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import "./SMAStructs.sol";

library SMAUtils {

    function assetIsOperable(address _asset, SMAStructs.OperableToken[] memory _allowedTokens) internal pure returns(bool){
        for(uint i = 0; i < _allowedTokens.length; i++){
            if(_asset == _allowedTokens[i].tokenAddress){
                return true;
            }
        }
        return false;
    }
}
