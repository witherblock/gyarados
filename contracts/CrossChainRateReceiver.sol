// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ILayerZeroReceiver} from "./interfaces/ILayerZeroReceiver.sol";

import "hardhat/console.sol";

/// @title Cross chain rate receiver
/// @author witherblock
/// @notice Receives a rate to from a provider contract on a different chain than the one this contract is deployed on
/// @dev Powered using LayerZero
contract CrossChainRateReceiver is ILayerZeroReceiver, Ownable {
    /// @notice Last rate updated on the receiver
    uint256 public rate;

    /// @notice Last time rate was updated.
    uint256 public lastUpdated;

    /// @notice Source chainId
    uint16 public srcChainId;

    /// @notice Rate Provider address.
    address public rateProvider;

    /// @notice Emitted when rate is updated
    /// @param newRate the rate that was updated
    event RateUpdated(uint256 newRate);

    /// @notice Emitted when RateProvider is updated
    /// @param newRateProvider the RateProvider address that was updated
    event RateProviderUpdated(address newRateProvider);

    /// @notice Emitted when the source chainId is updated
    /// @param newSrcChainId the source chainId that was updated
    event SrcChainIdUpdated(uint16 newSrcChainId);

    /// @notice Updates the RateProvider address
    /// @dev Can only be called by owner
    /// @param _rateProvider the new rate provider address
    function updateRateProvider(address _rateProvider) external onlyOwner {
        rateProvider = _rateProvider;

        emit RateProviderUpdated(_rateProvider);
    }

    /// @notice Updates the source chainId
    /// @dev Can only be called by owner
    /// @param _srcChainId the source chainId
    function updateSrcChainId(uint16 _srcChainId) external onlyOwner {
        srcChainId = _srcChainId;

        emit SrcChainIdUpdated(_srcChainId);
    }

    /// @notice LayerZero receive function which is called via send from a different chain
    /// @param _srcChainId The source chainId
    /// @param _srcAddress The source address
    /// @param _payload The payload
    function lzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64,
        bytes calldata _payload
    ) external {
        address srcAddress;
        assembly {
            srcAddress := mload(add(_srcAddress, 20))
        }

        require(_srcChainId == srcChainId, "Src chainId must be correct");
        require(srcAddress == rateProvider, "Src address must be provider");

        uint _rate = abi.decode(_payload, (uint));

        rate = _rate;

        lastUpdated = block.timestamp;

        emit RateUpdated(_rate);
    }

    /// @notice Gets the last stored rate in the contract
    function getRate() external view returns (uint256) {
        return rate;
    }
}
