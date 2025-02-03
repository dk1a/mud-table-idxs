// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Idx_Equipment_Entity } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_Entity.sol";
import { Idx_Equipment_Level } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_Level.sol";
import { Idx_Equipment_SlotLevel } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_SlotLevel.sol";
import { Idx_Position_MatchEntityXY } from "../src/namespaces/root/codegen/idxs/Idx_Position_MatchEntityXY.sol";
import { UniqueIdx_Equipment_SlotName } from "../src/namespaces/root/codegen/idxs/UniqueIdx_Equipment_SlotName.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    Idx_Equipment_Entity.register();
    Idx_Equipment_Level.register();
    Idx_Equipment_SlotLevel.register();
    Idx_Position_MatchEntityXY.register();
    UniqueIdx_Equipment_SlotName.register();

    vm.stopBroadcast();
  }
}
