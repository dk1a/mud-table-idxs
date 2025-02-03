// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { Module } from "@latticexyz/world/src/Module.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { NAMESPACE_ID, SYSTEM_ID } from "./constants.sol";
import { BasicIdxHook } from "./BasicIdxHook.sol";
import { BasicIdx } from "./codegen/tables/BasicIdx.sol";
import { BasicIdxMetadata } from "./codegen/tables/BasicIdxMetadata.sol";
import { BasicIdxUsedKeys } from "./codegen/tables/BasicIdxUsedKeys.sol";
import { BasicIdxRegistrationSystem } from "./BasicIdxRegistrationSystem.sol";

contract BasicIdxModule is Module {
  // Since the BasicIdxRegistrationSystem only exists once per World and writes to
  // known tables, we can deploy it once and register it in multiple Worlds.
  BasicIdxRegistrationSystem private immutable basicIdxRegistrationSystem = new BasicIdxRegistrationSystem();

  function installRoot(bytes memory) public pure {
    revert Module_RootInstallNotSupported();
  }

  function install(bytes memory) public {
    IBaseWorld world = IBaseWorld(_world());

    // Register namespace
    world.registerNamespace(NAMESPACE_ID);

    // Register tables
    BasicIdx.register();
    BasicIdxMetadata.register();
    BasicIdxUsedKeys.register();

    // Register system
    world.registerSystem(SYSTEM_ID, basicIdxRegistrationSystem, true);

    // Transfer namespace ownership to the registration system, so it can grant table access to hooks
    (address systemAddress, ) = Systems.get(SYSTEM_ID);
    world.transferOwnership(NAMESPACE_ID, systemAddress);
  }
}
