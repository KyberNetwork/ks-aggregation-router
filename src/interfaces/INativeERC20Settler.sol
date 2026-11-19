// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title INativeERC20Settler
/// @notice Interface of {NativeERC20Settler}
interface INativeERC20Settler {
  /// @notice Thrown when the balance of `to` in a token increases by less than its minimum amount
  error InsufficientReceivedAmount(address token, uint256 receivedAmount, uint256 minAmount);

  /**
   * @notice Called by the allowance hub with an owner call. Transfers the entire balance of each
   * token to `to`, or calls `from` back to transfer the tokens, reverting if the balance of `to` in
   * any token increases by less than its minimum amount
   * @dev When `callbackData` is non-empty, this contract calls
   * {INativeERC20SettlerCallback-nativeERC20SettlerCallback} on `from` with `tokens`, `minAmounts`
   * and `callbackData` in place of any transfer of its own, and `from` must be a contract.
   * Otherwise, when `from` is non-zero, each ERC20 token is transferred with `transferFrom` from
   * `from`, in the amount of its entire balance. Any caller can transfer from any address that has
   * approved this contract, so an approval must be used in the transaction that grants it. Native
   * tokens are always transferred from this contract's native balance.
   * @param ownerData The data signed by the owner, `abi.encode(address[] tokens,
   * uint256[] minAmounts, address from, address to, bytes callbackData)`, where native tokens are
   * given as `TokenHelper.NATIVE_ADDRESS` or `address(0)` and a zero `from` transfers this
   * contract's own balances
   * @param solverData The data chosen by the solver, which is ignored
   * @return `abi.encode(uint256[] amounts)`, the increase in the balance of `to` in each token
   */
  function execute(bytes calldata ownerData, bytes calldata solverData)
    external
    payable
    returns (bytes memory);
}
