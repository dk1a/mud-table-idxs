// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { StoreHook } from "@latticexyz/store/src/StoreHook.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { Uint8Map } from "./Uint8Map.sol";
import { hashIndexes, hashValues } from "./utils.sol";

// Common logic used by idx hooks
abstract contract AbstractIdxHook is StoreHook {
  FieldLayout public immutable fieldLayout;
  uint256 public immutable keyTupleLength;

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
    uint256 _keyTupleLength,
    Uint8Map _keyIndexes,
    Uint8Map _fieldIndexes,
    Uint8Map _staticIndexes,
    Uint8Map _dynamicIndexes
  ) {
    fieldLayout = _fieldLayout;
    keyTupleLength = _keyTupleLength;
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

  function _getValuesHash(
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
