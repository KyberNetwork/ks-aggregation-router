// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IKSGenericRouter} from './IKSGenericRouter.sol';

/// @title INativeERC20Settler
/// @notice Interface of {NativeERC20Settler}
interface INativeERC20Settler is IKSGenericRouter {
  /// @notice Thrown when the balance of a token held by this contract is below its minimum amount
  error InsufficientBalance(address token, uint256 balance, uint256 minAmount);
}
