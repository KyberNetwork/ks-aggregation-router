// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import 'ks-common-sc-script/script/Base.s.sol';
import 'src/KSAggregationRouterV3.sol';

contract BaseRouterScript is BaseScript {
  using stdJson for string;

  bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');
  bytes32 public constant GUARDIAN_ROLE = keccak256('GUARDIAN_ROLE');
  bytes32 public constant RESCUER_ROLE = keccak256('RESCUER_ROLE');

  mapping(uint256 => address) adminOf;
  mapping(uint256 => address[]) guardiansOf;
  mapping(uint256 => address[]) rescuersOf;
  mapping(uint256 => address[]) executorsOf;
  mapping(uint256 => address) permit2Of;

  mapping(uint256 => KSAggregationRouterV3) public routerOf;

  function _loadConfigs(string[] memory _chainIds) internal override {
    for (uint256 i = 0; i < _chainIds.length; i++) {
      uint256 chainId = vm.parseUint(_chainIds[i]);
      adminOf[chainId] = _readAddressByChainId('admin', chainId);
      guardiansOf[chainId] = _readAddressArrayByChainId('guardians', chainId);
      rescuersOf[chainId] = _readAddressArrayByChainId('rescuers', chainId);
      executorsOf[chainId] = _readAddressArrayByChainId('executors', chainId);
      permit2Of[chainId] = _readAddressByChainId('permit2', chainId);
      // Tolerates a chain that has not been deployed to yet, so DeployScript can bootstrap it.
      routerOf[chainId] =
        KSAggregationRouterV3(payable(_readAddressByChainIdOr('router', chainId, address(0))));
    }
  }

  /// @dev `_readAddressByChainId` with a fallback, for keys that may not exist on a chain yet.
  function _readAddressByChainIdOr(string memory key, uint256 chainId, address defaultValue)
    internal
    returns (address result)
  {
    string memory json = _getJsonString(key);
    result = json.readAddressOr(_toDotChainId(chainId), defaultValue);

    emit ReadAddress(key, result);
  }
}
