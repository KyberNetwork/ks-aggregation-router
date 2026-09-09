// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './Base.s.sol';

contract PauseScript is BaseRouterScript {
  /**
   * @dev Pauses or unpauses the router on specified chains
   *
   * pause() requires GUARDIAN_ROLE or the default admin, unpause() requires the default admin.
   *
   * Usage:
   * Pause on multiple chains using chain ids
   * forge script PauseScript \
   *   --sig "run(string[],bool)" \
   *   "[1,137,8453]"  \
   *   true \
   *   --broadcast
   */
  function run(string[] memory chainIds, bool isPause) public multiChain(chainIds) {
    KSAggregationRouterV3 router = routerOf[vm.getChainId()];
    if (address(router) == address(0) || router.paused() == isPause) {
      return;
    }

    if (isPause) {
      router.pause();
      console.log('paused router: ', address(router));
    } else {
      router.unpause();
      console.log('unpaused router: ', address(router));
    }
  }
}
