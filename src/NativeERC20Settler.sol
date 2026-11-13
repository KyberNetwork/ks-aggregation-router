// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {INativeERC20Settler} from './interfaces/INativeERC20Settler.sol';

import {ICommon} from 'ks-common-sc/src/interfaces/ICommon.sol';
import {CalldataDecoder} from 'ks-common-sc/src/libraries/calldata/CalldataDecoder.sol';
import {TokenHelper} from 'ks-common-sc/src/libraries/token/TokenHelper.sol';

import {Address} from 'openzeppelin-contracts/contracts/utils/Address.sol';

/// @title NativeERC20Settler
/// @notice Transfers the entire balance of each given native or ERC20 token, held by itself or
/// pulled from a given address, to a recipient, or calls that address back to perform the
/// transfers, reverting if the recipient receives less than the minimum amount of any token
contract NativeERC20Settler is INativeERC20Settler, ICommon {
  using CalldataDecoder for bytes;
  using TokenHelper for address;

  receive() external payable {}

  /// @inheritdoc INativeERC20Settler
  function ksExecute(bytes calldata data) external payable returns (bytes memory) {
    address[] calldata tokens = data.decodeAddressArray(0);
    uint256[] calldata minAmounts = data.decodeUint256Array(1);
    address from = data.decodeAddress(2);
    address to = data.decodeAddress(3);
    bytes calldata callbackData = data.decodeBytes(4);

    if (tokens.length != minAmounts.length) {
      revert MismatchedArrayLengths();
    }
    if (to == address(0)) {
      revert InvalidAddress();
    }

    uint256[] memory amounts = new uint256[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
      amounts[i] = tokens[i].balanceOf(to);
    }

    if (callbackData.length != 0) {
      Address.functionCall(from, callbackData);
    } else {
      for (uint256 i = 0; i < tokens.length; i++) {
        address token = tokens[i];
        if (from == address(0) || token.isNative()) {
          token.safeTransfer(to, token.selfBalance());
        } else {
          token.safeTransferFrom(from, to, token.balanceOf(from));
        }
      }
    }

    for (uint256 i = 0; i < tokens.length; i++) {
      uint256 receivedAmount = tokens[i].balanceOf(to) - amounts[i];
      if (receivedAmount < minAmounts[i]) {
        revert InsufficientReceivedAmount(tokens[i], receivedAmount, minAmounts[i]);
      }
      amounts[i] = receivedAmount;
    }

    return abi.encode(amounts);
  }
}
