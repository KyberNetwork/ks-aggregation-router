// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title INativeERC20Settler
/// @notice Interface of {NativeERC20Settler}
interface INativeERC20Settler {
  /// @notice Thrown when the recipient's balance of a token increases by less than its minimum
  /// amount
  error InsufficientReceivedAmount(address token, uint256 receivedAmount, uint256 minAmount);

  /**
   * @notice Transfers the entire balance of each token to a recipient, reverting if the
   * recipient's balance of any token increases by less than its minimum amount
   * @param data `abi.encode(address[] tokens, uint256[] minAmounts, address recipient)`, where
   * native tokens are given as `TokenHelper.NATIVE_ADDRESS` or `address(0)`
   * @return `abi.encode(uint256[] amounts)`, the increase in the recipient's balance of each token
   */
  function ksExecute(bytes calldata data) external payable returns (bytes memory);
}
