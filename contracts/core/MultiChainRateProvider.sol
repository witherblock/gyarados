// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {ILayerZeroEndpoint} from "../interfaces/ILayerZeroEndpoint.sol";

/// @title Multi chain rate provider
/// @author witherblock
/// @notice Provides a rate to a multiple receiver contracts on a different chain than the one this contract is deployed on
/// @dev Powered using LayerZero
abstract contract MultiChainRateProvider is Ownable, ReentrancyGuard {
    /// @notice Last rate updated on the provider
    uint256 public rate;

    /// @notice Last time rate was updated
    uint256 public lastUpdated;

    /// @notice LayerZero endpoint address
    address public layerZeroEndpoint;

    /// @notice Information of which token and base token rate is being provided
    RateInfo public rateInfo;

    /// @notice Rate receivers
    RateReceiver[] public rateReceivers;

    struct RateReceiver {
        uint16 _chainId;
        address _contract;
    }

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

    // /// @notice Emitted when a destination chainId is added
    // /// @param dstChainId the destination chainId that was added
    // event DstChainIdAdded(uint dstChainId);

    // /// @notice Emitted when a destination chainId is removed
    // /// @param dstChainId the destination chainId that was remove
    // event DstChainIdRemoved(uint dstChainId);

    /// @notice Updates the LayerZero Endpoint address
    /// @dev Can only be called by owner
    /// @param _layerZeroEndpoint the new layer zero endpoint address
    function updateLayerZeroEndpoint(
        address _layerZeroEndpoint
    ) external onlyOwner {
        layerZeroEndpoint = _layerZeroEndpoint;

        emit LayerZeroEndpointUpdated(_layerZeroEndpoint);
    }

    /// @notice Adds a destination chainId
    /// @dev Can only be called by owner
    /// @param _chainId rate receiver chainId
    /// @param _contract rate receiver address
    function addRateReceiver(
        uint16 _chainId,
        address _contract
    ) external onlyOwner {
        rateReceivers.push(
            RateReceiver({_chainId: _chainId, _contract: _contract})
        );

        // emit DstChainIdAdded(_dstChainId);
    }

    /// @notice Removes a destination chainId
    /// @dev Can only be called by owner
    /// @param _index the destination chainId
    function removeRateReceiver(uint _index) external onlyOwner {
        uint rateReceiversLength = rateReceivers.length;

        RateReceiver memory lastValue = rateReceivers[rateReceiversLength - 1];

        rateReceivers[_index] = lastValue;

        rateReceivers.pop();

        // emit DstChainIdAdded(_dstChainId);
    }

    /// @notice Updates rate in this contract and on the receivers
    /// @dev This function is set to payable to pay for gas on execute lzReceive (on the receiver contract)
    /// on the destination chain. To compute the correct value to send check here - https://layerzero.gitbook.io/docs/evm-guides/code-examples/estimating-message-fees
    function updateRate() external payable nonReentrant {
        uint256 latestRate = getLatestRate();

        rate = latestRate;

        lastUpdated = block.timestamp;

        bytes memory _payload = abi.encode(latestRate);

        uint rateReceiversLength = rateReceivers.length;

        for (uint i; i < rateReceiversLength; ) {
            uint16 dstChainId = uint16(rateReceivers[i]._chainId);

            bytes memory remoteAndLocalAddresses = abi.encodePacked(
                rateReceivers[i]._contract,
                address(this)
            );

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

    function estimateFees(
        uint16 dstChainId
    ) external view returns (uint estimatedFee) {
        uint256 latestRate = getLatestRate();

        bytes memory _payload = abi.encode(latestRate);

        (estimatedFee, ) = ILayerZeroEndpoint(layerZeroEndpoint).estimateFees(
            dstChainId,
            address(this),
            _payload,
            false,
            bytes("")
        );
    }

    function estimateTotalFee() external view returns (uint totalFee) {
        uint256 latestRate = getLatestRate();

        bytes memory _payload = abi.encode(latestRate);

        uint rateReceiversLength = rateReceivers.length;

        for (uint i; i < rateReceiversLength; ) {
            uint16 dstChainId = uint16(rateReceivers[i]._chainId);

            (uint estimatedFee, ) = ILayerZeroEndpoint(layerZeroEndpoint)
                .estimateFees(
                    dstChainId,
                    address(this),
                    _payload,
                    false,
                    bytes("")
                );

            totalFee += estimatedFee;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns the latest rate
    function getLatestRate() public view virtual returns (uint256) {}
}
