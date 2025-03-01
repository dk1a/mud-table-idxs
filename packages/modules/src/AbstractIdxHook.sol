// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreHook } from "@latticexyz/store/src/StoreHook.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Slice, SliceLib } from "@latticexyz/store/src/Slice.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { EncodedLengths } from "@latticexyz/store/src/EncodedLengths.sol";
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

  function _withStatic(uint48 start) internal view returns (bool) {
    // If none or all static fields are indexed, then the more specific checks can be skipped
    if (staticIndexes.length() == 0) return false;
    if (staticIndexes.length() == fieldLayout.numStaticFields()) return true;

    uint256[] memory staticFieldOffsets = _getStaticFieldOffsets();

    for (uint256 i; i < staticIndexes.length(); i++) {
      uint8 fieldIndex = fieldIndexes.atIndex(i);
      uint256 fieldStart = staticFieldOffsets[fieldIndex];
      uint256 fieldEnd = fieldStart + fieldLayout.atIndex(fieldIndex);

      if (start >= fieldStart && start < fieldEnd) return true;
    }
    return false;
  }

  function _withDynamic(uint8 dynamicFieldIndex) internal view returns (bool) {
    if (dynamicIndexes.length() == 0) return false;

    // Provided dynamic field index is relative to dynamic fields only - adjust it to be a global field index
    uint256 fieldIndex = dynamicFieldIndex + fieldLayout.numStaticFields();

    return _includes(dynamicIndexes, fieldIndex);
  }

  function _getValuesHash(
    bytes32[] memory keyTuple,
    bytes[] memory partialValues
  ) internal view returns (bytes32 valueHash) {
    bytes32[] memory partialKeyTuple = new bytes32[](keyIndexes.length());
    for (uint256 i; i < keyIndexes.length(); i++) {
      uint8 keyIndex = keyIndexes.atIndex(i);
      partialKeyTuple[i] = keyTuple[keyIndex];
    }

    return hashValues(partialKeyTuple, partialValues);
  }

  function _getPartialValues(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple
  ) internal view returns (bytes[] memory partialValues) {
    partialValues = new bytes[](fieldIndexes.length());
    for (uint256 i; i < fieldIndexes.length(); i++) {
      uint8 fieldIndex = fieldIndexes.atIndex(i);
      partialValues[i] = _world().getField(sourceTableId, keyTuple, fieldIndex, fieldLayout);
    }
  }

  function _getPartialValuesSetRecord(
    bytes memory staticData,
    EncodedLengths encodedLengths,
    bytes memory dynamicData
  ) internal view returns (bytes[] memory partialValues) {
    partialValues = new bytes[](fieldIndexes.length());

    if (staticIndexes.length() > 0) {
      uint256[] memory staticFieldOffsets = _getStaticFieldOffsets();
      for (uint256 i; i < staticIndexes.length(); i++) {
        uint8 fieldIndex = staticIndexes.atIndex(i);
        uint256 fieldOffset = staticFieldOffsets[fieldIndex];
        Slice fieldSlice = SliceLib.getSubslice(staticData, fieldOffset, fieldOffset + fieldLayout.atIndex(fieldIndex));
        partialValues[i] = fieldSlice.toBytes();
      }
    }

    if (dynamicIndexes.length() > 0) {
      uint256[] memory dynamicFieldOffsets = _getDynamicFieldOffsets(encodedLengths);
      for (uint256 i = staticIndexes.length(); i < fieldIndexes.length(); i++) {
        uint8 dynamicFieldIndex = uint8(fieldIndexes.atIndex(i) - fieldLayout.numStaticFields());
        uint256 fieldOffset = dynamicFieldOffsets[dynamicFieldIndex];
        Slice fieldSlice = SliceLib.getSubslice(
          dynamicData,
          fieldOffset,
          fieldOffset + encodedLengths.atIndex(dynamicFieldIndex)
        );
        partialValues[i] = fieldSlice.toBytes();
      }
    }
  }

  function _getPartialValuesSpliceStatic(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint48 start,
    bytes memory data
  ) internal view returns (bytes[] memory partialValues) {
    uint256[] memory staticFieldOffsets = _getStaticFieldOffsets();

    partialValues = new bytes[](fieldIndexes.length());
    for (uint256 i; i < fieldIndexes.length(); i++) {
      uint8 fieldIndex = fieldIndexes.atIndex(i);
      partialValues[i] = _world().getField(sourceTableId, keyTuple, fieldIndex, fieldLayout);

      // If this is a static field
      if (fieldIndex < fieldLayout.numStaticFields()) {
        uint256 fieldStart = staticFieldOffsets[fieldIndex];
        uint256 fieldEnd = fieldStart + fieldLayout.atIndex(fieldIndex);

        // And it is being spliced
        if (start < fieldEnd) {
          // These complications are necessary because static field splices do not have to be aligned to whole fields
          _partialDataCopyUsingFullRecordOffsets(
            data,
            start,
            start + data.length,
            partialValues[i],
            fieldStart,
            fieldEnd
          );
        }
      }
    }
  }

  // TODO this is kinda confusing, try to refactor it simpler
  /**
   * @dev Copy between partial blobs using indexes relative to the full record
   * This means that in storage `inputData` starts at `inputStart`, and `outputData` starts at `outputStart`
   * And input should receive the portion of output that would intersect it in storage
   */
  function _partialDataCopyUsingFullRecordOffsets(
    bytes memory inputData,
    uint256 inputStart,
    uint256 inputEnd,
    bytes memory outputData,
    uint256 outputStart,
    uint256 outputEnd
  ) internal pure {
    uint256 inputSubsliceStart = _max(inputStart, outputStart) - inputStart;
    uint256 inputSubsliceEnd = _min(inputEnd, outputEnd) - inputStart;
    Slice inputSubslice = SliceLib.getSubslice(inputData, inputSubsliceStart, inputSubsliceEnd);

    uint256 outputSubsliceStart = _max(inputStart, outputStart) - outputStart;
    uint256 outputSubsliceEnd = _min(inputEnd, outputEnd) - outputStart;
    Slice outputSubslice = SliceLib.getSubslice(outputData, outputSubsliceStart, outputSubsliceEnd);

    Memory.copy(inputSubslice.pointer(), outputSubslice.pointer(), inputSubslice.length());
  }

  function _getPartialValuesSpliceDynamic(
    ResourceId sourceTableId,
    bytes32[] memory keyTuple,
    uint8 dynamicFieldIndex,
    uint40 startWithinField,
    uint40 deleteCount,
    EncodedLengths,
    bytes memory data
  ) internal view returns (bytes[] memory partialValues) {
    // Get the absolute field index (the provided one is relative to the start of the dynamic fields)
    uint256 splicedFieldIndex = fieldLayout.numStaticFields() + dynamicFieldIndex;

    partialValues = new bytes[](fieldIndexes.length());
    for (uint256 i; i < fieldIndexes.length(); i++) {
      uint8 fieldIndex = fieldIndexes.atIndex(i);
      partialValues[i] = _world().getField(sourceTableId, keyTuple, fieldIndex, fieldLayout);

      // If this is the spliced dynamic field
      if (fieldIndex == splicedFieldIndex) {
        uint256 previousFieldLength = partialValues[i].length;
        uint256 updatedFieldLength = previousFieldLength - deleteCount + data.length;

        if (updatedFieldLength < previousFieldLength) {
          // Change the blob length directly within memory
          // (memory safe because this can only reduce the length, whereas increasing it would have caused potential collisions)
          bytes memory partialValue = partialValues[i];
          /// @solidity memory-safe-assembly
          assembly {
            mstore(partialValue, updatedFieldLength)
          }
        } else if (updatedFieldLength > previousFieldLength) {
          // Slice with the previous memory pointer, to be copied
          Slice inputSubslice = SliceLib.fromBytes(partialValues[i]);
          // Create a new memory pointer
          partialValues[i] = new bytes(updatedFieldLength);
          // Slice with the new memory pointer
          Slice outputSubslice = SliceLib.fromBytes(partialValues[i]);
          // Copy the previous slice to the new one
          Memory.copy(inputSubslice.pointer(), outputSubslice.pointer(), previousFieldLength);
        }

        if (data.length > 0) {
          // Copy the input (data being changed) to the output (relevant subslice of the dynamic field)
          Slice inputSubslice = SliceLib.fromBytes(data);
          Slice outputSubslice = SliceLib.getSubslice(partialValues[i], startWithinField);

          Memory.copy(inputSubslice.pointer(), outputSubslice.pointer(), inputSubslice.length());
        }
      }
    }
  }

  function _getStaticFieldOffsets() internal view returns (uint256[] memory staticFieldOffsets) {
    uint256 numStaticFields = fieldLayout.numStaticFields();
    staticFieldOffsets = new uint256[](numStaticFields);

    uint256 offset = 0;
    for (uint256 i; i < numStaticFields; i++) {
      staticFieldOffsets[i] = offset;
      offset += fieldLayout.atIndex(i);
    }
  }

  function _getDynamicFieldOffsets(
    EncodedLengths encodedLengths
  ) internal view returns (uint256[] memory dynamicFieldOffsets) {
    uint256 numDynamicFields = fieldLayout.numDynamicFields();
    dynamicFieldOffsets = new uint256[](numDynamicFields);

    uint256 offset = 0;
    for (uint8 i; i < numDynamicFields; i++) {
      dynamicFieldOffsets[i] = offset;
      offset += encodedLengths.atIndex(i);
    }
  }

  function _includes(Uint8Map arr, uint256 element) internal pure returns (bool) {
    for (uint256 i; i < arr.length(); i++) {
      if (arr.atIndex(i) == element) {
        return true;
      }
    }
    return false;
  }

  function _min(uint256 a, uint256 b) private pure returns (uint256) {
    if (a <= b) {
      return a;
    } else {
      return b;
    }
  }

  function _max(uint256 a, uint256 b) private pure returns (uint256) {
    if (a >= b) {
      return a;
    } else {
      return b;
    }
  }
}
