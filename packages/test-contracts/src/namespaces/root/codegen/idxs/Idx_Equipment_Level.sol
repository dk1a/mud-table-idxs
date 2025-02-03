// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";

// Import idx internals
import { Uint8Map, Uint8MapLib } from "@dk1a/mud-table-idxs/src/Uint8Map.sol";
import { hashIndexes, hashValues } from "@dk1a/mud-table-idxs/src/utils.sol";

import { registerBasicIdx } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/registerBasicIdx.sol";
import { BasicIdx } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/codegen/tables/BasicIdx.sol";
import { BasicIdxUsedKeys } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/codegen/tables/BasicIdxUsedKeys.sol";
import { BasicIdx_KeyTuple } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/BasicIdx_KeyTuple.sol";

library Idx_Equipment_Level {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Equipment", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462000000000000000000000000000045717569706d656e7400000000000000);

  uint256 constant _keyNumber = 0;
  uint256 constant _fieldNumber = 1;

  Uint8Map constant _keyIndexes = Uint8Map.wrap(0x0000000000000000000000000000000000000000000000000000000000000000);
  Uint8Map constant _fieldIndexes = Uint8Map.wrap(0x0101000000000000000000000000000000000000000000000000000000000000);

  bytes32 constant _indexesHash = 0xa02cae05650623e0606402dda8c041b25ec31166ce1821df48396b91c98d4b6b;

  function valuesHash(uint32 level) internal pure returns (bytes32) {
    bytes32[] memory _partialKeyTuple = new bytes32[](_keyNumber);

    bytes[] memory _partialValues = new bytes[](_fieldNumber);

    _partialValues[0] = abi.encodePacked((level));

    return hashValues(_partialKeyTuple, _partialValues);
  }

  // Should be called once in e.g. PostDeploy
  function register() internal {
    registerBasicIdx(_tableId, _keyIndexes, _fieldIndexes);
  }

  function length(uint32 level) internal view returns (uint256) {
    bytes32 _valuesHash = valuesHash(level);

    return BasicIdx_KeyTuple.length(_tableId, _indexesHash, _valuesHash);
  }

  function hasKeyTuple(uint32 level, bytes32[] memory _keyTuple) internal view returns (bool _has, uint40 _index) {
    bytes32 _valuesHash = valuesHash(level);
    bytes32 _keyTupleHash = keccak256(abi.encode(_keyTuple));

    return BasicIdxUsedKeys.get(_tableId, _indexesHash, _valuesHash, _keyTupleHash);
  }

  function has(uint32 level, bytes32 entity) internal view returns (bool _has, uint40 _index) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entity;

    return hasKeyTuple(level, _keyTuple);
  }

  function getKeyTuple(uint32 level, uint256 _index) internal view returns (bytes32[] memory _keyTuple) {
    bytes32 _valuesHash = valuesHash(level);

    return BasicIdx_KeyTuple.getItem(_tableId, _indexesHash, _valuesHash, _index, 1);
  }

  function get(uint32 level, uint256 _index) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = getKeyTuple(level, _index);

    entity = _keyTuple[0];
  }

  /**
   * @notice Decode keys from a bytes32 array using the source table's field layout.
   */
  function decodeKeyTuple(bytes32[] memory _keyTuple) internal pure returns (bytes32 entity) {
    entity = _keyTuple[0];
  }
}
