// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IKSGenericRouter} from './IKSGenericRouter.sol';

/// @title INativeERC20Settler
/// @notice Interface of {NativeERC20Settler}
interface INativeERC20Settler is IKSGenericRouter {
  /// @notice Thrown when the recipient's balance of a token increases by less than its minimum
  /// amount
  error InsufficientReceivedAmount(address token, uint256 receivedAmount, uint256 minAmount);
}
