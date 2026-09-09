// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './Base.s.sol';

contract DeployScript is BaseRouterScript {
  string salt = '';

  /**
   * @dev Deploys KSAggregationRouterV3 to specified chains
   *
   * Usage:
   * Deploy to multiple chains using chain ids
   * forge script DeployScript \
   *   --sig "run(string[])" \
   *   "[1,137,8453]" \
   *   --broadcast
   */
  function run(string[] memory chainIds) public multiChain(chainIds) {
    if (bytes(salt).length == 0) {
      revert('salt is required');
    }
    string memory contractSalt = string.concat('KSAggregationRouterV3_', salt);

    uint256 chainId = vm.getChainId();
    bytes memory creationCode = abi.encodePacked(
      type(KSAggregationRouterV3).creationCode,
      abi.encode(
        adminOf[chainId],
        guardiansOf[chainId],
        rescuersOf[chainId],
        executorsOf[chainId],
        permit2Of[chainId]
      )
    );

    (address router,) = _createXDeploy(keccak256(abi.encodePacked(contractSalt)), creationCode);
    if (vm.isContext(VmSafe.ForgeContext.ScriptBroadcast)) {
      _writeAddress('router', router);
    }
  }
}
