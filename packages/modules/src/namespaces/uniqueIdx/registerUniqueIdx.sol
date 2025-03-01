// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { BEFORE_ALL } from "@latticexyz/store/src/storeHookTypes.sol";

import { StoreRegistrationSystem } from "@latticexyz/world/src/modules/init/implementations/StoreRegistrationSystem.sol";

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";

import { Uint8Map } from "../../Uint8Map.sol";
import { SYSTEM_ID } from "./constants.sol";
import { UniqueIdxRegistrationSystem } from "./UniqueIdxRegistrationSystem.sol";
import { UniqueIdxHook } from "./UniqueIdxHook.sol";

/**
 * Create and register a hook on the source table to hash and constrain the data of the provided columns.
 * @param sourceTableId table id to constrain.
 * @param keyIndexes key columns identified by their indexes in the table schema (may be empty).
 * @param fieldIndexes field columns identified by their indexes in the table schema (must have at least 1 field).
 */
function registerUniqueIdx(ResourceId sourceTableId, Uint8Map keyIndexes, Uint8Map fieldIndexes) {
  // Use the system to create the UniqueIdx hook, which handles all the indexing
  bytes memory returnData = SystemSwitch.call(
    SYSTEM_ID,
    abi.encodeCall(UniqueIdxRegistrationSystem.createUniqueIdxHook, (sourceTableId, keyIndexes, fieldIndexes))
  );
  UniqueIdxHook hook = abi.decode(returnData, (UniqueIdxHook));

  // Register the hook to be called when a value is set in the source table
  // (this can't be done inside the system because the caller must own the arbitrary source table)
  // TODO IBaseWorld should be used instead of StoreRegistrationSystem,
  // but due to inheritance in RegistrationSystem not being included in worldgen, IBaseWorld lacks its methods
  SystemSwitch.call(abi.encodeCall(StoreRegistrationSystem.registerStoreHook, (sourceTableId, hook, BEFORE_ALL)));
}
