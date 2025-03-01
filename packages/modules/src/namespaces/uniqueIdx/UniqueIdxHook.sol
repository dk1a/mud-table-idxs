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
    bytes memory staticData,
    EncodedLengths encodedLengths,
    bytes memory dynamicData,
    FieldLayout
  ) public override {
    bytes[] memory partialValues = _getPartialValuesSetRecord(staticData, encodedLengths, dynamicData);
    bytes32 valuesHash = _getValuesHash(keyTuple, partialValues);

    _updateValuesHash(sourceTableId, keyTuple, valuesHash);
  }

  function onBeforeSpliceStaticData(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint48 start,
    bytes memory data
  ) public override {
    if (!_withStatic(start)) return;

    bytes[] memory partialValues = _getPartialValuesSpliceStatic(sourceTableId, keyTuple, start, data);
    bytes32 valuesHash = _getValuesHash(keyTuple, partialValues);

    _updateValuesHash(sourceTableId, keyTuple, valuesHash);
  }

  function onBeforeSpliceDynamicData(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint8 dynamicFieldIndex,
    uint40 startWithinField,
    uint40 deleteCount,
    EncodedLengths encodedLengths,
    bytes memory data
  ) public override {
    if (!_withDynamic(dynamicFieldIndex)) return;

    bytes[] memory partialValues = _getPartialValuesSpliceDynamic(
      sourceTableId,
      keyTuple,
      dynamicFieldIndex,
      startWithinField,
      deleteCount,
      encodedLengths,
      data
    );
    bytes32 valuesHash = _getValuesHash(keyTuple, partialValues);

    _updateValuesHash(sourceTableId, keyTuple, valuesHash);
  }

  function onBeforeDeleteRecord(ResourceId sourceTableId, bytes32[] memory keyTuple, FieldLayout) public override {
    // Compute the previous valuesHash
    bytes[] memory previousPartialValues = _getPartialValues(sourceTableId, keyTuple);
    bytes32 previousValuesHash = _getValuesHash(keyTuple, previousPartialValues);

    // Clear the previous valuesHash
    UniqueIdx.deleteRecord(sourceTableId, indexesHash, previousValuesHash);
  }

  // For onBefore hooks only
  function _updateValuesHash(ResourceId sourceTableId, bytes32[] memory keyTuple, bytes32 valuesHash) internal {
    bytes32[] memory previousKeyTuple = UniqueIdx.get(sourceTableId, indexesHash, valuesHash);

    if (
      previousKeyTuple.length > 0 &&
      keccak256(abi.encodePacked(previousKeyTuple)) != keccak256(abi.encodePacked(keyTuple))
    ) {
      revert UniqueIdxHook_UniqueValueDuplicate(previousKeyTuple, keyTuple);
    }

    // Compute the previous valuesHash (relies on being called in onBefore hooks)
    bytes[] memory previousPartialValues = _getPartialValues(sourceTableId, keyTuple);
    bytes32 previousValuesHash = _getValuesHash(keyTuple, previousPartialValues);

    // Clear the previous valuesHash
    UniqueIdx.deleteRecord(sourceTableId, indexesHash, previousValuesHash);

    // Set the keyTuple to the new valuesHash
    UniqueIdx.set(sourceTableId, indexesHash, valuesHash, keyTuple);
  }
}
