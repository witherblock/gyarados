// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ILayerZeroReceiver} from "contracts/interfaces/ILayerZeroReceiver.sol";

import {IBasicRateProvider} from "contracts/interfaces/IBasicRateProvider.sol";

/// @title Cross chain rate receiver
/// @author witherblock
/// @notice Receives a rate from a provider contract on a different chain than the one this contract is deployed on
/// @dev Powered using LayerZero
abstract contract CrossChainRateReceiver is ILayerZeroReceiver, Ownable {
    /// @notice Last rate validated rate
    uint256 public rate;

    /// @notice The next rate to be applied
    uint256 public pendingRate;

    /// @notice When the next rate can be validated
    uint256 public pendingRateApplicationTime;

    /// @notice How long the dispute window should be.  This is also the min lag between receiving a rate and applying.
    uint256 disputeWindowSeconds;

    /// @notice How long to wait after the dispute period before allowing a new rate.
    uint256 public applyRateBufferTime;

    /// @notice Last time rate was updated
    uint256 public lastUpdated;

    /// @notice Max time to elapse since receiving the last rate before emergency mode can be enabled.
    uint256 public immutable maxTimeBetweenUpdates;

    /// @notice Source chainId
    uint16 public srcChainId;

    /// @notice Rate Provider address
    address public rateProvider;

    /// @notice LayerZero endpoint address
    address public layerZeroEndpoint;

    /// @notice Information of which token and base token rate is being provided
    RateInfo public rateInfo;

    // EMERGENCY MODE
    // The storage below is setup to allow an admin to fix the rate provider should the current sender(lz) fail.

    /// @notice Emergency Mode means no new rates are being received and admin has privilege to re-wire.
    bool public emergencyMode;

    /// @notice If no new rates is set, rate will not allowed to be changed by any incomming data.
    bool public noNewRates;

    /// @notice If set, getRate will call getRate() on this contract to return a rate instead of using LZ.
    address public passthroughRateProvider;

    struct RateInfo {
        string tokenSymbol;
        string baseTokenSymbol;
    }

    /// @notice Emitted when rate is updated
    /// @param newRate the rate that was updated
    event RateUpdated(uint256 newRate);

    /// @notice Emitted when RateProvider is updated
    /// @param newRateProvider the RateProvider address that was updated
    event RateProviderUpdated(address newRateProvider);

    /// @notice Emitted when the source chainId is updated
    /// @param newSrcChainId the source chainId that was updated
    event SrcChainIdUpdated(uint16 newSrcChainId);

    /// @notice Emitted when LayerZero Endpoint is updated
    /// @param newLayerZeroEndpoint the LayerZero Endpoint address that was updated
    event LayerZeroEndpointUpdated(address newLayerZeroEndpoint);

    // @notice An error to throw a string log message
    error Log(sting message);


    /// @notice Updates the LayerZero Endpoint address
    /// @dev Can only be called by owner
    /// @param _layerZeroEndpoint the new layer zero endpoint address
    function updateLayerZeroEndpoint(
        address _layerZeroEndpoint
    ) external onlyOwner onlyEmergencyMode {
        layerZeroEndpoint = _layerZeroEndpoint;

        emit LayerZeroEndpointUpdated(_layerZeroEndpoint);
    }

    /// @notice Updates the RateProvider address
    /// @dev Can only be called by owner
    /// @param _rateProvider the new rate provider address
    function updateRateProvider(address _rateProvider) external onlyOwner onlyEmergencyMode {
        rateProvider = _rateProvider;
        emit RateProviderUpdated(_rateProvider);
    }

    /// @notice Updates the source chainId
    /// @dev Can only be called by owner
    /// @param _srcChainId the source chainId
    function updateSrcChainId(uint16 _srcChainId) external onlyOwner onlyEmergencyMode {
        srcChainId = _srcChainId;
        emit SrcChainIdUpdated(_srcChainId);
    }

    // EMERGENCY MODE
    // The logic below is setup to allow an admin to fix the rate provider should the current sender(lz) fail.

    /// @notice Enable Emergency Mode preventing new rates from being received and allowing more admin privilege.
    /// @dev Can only be called by owner and only after maxSecondsBetweenUpdates has elapsed since the last update.
    function _enableEmergencyMode() onlyOwner internal {
        if (!lastUpdated + maxTimeBetweenUpdates > block.timestamp) {
            revert emergencyModeDenied();
        }
        emergencyMode = true;
        emit EmergencyModeEnabled();
    }


    function proposeRate(uint256 _rate) onlyEmergencyMode onlyOwner { // maybe good to allow a keeper address here
        _setNewRate(_rate);
    }

    function _setNewRate(uint256 _rate) ratesNotDisabled internal {
        if (pendingRate && pendingRateApplicationTime < block.timestamp + applyRateBufferTime){
            revert newRateTooSoon(pendingRateApplicationTime, block.timestamp + applyRateBufferTime);
        }
        pendingRate = _rate;
        pendingRateApplicationTime = block.timestamp + disputeWindowSeconds;
        emit RateProposed(_rate, block.timestamp + disputeWindowSeconds);
    }


    function registerBadRate() external {
        /// asert rate is bad report comes from right place/uma stuff
        pendingRateApplicationTime = 0; // cancel update
        emergencyMode = true;
        emit EmergencyModeEnabled();
    }

    function setPassthroughRateProvider(address rateProvider) onlyOwner onlyEmergencyMode external {
        emit PassthroughRateProviderSet(passthroughRateProvider, rateProvider);
        passthroughRateProvider = rateProvider;
    }


    function applyPendingRate() external  {
        uint256 readyTime = pendingRateApplicationTime;
        if (!readyTime) {
            return;
        }
        if (readyTime < block.timestamp) {
            /// Need to figure out how to work Uma in here
            rate = pendingRate;
            pendingRateApplicationTime = 0;
        }
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
        require(
            msg.sender == layerZeroEndpoint,
            Log("Sender should be lz endpoint")
        );

        address srcAddress;
        assembly {
            srcAddress := mload(add(_srcAddress, 20))
        }

        require(_srcChainId == srcChainId, Log("Src chainId must be correct"));
        require(srcAddress == rateProvider, Log("Src address must be provider"));
        require(!emergencyMode, Log("No new rates in Emergency Mode"));

        uint _rate = abi.decode(_payload, (uint));

        _setNewRate(_rate);
    }

    /// @notice Gets the last stored rate in the contract
    /// @dev If passthrough is set will use that instead of local rate
    function getRate() external view returns (uint256) {
        address passthrough = passthroughRateProvider;
        if (passthrough) {
            try IBasicRateProvider(passthrough).getRate() returns (uint256 passthroughRate) {
                return passthroughRate;
            } catch {
                emit PassthroughCallFailed(passthrough);
                return rate;
            }
        }
        return rate;
    }

    modifier onlyEmergencyMode() {
        if (!emergencyMode) {
            revert OnlyEmergencyMode();
        }
        _;
        }
}
