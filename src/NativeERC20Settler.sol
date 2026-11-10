// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {INativeERC20Settler} from './interfaces/INativeERC20Settler.sol';

import {ICommon} from 'ks-common-sc/src/interfaces/ICommon.sol';
import {CalldataDecoder} from 'ks-common-sc/src/libraries/calldata/CalldataDecoder.sol';
import {TokenHelper} from 'ks-common-sc/src/libraries/token/TokenHelper.sol';

/// @title NativeERC20Settler
/// @notice Transfers its entire balance of each given native or ERC20 token to a recipient,
/// reverting if the recipient receives less than the minimum amount of any token
contract NativeERC20Settler is INativeERC20Settler, ICommon {
  using CalldataDecoder for bytes;
  using TokenHelper for address;

  receive() external payable {}

  /// @inheritdoc INativeERC20Settler
  function ksExecute(bytes calldata data) external payable returns (bytes memory) {
    address[] calldata tokens = data.decodeAddressArray(0);
    uint256[] calldata minAmounts = data.decodeUint256Array(1);
    address recipient = data.decodeAddress(2);

    if (tokens.length != minAmounts.length) revert MismatchedArrayLengths();
    if (recipient == address(0)) revert InvalidAddress();

    uint256[] memory amounts = new uint256[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
      address token = tokens[i];
      uint256 balanceBefore = token.balanceOf(recipient);
      token.safeTransfer(recipient, token.selfBalance());

      uint256 receivedAmount = token.balanceOf(recipient) - balanceBefore;
      if (receivedAmount < minAmounts[i]) {
        revert InsufficientReceivedAmount(token, receivedAmount, minAmounts[i]);
      }
      amounts[i] = receivedAmount;
    }

    return abi.encode(amounts);
  }
}
