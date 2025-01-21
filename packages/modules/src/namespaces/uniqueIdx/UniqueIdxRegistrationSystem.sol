// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";
import { BEFORE_SET_RECORD, BEFORE_SPLICE_STATIC_DATA, AFTER_SPLICE_STATIC_DATA, BEFORE_SPLICE_DYNAMIC_DATA, AFTER_SPLICE_DYNAMIC_DATA, BEFORE_DELETE_RECORD } from "@latticexyz/store/src/storeHookTypes.sol";

import { ResourceId, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";

import { Uint8Map, Uint8MapLib } from "../../Uint8Map.sol";

import { UniqueIdx } from "./codegen/tables/UniqueIdx.sol";
import { UniqueIdxMetadata, UniqueIdxMetadataData } from "./codegen/tables/UniqueIdxMetadata.sol";
import { UniqueIdxHook } from "./UniqueIdxHook.sol";
import { hashIndexes } from "./utils.sol";

contract UniqueIdxRegistrationSystem is System {
  using WorldResourceIdInstance for ResourceId;

  error UniqueIdxRegistrationSystem_IdxAlreadyExists(ResourceId tableId, uint256[] keyIndexes, uint256[] fieldIndexes);
  error UniqueIdxRegistrationSystem_KeyIndexOutOfBounds(uint256 index, uint256 keySchemaNumFields);
  error UniqueIdxRegistrationSystem_FieldIndexOutOfBounds(uint256 index, uint256 numFields);
  error UniqueIdxRegistrationSystem_AtLeastOneFieldRequired();
  error UniqueIdxRegistrationSystem_KeyAndFieldIndexesMustBeUnique(uint256[] indexes);
  error UniqueIdxRegistrationSystem_KeyAndFieldIndexesMustBeOrderedAscending(uint256[] indexes);

  /**
   * Create a hook on the source table to hash and constrain the data of the provided columns.
   * You likely should not use this function directly! See `registerUniqueIdx` instead.
   * @param sourceTableId table id to constrain.
   * @param keyIndexes key columns identified by their indexes in the table schema (may be empty).
   * @param fieldIndexes field columns identified by their indexes in the table schema (must have at least 1 field).
   */
  function createUniqueIdxHook(
    ResourceId sourceTableId,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes
  ) public returns (UniqueIdxHook) {
    // The first 2 access checks mirror registerStoreHook
    // Require the table's namespace to exist
    AccessControl.requireExistence(sourceTableId.getNamespaceId());
    // Require caller to own the namespace
    AccessControl.requireOwner(sourceTableId, _msgSender());

    // Key and field indexes must be ordered (ascending) and unique
    _requireUniqueAndOrdered(keyIndexes);
    _requireUniqueAndOrdered(fieldIndexes);

    IBaseWorld world = IBaseWorld(_world());

    Schema keySchema = world.getKeySchema(sourceTableId);
    FieldLayout fieldLayout = world.getFieldLayout(sourceTableId);

    // At least 1 field index is required
    // Primary key should not be made redundant by forcing a subset of it to be unique
    if (fieldIndexes.length() == 0) {
      revert UniqueIdxRegistrationSystem_AtLeastOneFieldRequired();
    }

    // Indexes of keys and fields which are enforced to be unique by UniqueIdx module
    bytes32 indexesHash = hashIndexes(keyIndexes, fieldIndexes);

    // Cache separate static and dynamic field index arrays to optimize some conditions within the hook
    (Uint8Map staticIndexes, Uint8Map dynamicIndexes) = _splitFieldIndexes(fieldLayout, fieldIndexes);

    // Key indexes must be within the table's schema bounds
    for (uint256 i; i < keyIndexes.length(); i++) {
      uint256 index = keyIndexes.atIndex(i);
      uint256 numFields = keySchema.numFields();
      if (index >= numFields) {
        revert UniqueIdxRegistrationSystem_KeyIndexOutOfBounds(index, numFields);
      }
    }
    // Field indexes must be within the table's field layout bounds
    for (uint256 i; i < fieldIndexes.length(); i++) {
      uint256 index = fieldIndexes.atIndex(i);
      uint256 numFields = fieldLayout.numFields();
      if (index >= numFields) {
        revert UniqueIdxRegistrationSystem_FieldIndexOutOfBounds(index, numFields);
      }
    }

    UniqueIdxHook hook = new UniqueIdxHook(fieldLayout, keyIndexes, fieldIndexes, staticIndexes, dynamicIndexes);
    // Grant the hook access to the idx table
    world.grantAccess(UniqueIdx._tableId, address(hook));

    // Save the metadata for convenience and external access
    // (the hook doesn't use it in favor of immutable variables to avoid extra storage access)
    if (UniqueIdxMetadata.getHas(sourceTableId, indexesHash)) {
      revert UniqueIdxRegistrationSystem_IdxAlreadyExists(sourceTableId, keyIndexes.toArray(), fieldIndexes.toArray());
    }
    UniqueIdxMetadata.set(
      sourceTableId,
      indexesHash,
      UniqueIdxMetadataData({
        has: true,
        hookAddress: address(hook),
        keyIndexes: keyIndexes,
        fieldIndexes: fieldIndexes,
        staticIndexes: staticIndexes,
        dynamicIndexes: dynamicIndexes
      })
    );

    return hook;
  }

  function _requireUniqueAndOrdered(Uint8Map uint8Map) internal pure {
    if (uint8Map.length() == 0) {
      return;
    }

    // Assign the 0th elementg to be the highest and skip order/uniqueness checks
    uint256 highest = uint8Map.atIndex(0);

    for (uint256 i = 1; i < uint8Map.length(); i++) {
      // Check ascending order
      if (uint8Map.atIndex(i) < highest) {
        revert UniqueIdxRegistrationSystem_KeyAndFieldIndexesMustBeOrderedAscending(uint8Map.toArray());
      }
      // Rely on ascending order to easily check uniqueness
      if (uint8Map.atIndex(i) == highest) {
        revert UniqueIdxRegistrationSystem_KeyAndFieldIndexesMustBeUnique(uint8Map.toArray());
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
      if (fieldIndexes.atIndex(0) < dynamicIndexStart) {
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
