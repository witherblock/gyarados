// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {ILayerZeroEndpoint} from "../interfaces/ILayerZeroEndpoint.sol";

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title Multi chain rate provider
/// @author witherblock
/// @notice Provides a rate to a multiple receiver contracts on a different chain than the one this contract is deployed on
/// @dev Powered using LayerZero
abstract contract MultiChainRateProvider is Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;

    /// @notice Last rate updated on the provider
    uint256 public rate;

    /// @notice Last time rate was updated
    uint256 public lastUpdated;

    /// @notice Destination chainId
    EnumerableSet.UintSet private dstChainIds;

    /// @notice LayerZero endpoint address
    address public layerZeroEndpoint;

    /// @notice Rate Reciever address address
    address public rateReceiver;

    /// @notice Information of which token and base token rate is being provided
    RateInfo public rateInfo;

    struct RateInfo {
        string tokenSymbol;
        address tokenAddress;
        string baseTokenSymbol;
        address baseTokenAddress;
    }

    /// @notice Emitted when rate is updated
    /// @param newRate the rate that was updated
    event RateUpdated(uint256 newRate);

    /// @notice Emitted when LayerZero Endpoint is updated
    /// @param newLayerZeroEndpoint the LayerZero Endpoint address that was updated
    event LayerZeroEndpointUpdated(address newLayerZeroEndpoint);

    /// @notice Emitted when RateReceiver is updated
    /// @param newRateReceiver the RateReceiver address that was updated
    event RateReceiverUpdated(address newRateReceiver);

    /// @notice Emitted when a destination chainId is added
    /// @param dstChainId the destination chainId that was added
    event DstChainIdAdded(uint dstChainId);

    /// @notice Emitted when a destination chainId is removed
    /// @param dstChainId the destination chainId that was remove
    event DstChainIdRemoved(uint dstChainId);

    /// @notice Updates the LayerZero Endpoint address
    /// @dev Can only be called by owner
    /// @param _layerZeroEndpoint the new layer zero endpoint address
    function updateLayerZeroEndpoint(
        address _layerZeroEndpoint
    ) external onlyOwner {
        layerZeroEndpoint = _layerZeroEndpoint;

        emit LayerZeroEndpointUpdated(_layerZeroEndpoint);
    }

    /// @notice Updates the RateReceiver address
    /// @dev Can only be called by owner
    /// @param _rateReceiver the new rate receiver address
    function updateRateReceiver(address _rateReceiver) external onlyOwner {
        rateReceiver = _rateReceiver;

        emit RateReceiverUpdated(_rateReceiver);
    }

    /// @notice Adds a destination chainId
    /// @dev Can only be called by owner
    /// @param _dstChainId the destination chainId
    function addDstChainId(uint16 _dstChainId) external onlyOwner {
        dstChainIds.add(_dstChainId);

        emit DstChainIdAdded(_dstChainId);
    }

    /// @notice Removes a destination chainId
    /// @dev Can only be called by owner
    /// @param _dstChainId the destination chainId
    function removeDstChainId(uint16 _dstChainId) external onlyOwner {
        dstChainIds.remove(_dstChainId);

        emit DstChainIdAdded(_dstChainId);
    }

    /// @notice Updates rate in this contract and on the receivers
    /// @dev This function is set to payable to pay for gas on execute lzReceive (on the receiver contract)
    /// on the destination chain. To compute the correct value to send check here - https://layerzero.gitbook.io/docs/evm-guides/code-examples/estimating-message-fees
    function updateRate() external payable nonReentrant {
        uint256 latestRate = getLatestRate();

        bytes memory remoteAndLocalAddresses = abi.encodePacked(
            rateReceiver,
            address(this)
        );

        rate = latestRate;

        lastUpdated = block.timestamp;

        bytes memory _payload = abi.encode(latestRate);

        uint[] memory chainIds = dstChainIds.values();

        uint chainIdsLength = chainIds.length;

        for (uint i; i < chainIdsLength; ) {
            uint16 dstChainId = uint16(dstChainIds.at(i));

            (uint estimatedFee, ) = ILayerZeroEndpoint(layerZeroEndpoint)
                .estimateFees(
                    dstChainId,
                    address(this),
                    _payload,
                    false,
                    bytes("")
                );

            ILayerZeroEndpoint(layerZeroEndpoint).send{value: estimatedFee}(
                dstChainId,
                remoteAndLocalAddresses,
                _payload,
                payable(msg.sender),
                address(0x0),
                bytes("")
            );

            unchecked {
                ++i;
            }
        }

        emit RateUpdated(rate);
    }

    /// @notice Retrieves all destination chainIds
    function getDstChainIds() public view returns (uint[] memory) {
        return dstChainIds.values();
    }

    /// @notice Returns the latest rate
    function getLatestRate() public view virtual returns (uint256) {}
}
