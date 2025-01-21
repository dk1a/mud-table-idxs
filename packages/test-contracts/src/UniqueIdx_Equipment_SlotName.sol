// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { Uint8Map, Uint8MapLib } from "@dk1a/mud-table-idxs/src/Uint8Map.sol";
import { registerUniqueIdx } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/registerUniqueIdx.sol";
import { UniqueIdx } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/codegen/tables/UniqueIdx.sol";
import { hashIndexes, hashValues } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/utils.sol";

import { Equipment } from "../src/codegen/tables/Equipment.sol";

// TODO this should be autogenerated similar to mud tables

library UniqueIdx_Equipment_SlotName {
  uint256 constant _keyNumber = 0;
  uint256 constant _fieldNumber = 2;

  function sourceTableId() internal pure returns (ResourceId) {
    return Equipment._tableId;
  }

  // TODO with codegen uint maps and hashes can be hardcoded for better performance
  function indexes() internal pure returns (Uint8Map, Uint8Map) {
    uint256[] memory _keyIndexesArray = new uint256[](_keyNumber);

    uint256[] memory _fieldIndexesArray = new uint256[](_fieldNumber);
    // slot
    _fieldIndexesArray[0] = 0;
    // name
    _fieldIndexesArray[1] = 2;

    return (Uint8MapLib.encode(_keyIndexesArray), Uint8MapLib.encode(_fieldIndexesArray));
  }

  function indexesHash() internal pure returns (bytes32) {
    (Uint8Map _keyIndexes, Uint8Map _fieldIndexes) = indexes();
    return hashIndexes(_keyIndexes, _fieldIndexes);
  }

  function valuesHash(bytes32 slot, string memory name) internal pure returns (bytes32) {
    bytes32[] memory _partialKeyTuple = new bytes32[](_keyNumber);

    bytes[] memory _partialValues = new bytes[](_fieldNumber);
    _partialValues[0] = abi.encodePacked(slot);
    _partialValues[1] = abi.encodePacked(name);

    return hashValues(_partialKeyTuple, _partialValues);
  }

  // Should be called once in e.g. PostDeploy
  function register() internal {
    (Uint8Map _keyIndexes, Uint8Map _fieldIndexes) = indexes();
    registerUniqueIdx(Equipment._tableId, _keyIndexes, _fieldIndexes);
  }

  function has(bytes32 slot, string memory name) internal view returns (bool) {
    bytes32 _valuesHash = valuesHash(slot, name);

    return UniqueIdx.length(sourceTableId(), indexesHash(), _valuesHash) > 0;
  }

  function getKeyTuple(bytes32 slot, string memory name) internal view returns (bytes32[] memory _keyTuple) {
    bytes32 _valuesHash = valuesHash(slot, name);

    return UniqueIdx.get(sourceTableId(), indexesHash(), _valuesHash);
  }

  function get(bytes32 slot, string memory name) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = getKeyTuple(slot, name);

    if (_keyTuple.length > 0) {
      return (_keyTuple[0]);
    }
  }
}
