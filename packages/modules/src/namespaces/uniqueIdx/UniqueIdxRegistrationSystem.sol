// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Uint8Map, Uint8MapLib } from "../../Uint8Map.sol";
import { IdxRegistrationSystemAbstract } from "../../IdxRegistrationSystemAbstract.sol";

import { UniqueIdx } from "./codegen/tables/UniqueIdx.sol";
import { UniqueIdxMetadata, UniqueIdxMetadataData } from "./codegen/tables/UniqueIdxMetadata.sol";
import { UniqueIdxHook } from "./UniqueIdxHook.sol";

contract UniqueIdxRegistrationSystem is IdxRegistrationSystemAbstract {
  error UniqueIdxRegistrationSystem_AtLeastOneFieldRequired();

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
    IBaseWorld world = IBaseWorld(_world());

    // At least 1 field index is required
    // Primary key should not be made redundant by forcing a subset of it to be unique
    if (fieldIndexes.length() == 0) {
      revert UniqueIdxRegistrationSystem_AtLeastOneFieldRequired();
    }

    (
      FieldLayout fieldLayout,
      uint256 keyTupleLength,
      Uint8Map staticIndexes,
      Uint8Map dynamicIndexes,
      bytes32 indexesHash
    ) = prepareHookData(sourceTableId, keyIndexes, fieldIndexes);

    UniqueIdxHook hook = new UniqueIdxHook(
      fieldLayout,
      keyTupleLength,
      keyIndexes,
      fieldIndexes,
      staticIndexes,
      dynamicIndexes
    );
    // Grant the hook access to the idx table
    world.grantAccess(UniqueIdx._tableId, address(hook));

    // Save the metadata for convenience and external access
    // (the hook doesn't use it in favor of immutable variables to avoid extra storage access)
    if (UniqueIdxMetadata.getHas(sourceTableId, indexesHash)) {
      revert IdxRegistrationSystem_IdxAlreadyExists(sourceTableId, keyIndexes.toArray(), fieldIndexes.toArray());
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
}
