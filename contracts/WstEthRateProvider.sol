// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contracts
import {MultiChainRateProvider} from "./core/MultiChainRateProvider.sol";

// Interfaces
import {IWstETH} from "./interfaces/IWstETH.sol";

/// @title wstETH multi-chain rate provider
/// @author witherblock
/// @notice Provides the current exchange rate of wstETH to multiple receiver contracts on a different chains than the one this contract is deployed on
contract WstEthRateProvider is MultiChainRateProvider {
    constructor(address _layerZeroEndpoint) {
        rateInfo = RateInfo({
            tokenSymbol: "wstETH",
            tokenAddress: 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0,
            baseTokenSymbol: "stETH",
            baseTokenAddress: 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84
        });
        layerZeroEndpoint = _layerZeroEndpoint;
    }

    /// @notice Returns the latest rate from the wstETH contract
    function getLatestRate() public view override returns (uint256) {
        return
            IWstETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0).stEthPerToken();
    }
}
