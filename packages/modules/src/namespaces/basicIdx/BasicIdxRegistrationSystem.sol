// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Uint8Map, Uint8MapLib } from "../../Uint8Map.sol";
import { IdxRegistrationSystemAbstract } from "../../IdxRegistrationSystemAbstract.sol";

import { BasicIdx } from "./codegen/tables/BasicIdx.sol";
import { BasicIdxMetadata, BasicIdxMetadataData } from "./codegen/tables/BasicIdxMetadata.sol";
import { BasicIdxUsedKeys } from "./codegen/tables/BasicIdxUsedKeys.sol";
import { BasicIdxHook } from "./BasicIdxHook.sol";

contract BasicIdxRegistrationSystem is IdxRegistrationSystemAbstract {
  /**
   * Create a hook on the source table to index the data of the provided columns.
   * You likely should not use this function directly! See `registerBasicIdx` instead.
   * @param sourceTableId table id to index.
   * @param keyIndexes key columns identified by their indexes in the table schema (may be empty if fieldIndexes is not empty).
   * @param fieldIndexes field columns identified by their indexes in the table schema (may be empty if keyIndexes is not empty).
   */
  function createBasicIdxHook(
    ResourceId sourceTableId,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes
  ) public returns (BasicIdxHook) {
    IBaseWorld world = IBaseWorld(_world());

    (
      FieldLayout fieldLayout,
      uint256 keyTupleLength,
      Uint8Map staticIndexes,
      Uint8Map dynamicIndexes,
      bytes32 indexesHash
    ) = prepareHookData(sourceTableId, keyIndexes, fieldIndexes);

    BasicIdxHook hook = BasicIdxHookCreator.newHook(
      fieldLayout,
      keyTupleLength,
      keyIndexes,
      fieldIndexes,
      staticIndexes,
      dynamicIndexes
    );
    // Grant the hook access to the idx table
    world.grantAccess(BasicIdx._tableId, address(hook));
    world.grantAccess(BasicIdxUsedKeys._tableId, address(hook));

    // Save the metadata for convenience and external access
    // (the hook doesn't use it in favor of immutable variables to avoid extra storage access)
    if (BasicIdxMetadata.getHas(sourceTableId, indexesHash)) {
      revert IdxRegistrationSystem_IdxAlreadyExists(sourceTableId, keyIndexes.toArray(), fieldIndexes.toArray());
    }
    BasicIdxMetadata.set(
      sourceTableId,
      indexesHash,
      BasicIdxMetadataData({
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

// A public library to externalize the hook's codesize from the system, otherwise it won't fit
library BasicIdxHookCreator {
  function newHook(
    FieldLayout fieldLayout,
    uint256 keyTupleLength,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes,
    Uint8Map staticIndexes,
    Uint8Map dynamicIndexes
  ) public returns (BasicIdxHook) {
    return new BasicIdxHook(fieldLayout, keyTupleLength, keyIndexes, fieldIndexes, staticIndexes, dynamicIndexes);
  }
}
