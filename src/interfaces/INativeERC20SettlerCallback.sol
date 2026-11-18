// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title INativeERC20SettlerCallback
/// @notice Interface of the callback that {NativeERC20Settler} calls on `from`
interface INativeERC20SettlerCallback {
  /**
   * @notice Called by {NativeERC20Settler} in place of its own transfers, to transfer the tokens
   * to the recipient
   * @param tokens The tokens to transfer, where native tokens are given as
   * `TokenHelper.NATIVE_ADDRESS` or `address(0)`
   * @param minAmounts The minimum amount of each token that the recipient must receive
   * @param callbackData The `callbackData` field of the data of {INativeERC20Settler-solverCall}
   */
  function nativeERC20SettlerCallback(
    address[] calldata tokens,
    uint256[] calldata minAmounts,
    bytes calldata callbackData
  ) external;
}
