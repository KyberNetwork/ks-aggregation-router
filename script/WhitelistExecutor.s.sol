// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './Base.s.sol';

contract WhitelistExecutorScript is BaseRouterScript {
  address[] executorsToGrant;

  /**
   * @dev Grants EXECUTOR_ROLE on the router to every executor listed for the chain in
   * `executors.json`.
   *
   * Usage:
   * Whitelist executors on multiple chains using chain ids
   * forge script WhitelistExecutorScript \
   *   --sig "run(string[])" \
   *   "[1,137,8453]"  \
   *   --broadcast
   */
  function run(string[] memory chainIds) public multiChain(chainIds) {
    uint256 chainId = vm.getChainId();
    KSAggregationRouterV3 router = routerOf[chainId];
    if (address(router) == address(0)) {
      return;
    }

    address[] memory executors = executorsOf[chainId];

    delete executorsToGrant;

    for (uint256 i = 0; i < executors.length; i++) {
      if (!router.hasRole(EXECUTOR_ROLE, executors[i])) {
        executorsToGrant.push(executors[i]);
        console.log('grant EXECUTOR_ROLE for: ', executors[i]);
      }
    }

    if (executorsToGrant.length != 0) {
      router.batchGrantRole(EXECUTOR_ROLE, executorsToGrant);
    }
  }
}
