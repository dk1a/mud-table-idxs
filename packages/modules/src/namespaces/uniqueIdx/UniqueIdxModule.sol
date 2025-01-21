// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { Module } from "@latticexyz/world/src/Module.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { NAMESPACE_ID, SYSTEM_ID } from "./constants.sol";
import { UniqueIdxHook } from "./UniqueIdxHook.sol";
import { UniqueIdx } from "./codegen/tables/UniqueIdx.sol";
import { UniqueIdxMetadata } from "./codegen/tables/UniqueIdxMetadata.sol";
import { UniqueIdxRegistrationSystem } from "./UniqueIdxRegistrationSystem.sol";

/**
 * This module deploys a hook that is called when a value is set in the `sourceTableId`
 * provided in the install methods arguments. The hook keeps track of the keys that map to a given value.
 * from value to list of keys with this value. This mapping is stored in a table registered
 * by the module at the `targetTableId` provided in the install methods arguments.
 */
contract UniqueIdxModule is Module {
  // Since the UniqueIdxRegistrationSystem only exists once per World and writes to
  // known tables, we can deploy it once and register it in multiple Worlds.
  UniqueIdxRegistrationSystem private immutable uniqueIdxRegistrationSystem = new UniqueIdxRegistrationSystem();

  function installRoot(bytes memory) public pure {
    revert Module_RootInstallNotSupported();
  }

  function install(bytes memory) public {
    IBaseWorld world = IBaseWorld(_world());

    // Register namespace
    world.registerNamespace(NAMESPACE_ID);

    // Register tables
    UniqueIdx.register();
    UniqueIdxMetadata.register();

    // Register system
    world.registerSystem(SYSTEM_ID, uniqueIdxRegistrationSystem, true);

    // Transfer namespace ownership to the registration system, so it can grant table access to hooks
    (address systemAddress, ) = Systems.get(SYSTEM_ID);
    world.transferOwnership(NAMESPACE_ID, systemAddress);
  }
}
