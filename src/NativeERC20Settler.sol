// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IKSGenericRouter} from './interfaces/IKSGenericRouter.sol';
import {INativeERC20Settler} from './interfaces/INativeERC20Settler.sol';

import {ICommon} from 'ks-common-sc/src/interfaces/ICommon.sol';
import {CalldataDecoder} from 'ks-common-sc/src/libraries/calldata/CalldataDecoder.sol';
import {TokenHelper} from 'ks-common-sc/src/libraries/token/TokenHelper.sol';

/// @title NativeERC20Settler
/// @notice Transfers its entire balance of each given native or ERC20 token to a recipient,
/// reverting if any balance is below its minimum amount
contract NativeERC20Settler is INativeERC20Settler, ICommon {
  using CalldataDecoder for bytes;
  using TokenHelper for address;

  receive() external payable {}

  /**
   * @inheritdoc IKSGenericRouter
   * @dev `data` is `abi.encode(address[] tokens, uint256[] minAmounts, address recipient)`.
   * Returns `abi.encode(uint256[] amounts)`, the amount transferred for each token.
   */
  function ksExecute(bytes calldata data) external payable returns (bytes memory) {
    address[] calldata tokens = data.decodeAddressArray(0);
    uint256[] calldata minAmounts = data.decodeUint256Array(1);
    address recipient = data.decodeAddress(2);

    if (tokens.length != minAmounts.length) revert MismatchedArrayLengths();
    if (recipient == address(0)) revert InvalidAddress();

    uint256[] memory amounts = new uint256[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
      uint256 balance = tokens[i].selfBalance();
      if (balance < minAmounts[i]) {
        revert InsufficientBalance(tokens[i], balance, minAmounts[i]);
      }

      tokens[i].safeTransfer(recipient, balance);
      amounts[i] = balance;
    }

    return abi.encode(amounts);
  }
}
