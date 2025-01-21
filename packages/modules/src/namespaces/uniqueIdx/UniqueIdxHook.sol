// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { StoreHook } from "@latticexyz/store/src/StoreHook.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { EncodedLengths } from "@latticexyz/store/src/EncodedLengths.sol";
import { Tables } from "@latticexyz/store/src/codegen/tables/Tables.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { Uint8Map } from "../../Uint8Map.sol";
import { UniqueIdx } from "./codegen/tables/UniqueIdx.sol";
import { hashIndexes, hashValues } from "./utils.sol";

contract UniqueIdxHook is StoreHook {
  error UniqueIdxHook_UniqueValueDuplicate(bytes32[] keyTupleOfUniqueValue, bytes32[] keyTupleOfDuplicateValue);

  FieldLayout public immutable fieldLayout;
  // Note: The provided indexes aren't validated, hook creator should do that
  Uint8Map public immutable keyIndexes;
  Uint8Map public immutable fieldIndexes;
  Uint8Map public immutable staticIndexes;
  Uint8Map public immutable dynamicIndexes;
  bytes32 public immutable indexesHash;

  // Set by onBefore hooks so that onAfter hooks have access to both current and previous value hashes
  bytes32 transient previousValuesHash;

  constructor(
    FieldLayout _fieldLayout,
    Uint8Map _keyIndexes,
    Uint8Map _fieldIndexes,
    Uint8Map _staticIndexes,
    Uint8Map _dynamicIndexes
  ) {
    fieldLayout = _fieldLayout;
    keyIndexes = _keyIndexes;
    fieldIndexes = _fieldIndexes;
    staticIndexes = _staticIndexes;
    dynamicIndexes = _dynamicIndexes;

    indexesHash = hashIndexes(keyIndexes, fieldIndexes);
  }

  function _world() internal view returns (IBaseWorld) {
    return IBaseWorld(StoreSwitch.getStoreAddress());
  }

  function _withStatic() internal view returns (bool) {
    // TODO verify that the spliced data actually corresponds to one of staticIndexes?
    // (map static indexes to byte ranges to go through)
    return staticIndexes.length() > 0;
  }

  function _withDynamic(uint8 dynamicFieldIndex) internal view returns (bool) {
    if (dynamicIndexes.length() == 0) return false;

    // Provided dynamic field index is relative to dynamic fields only - adjust it to be a global field index
    uint256 fieldIndex = dynamicFieldIndex + fieldLayout.numStaticFields();

    return _includes(dynamicIndexes, fieldIndex);
  }

  function onBeforeSetRecord(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    bytes memory,
    EncodedLengths,
    bytes memory,
    FieldLayout
  ) public override {
    previousValuesHash = _getUniqueValuesHash(sourceTableId, keyTuple);
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

    previousValuesHash = _getUniqueValuesHash(sourceTableId, keyTuple);
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

    previousValuesHash = _getUniqueValuesHash(sourceTableId, keyTuple);
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
    bytes32 valuesHash = _getUniqueValuesHash(sourceTableId, keyTuple);

    // Clear the previous valuesHash
    UniqueIdx.deleteRecord(sourceTableId, indexesHash, valuesHash);
  }

  // For onAfter hooks
  function _updateUniqueValuesHash(ResourceId sourceTableId, bytes32[] memory keyTuple) internal {
    // Get the new valuesHash
    bytes32 valuesHash = _getUniqueValuesHash(sourceTableId, keyTuple);
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

  function _getUniqueValuesHash(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple
  ) internal view returns (bytes32 valueHash) {
    bytes32[] memory partialKeyTuple = new bytes32[](keyIndexes.length());
    for (uint256 i; i < keyIndexes.length(); i++) {
      uint8 keyIndex = keyIndexes.atIndex(i);
      partialKeyTuple[i] = keyTuple[keyIndex];
    }

    bytes[] memory partialValues = new bytes[](fieldIndexes.length());
    for (uint256 i; i < fieldIndexes.length(); i++) {
      uint8 fieldIndex = fieldIndexes.atIndex(i);
      partialValues[i] = _world().getField(sourceTableId, keyTuple, fieldIndex, fieldLayout);
    }

    return hashValues(partialKeyTuple, partialValues);
  }

  function _includes(Uint8Map arr, uint256 element) internal pure returns (bool) {
    for (uint256 i; i < arr.length(); i++) {
      if (arr.atIndex(i) == element) {
        return true;
      }
    }
    return false;
  }
}
