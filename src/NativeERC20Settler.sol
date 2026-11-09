// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IKSGenericRouter} from './interfaces/IKSGenericRouter.sol';
import {INativeERC20Settler} from './interfaces/INativeERC20Settler.sol';

import {Common} from 'ks-common-sc/src/base/Common.sol';
import {TokenHelper} from 'ks-common-sc/src/libraries/token/TokenHelper.sol';

/// @title NativeERC20Settler
/// @notice Transfers its entire balance of each given native or ERC20 token to a recipient,
/// reverting if any balance is below its minimum amount
contract NativeERC20Settler is INativeERC20Settler, Common {
  using TokenHelper for address;

  receive() external payable {}

  /**
   * @inheritdoc IKSGenericRouter
   * @dev `data` is `abi.encode(address[] tokens, uint256[] minAmounts, address recipient)`.
   * Returns `abi.encode(uint256[] amounts)`, the amount transferred for each token.
   */
  function ksExecute(bytes calldata data) external payable returns (bytes memory) {
    (address[] memory tokens, uint256[] memory minAmounts, address recipient) =
      abi.decode(data, (address[], uint256[], address));

    return abi.encode(_settle(tokens, minAmounts, recipient));
  }

  /// @notice Transfers the entire balance of each token to the recipient after checking its minimum.
  function _settle(address[] memory tokens, uint256[] memory minAmounts, address recipient)
    internal
    checkLengths(tokens.length, minAmounts.length)
    checkAddress(recipient)
    returns (uint256[] memory amounts)
  {
    amounts = new uint256[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
      uint256 balance = tokens[i].selfBalance();
      require(balance >= minAmounts[i], InsufficientBalance(tokens[i], balance, minAmounts[i]));

      tokens[i].safeTransfer(recipient, balance);
      amounts[i] = balance;
    }
  }
}
