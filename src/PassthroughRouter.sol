// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IKSAggregationExecutor} from './interfaces/IKSAggregationExecutor.sol';
import {IPassthroughRouter} from './interfaces/IPassthroughRouter.sol';

import {ICommon} from 'ks-common-sc/src/interfaces/ICommon.sol';

/// @title PassthroughRouter
/// @notice Forwards calldata and native value to the executor proxy
contract PassthroughRouter is IPassthroughRouter, ICommon {
  /// @inheritdoc IPassthroughRouter
  address public immutable EXECUTOR;

  /// @param executor The executor proxy that {ksExecute} calls
  constructor(address executor) {
    if (executor == address(0)) {
      revert InvalidAddress();
    }
    EXECUTOR = executor;
  }

  /// @inheritdoc IPassthroughRouter
  function ksExecute(bytes calldata data) external payable returns (bytes memory) {
    IKSAggregationExecutor(EXECUTOR).callBytes{value: msg.value}(data);
    return '';
  }
}
