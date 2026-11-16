// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IPassthroughRouter
/// @notice Interface of {PassthroughRouter}
interface IPassthroughRouter {
  /// @notice Returns the executor proxy that {ksExecute} calls
  function EXECUTOR() external view returns (address);

  /**
   * @notice Calls `callBytes` on the executor proxy with `data` and the native value sent
   * @dev The input tokens must already be held by the executor proxy
   * @param data The data passed to the executor proxy's `callBytes`
   * @return Empty bytes
   */
  function ksExecute(bytes calldata data) external payable returns (bytes memory);
}
