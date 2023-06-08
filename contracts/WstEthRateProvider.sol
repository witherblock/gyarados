// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contracts
import {MultiChainRateProvider} from "./core/MultiChainRateProvider.sol";

// Interfaces
import {IWstETH} from "./interfaces/IWstETH.sol";

/// @title TODO rETH cross chain rate provider
/// @author witherblock
/// @notice Provides the current exchange rate of rETH to a receiver contract on a different chain than the one this contract is deployed on
contract WstEthRateProvider is MultiChainRateProvider {
    constructor(address _layerZeroEndpoint) {
        rateInfo = RateInfo({
            tokenSymbol: "rETH",
            tokenAddress: 0xae78736Cd615f374D3085123A210448E74Fc6393,
            baseTokenSymbol: "ETH",
            baseTokenAddress: address(0) // Address 0 for native tokens
        });
        layerZeroEndpoint = _layerZeroEndpoint;
    }

    /// @notice Returns the latest rate from the rETH contract
    function getLatestRate() public view override returns (uint256) {
        return
            IWstETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0).stEthPerToken();
    }
}
