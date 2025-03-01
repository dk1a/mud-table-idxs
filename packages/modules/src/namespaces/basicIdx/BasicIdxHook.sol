// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { EncodedLengths } from "@latticexyz/store/src/EncodedLengths.sol";

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { AbstractIdxHook } from "../../AbstractIdxHook.sol";
import { Uint8Map } from "../../Uint8Map.sol";
import { BasicIdx } from "./codegen/tables/BasicIdx.sol";
import { BasicIdxUsedKeys } from "./codegen/tables/BasicIdxUsedKeys.sol";
import { BasicIdx_KeyTuple } from "./BasicIdx_KeyTuple.sol";

contract BasicIdxHook is AbstractIdxHook {
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
    _removeKeyTuple(sourceTableId, previousValuesHash, keccak256(abi.encode(keyTuple)));
  }

  // For onBefore hooks
  function _updateValuesHash(ResourceId sourceTableId, bytes32[] memory keyTuple, bytes32 valuesHash) internal {
    bytes32 keyTupleHash = keccak256(abi.encode(keyTuple));

    // Compute the previous valuesHash (relies on being called in onBefore hooks)
    bytes[] memory previousPartialValues = _getPartialValues(sourceTableId, keyTuple);
    bytes32 previousValuesHash = _getValuesHash(keyTuple, previousPartialValues);

    // Skip remove+push if nothing would change, to save gas
    if (valuesHash == previousValuesHash) {
      // Initializing the record to a nullish value is a special case which should not be skipped
      // (by default tables only differentiate this state offchain, but BasicIdx allows this differentiation onchain too)
      bool has = BasicIdxUsedKeys.getHas(sourceTableId, indexesHash, keyTupleHash);
      if (has) {
        return;
      }
    }

    // Remove the keyTuple from the previous valuesHash
    _removeKeyTuple(sourceTableId, previousValuesHash, keyTupleHash);

    // Add the keyTuple to the new valuesHash
    BasicIdx_KeyTuple.push(sourceTableId, indexesHash, valuesHash, keyTuple);
    uint256 newLength = BasicIdx_KeyTuple.length(sourceTableId, indexesHash, valuesHash);
    uint40 newIndex = uint40(newLength - 1);
    BasicIdxUsedKeys.set(sourceTableId, indexesHash, keyTupleHash, true, newIndex);
  }

  function _removeKeyTuple(ResourceId sourceTableId, bytes32 valuesHash, bytes32 keyTupleHash) internal {
    (bool has, uint40 index) = BasicIdxUsedKeys.get(sourceTableId, indexesHash, keyTupleHash);

    if (has) {
      uint256 length = BasicIdx_KeyTuple.length(sourceTableId, indexesHash, valuesHash);
      if (length <= 1) {
        // Delete the record if this is the last item
        BasicIdx.deleteRecord(sourceTableId, indexesHash, valuesHash);
        BasicIdxUsedKeys.deleteRecord(sourceTableId, indexesHash, keyTupleHash);
      } else {
        // Removal is only possible via pop, so swap if necessary
        uint256 lastIndex = length - 1;
        if (index != lastIndex) {
          // Move the last item to index, swapping it with the item being removed
          bytes32[] memory keyTupleToSwap = BasicIdx_KeyTuple.getItem(
            sourceTableId,
            indexesHash,
            valuesHash,
            lastIndex,
            keyTupleLength
          );
          BasicIdx_KeyTuple.update(sourceTableId, indexesHash, valuesHash, index, keyTupleToSwap);
          BasicIdxUsedKeys.setIndex(sourceTableId, indexesHash, keccak256(abi.encode(keyTupleToSwap)), index);
        }
        // Pop the item
        BasicIdx_KeyTuple.pop(sourceTableId, indexesHash, valuesHash, keyTupleLength);
        BasicIdxUsedKeys.deleteRecord(sourceTableId, indexesHash, keyTupleHash);
      }
    }
  }
}
