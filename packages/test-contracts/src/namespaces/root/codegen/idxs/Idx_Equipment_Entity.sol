// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";

// Import idx internals
import { Uint8Map, Uint8MapLib } from "@dk1a/mud-table-idxs/src/Uint8Map.sol";
import { hashIndexes, hashValues } from "@dk1a/mud-table-idxs/src/utils.sol";

import { IIdxErrors } from "@dk1a/mud-table-idxs/src/IIdxErrors.sol";

import { registerBasicIdx } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/registerBasicIdx.sol";
import { BasicIdx } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/codegen/tables/BasicIdx.sol";
import { BasicIdxUsedKeys } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/codegen/tables/BasicIdxUsedKeys.sol";
import { BasicIdx_KeyTuple } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/BasicIdx_KeyTuple.sol";

library Idx_Equipment_Entity {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Equipment", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462000000000000000000000000000045717569706d656e7400000000000000);

  uint256 constant _keyNumber = 1;
  uint256 constant _fieldNumber = 0;

  Uint8Map constant _keyIndexes = Uint8Map.wrap(0x0100000000000000000000000000000000000000000000000000000000000000);
  Uint8Map constant _fieldIndexes = Uint8Map.wrap(0x0000000000000000000000000000000000000000000000000000000000000000);

  bytes32 constant _indexesHash = 0x82ac279db26a206d9ba5a94c07ff940aea4b3bfde8820ec95f4efa0acfd0d5bc;

  function valuesHash(bytes32 entity) internal pure returns (bytes32) {
    bytes32[] memory _partialKeyTuple = new bytes32[](_keyNumber);

    _partialKeyTuple[0] = entity;

    bytes[] memory _partialValues = new bytes[](_fieldNumber);

    return hashValues(_partialKeyTuple, _partialValues);
  }

  // Should be called once in e.g. PostDeploy
  function register() internal {
    registerBasicIdx(_tableId, _keyIndexes, _fieldIndexes);
  }

  function length(bytes32 entity) internal view returns (uint256) {
    bytes32 _valuesHash = valuesHash(entity);

    return BasicIdx_KeyTuple.length(_tableId, _indexesHash, _valuesHash);
  }

  function hasKeyTuple(bytes32[] memory _keyTuple) internal view returns (bool _has, uint40 _index) {
    bytes32 _keyTupleHash = keccak256(abi.encode(_keyTuple));

    return BasicIdxUsedKeys.get(_tableId, _indexesHash, _keyTupleHash);
  }

  function has(bytes32 entity) internal view returns (bool _has, uint40 _index) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entity;

    return hasKeyTuple(_keyTuple);
  }

  /**
   * @notice Decode keys from a bytes32 array using the source table's field layout.
   */
  function decodeKeyTuple(bytes32[] memory _keyTuple) internal pure returns (bytes32 entity) {
    entity = _keyTuple[0];
  }
}
