// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contracts
import {CrossChainRateReceiver} from "./core/CrossChainRateReceiver.sol";

/// @title rETH cross chain rate receiver
/// @author witherblock
/// @notice Receives the rETH rate from a provider contract on a different chain than the one this contract is deployed on
contract REthRateReceiver is CrossChainRateReceiver {
    constructor(
        uint16 _srcChainId,
        address _rateProvider,
        address _layerZeroEndpoint
    ) {
        rateInfo = RateInfo({tokenSymbol: "rETH", baseTokenSymbol: "ETH"});
        srcChainId = _srcChainId;
        rateProvider = _rateProvider;
        layerZeroEndpoint = _layerZeroEndpoint;
    }
}
