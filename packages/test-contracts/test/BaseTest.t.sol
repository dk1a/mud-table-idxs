// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

abstract contract BaseTest is MudTest {
  IWorld world;

  function setUp() public virtual override {
    super.setUp();

    world = IWorld(worldAddress);

    address testContractAddress = address(this);
    // Allow tests to use table setters directly
    _grantRootAccess(testContractAddress);
  }

  function _grantRootAccess(address grantee) internal {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.broadcast(deployerPrivateKey);
    world.grantAccess(WorldResourceIdLib.encodeNamespace(""), grantee);
  }
}
