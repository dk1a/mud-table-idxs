// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { EncodedLengths } from "@latticexyz/store/src/EncodedLengths.sol";

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { AbstractIdxHook } from "../../AbstractIdxHook.sol";
import { Uint8Map } from "../../Uint8Map.sol";
import { UniqueIdx } from "./codegen/tables/UniqueIdx.sol";

contract UniqueIdxHook is AbstractIdxHook {
  error UniqueIdxHook_UniqueValueDuplicate(bytes32[] keyTupleOfUniqueValue, bytes32[] keyTupleOfDuplicateValue);

  constructor(
    FieldLayout _fieldLayout,
    uint256 _keyTupleLength,
    Uint8Map _keyIndexes,
    Uint8Map _fieldIndexes,
    Uint8Map _staticIndexes,
    Uint8Map _dynamicIndexes
  ) AbstractIdxHook(_fieldLayout, _keyTupleLength, _keyIndexes, _fieldIndexes, _staticIndexes, _dynamicIndexes) {}

  function onBeforeSetRecord(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    bytes memory,
    EncodedLengths,
    bytes memory,
    FieldLayout
  ) public override {
    previousValuesHash = _getValuesHash(sourceTableId, keyTuple);
  }

  function onAfterSetRecord(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    bytes memory,
    EncodedLengths,
    bytes memory,
    FieldLayout
  ) public override {
    _updateUniqueValuesHash(sourceTableId, keyTuple);
  }

  function onBeforeSpliceStaticData(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint48,
    bytes memory
  ) public override {
    if (!_withStatic()) return;

    previousValuesHash = _getValuesHash(sourceTableId, keyTuple);
  }

  function onAfterSpliceStaticData(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint48,
    bytes memory
  ) public override {
    if (!_withStatic()) return;

    _updateUniqueValuesHash(sourceTableId, keyTuple);
  }

  function onBeforeSpliceDynamicData(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint8 dynamicFieldIndex,
    uint40,
    uint40,
    EncodedLengths,
    bytes memory
  ) public override {
    if (!_withDynamic(dynamicFieldIndex)) return;

    previousValuesHash = _getValuesHash(sourceTableId, keyTuple);
  }

  function onAfterSpliceDynamicData(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint8 dynamicFieldIndex,
    uint40,
    uint40,
    EncodedLengths,
    bytes memory
  ) public override {
    if (!_withDynamic(dynamicFieldIndex)) return;

    _updateUniqueValuesHash(sourceTableId, keyTuple);
  }

  function onBeforeDeleteRecord(ResourceId sourceTableId, bytes32[] memory keyTuple, FieldLayout) public override {
    // Get the previous valuesHash
    bytes32 valuesHash = _getValuesHash(sourceTableId, keyTuple);

    // Clear the previous valuesHash
    UniqueIdx.deleteRecord(sourceTableId, indexesHash, valuesHash);
  }

  // For onAfter hooks
  function _updateUniqueValuesHash(ResourceId sourceTableId, bytes32[] memory keyTuple) internal {
    // Get the new valuesHash
    bytes32 valuesHash = _getValuesHash(sourceTableId, keyTuple);
    bytes32[] memory previousKeyTuple = UniqueIdx.get(sourceTableId, indexesHash, valuesHash);

    if (
      previousKeyTuple.length > 0 &&
      keccak256(abi.encodePacked(previousKeyTuple)) != keccak256(abi.encodePacked(keyTuple))
    ) {
      revert UniqueIdxHook_UniqueValueDuplicate(previousKeyTuple, keyTuple);
    }

    // Clear the previous valuesHash
    UniqueIdx.deleteRecord(sourceTableId, indexesHash, previousValuesHash);

    // Set the keyTuple to the new valuesHash
    UniqueIdx.set(sourceTableId, indexesHash, valuesHash, keyTuple);
  }
}
