// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";

import { ResourceId, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";

import { Uint8Map, Uint8MapLib } from "./Uint8Map.sol";
import { hashIndexes } from "./utils.sol";

abstract contract IdxRegistrationSystemAbstract is System {
  using WorldResourceIdInstance for ResourceId;

  error IdxRegistrationSystem_IdxAlreadyExists(ResourceId tableId, uint256[] keyIndexes, uint256[] fieldIndexes);
  error IdxRegistrationSystem_KeyIndexOutOfBounds(uint256 index, uint256 keySchemaNumFields);
  error IdxRegistrationSystem_FieldIndexOutOfBounds(uint256 index, uint256 numFields);
  error IdxRegistrationSystem_KeyAndFieldIndexesAbsent();
  error IdxRegistrationSystem_KeyAndFieldIndexesMustBeUnique(uint256[] indexes);
  error IdxRegistrationSystem_KeyAndFieldIndexesMustBeOrderedAscending(uint256[] indexes);

  /**
   * Validate and prepare data needed for idx hook creation.
   * @param sourceTableId table id to constrain.
   * @param keyIndexes key columns identified by their indexes in the table schema (may be empty).
   * @param fieldIndexes field columns identified by their indexes in the table schema (must have at least 1 field).
   */
  function prepareHookData(
    ResourceId sourceTableId,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes
  )
    internal
    view
    returns (
      FieldLayout fieldLayout,
      uint256 keyTupleLength,
      Uint8Map staticIndexes,
      Uint8Map dynamicIndexes,
      bytes32 indexesHash
    )
  {
    // The first 2 access checks mirror registerStoreHook
    // Require the table's namespace to exist
    AccessControl.requireExistence(sourceTableId.getNamespaceId());
    // Require caller to own the table
    AccessControl.requireOwner(sourceTableId, _msgSender());

    // Key and field indexes must be ordered (ascending) and unique
    _requireUniqueAndOrdered(keyIndexes);
    _requireUniqueAndOrdered(fieldIndexes);

    IBaseWorld world = IBaseWorld(_world());

    Schema keySchema = world.getKeySchema(sourceTableId);
    fieldLayout = world.getFieldLayout(sourceTableId);
    keyTupleLength = keySchema.numFields();

    // Must not be completely empty
    if (fieldIndexes.length() == 0 && keyIndexes.length() == 0) {
      revert IdxRegistrationSystem_KeyAndFieldIndexesAbsent();
    }

    // Indexes of keys and fields which define the idx
    indexesHash = hashIndexes(keyIndexes, fieldIndexes);

    // Cache separate static and dynamic field index arrays to optimize some conditions within the hook
    (staticIndexes, dynamicIndexes) = _splitFieldIndexes(fieldLayout, fieldIndexes);

    // Key indexes must be within the table's schema bounds
    for (uint256 i; i < keyIndexes.length(); i++) {
      uint256 index = keyIndexes.atIndex(i);
      uint256 numFields = keySchema.numFields();
      if (index >= numFields) {
        revert IdxRegistrationSystem_KeyIndexOutOfBounds(index, numFields);
      }
    }
    // Field indexes must be within the table's field layout bounds
    for (uint256 i; i < fieldIndexes.length(); i++) {
      uint256 index = fieldIndexes.atIndex(i);
      uint256 numFields = fieldLayout.numFields();
      if (index >= numFields) {
        revert IdxRegistrationSystem_FieldIndexOutOfBounds(index, numFields);
      }
    }
  }

  function _requireUniqueAndOrdered(Uint8Map uint8Map) internal pure {
    if (uint8Map.length() == 0) {
      return;
    }

    // Assign the 0th element to be the highest and skip order/uniqueness checks
    uint256 highest = uint8Map.atIndex(0);

    for (uint256 i = 1; i < uint8Map.length(); i++) {
      // Check ascending order
      if (uint8Map.atIndex(i) < highest) {
        revert IdxRegistrationSystem_KeyAndFieldIndexesMustBeOrderedAscending(uint8Map.toArray());
      }
      // Rely on ascending order to easily check uniqueness
      if (uint8Map.atIndex(i) == highest) {
        revert IdxRegistrationSystem_KeyAndFieldIndexesMustBeUnique(uint8Map.toArray());
      }

      highest = uint8Map.atIndex(i);
    }
  }

  function _splitFieldIndexes(
    FieldLayout fieldLayout,
    Uint8Map fieldIndexes
  ) internal pure returns (Uint8Map, Uint8Map) {
    uint256 dynamicIndexStart = fieldLayout.numStaticFields();

    uint256 staticFieldIndexesLength;
    uint256 dynamicFieldIndexesLength;
    for (uint256 i; i < fieldIndexes.length(); i++) {
      if (fieldIndexes.atIndex(i) < dynamicIndexStart) {
        staticFieldIndexesLength += 1;
      } else {
        dynamicFieldIndexesLength += 1;
      }
    }

    // TODO this can be optimized by ditching the intermediate arrays and adding setters to Uint8Map?
    uint256[] memory staticFieldIndexes = new uint256[](staticFieldIndexesLength);
    uint256[] memory dynamicFieldIndexes = new uint256[](dynamicFieldIndexesLength);

    for (uint256 i; i < staticFieldIndexesLength; i++) {
      staticFieldIndexes[i] = fieldIndexes.atIndex(i);
    }
    for (uint256 i; i < dynamicFieldIndexesLength; i++) {
      dynamicFieldIndexes[i] = fieldIndexes.atIndex(i + staticFieldIndexesLength);
    }

    return (Uint8MapLib.encode(staticFieldIndexes), Uint8MapLib.encode(dynamicFieldIndexes));
  }
}
