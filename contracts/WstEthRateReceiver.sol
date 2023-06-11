// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contracts
import {CrossChainRateReceiver} from "./core/CrossChainRateReceiver.sol";

// Interfaces
import {IWstETH} from "./interfaces/IWstETH.sol";

/// @title wstETH cross chain rate receiver
/// @author witherblock
/// @notice Receives the wstETH rate from a provider contract on a different chain than the one this contract is deployed on
contract WstEthRateReceiver is CrossChainRateReceiver {
    constructor(
        uint16 _srcChainId,
        address _rateProvider,
        address _layerZeroEndpoint
    ) {
        rateInfo = RateInfo({tokenSymbol: "wstETH", baseTokenSymbol: "stETH"});
        srcChainId = _srcChainId;
        rateProvider = _rateProvider;
        layerZeroEndpoint = _layerZeroEndpoint;
    }
}
