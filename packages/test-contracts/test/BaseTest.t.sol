// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IStoreHook } from "@latticexyz/store/src/IStoreHook.sol";

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

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
    vm.prank(vm.addr(deployerPrivateKey));
    world.grantAccess(WorldResourceIdLib.encodeNamespace(""), grantee);
  }

  function _expectCallHook(
    address hookAddress,
    ResourceId tableId,
    uint64 setRecordCount,
    uint64 spliceStaticCount,
    uint64 spliceDynamicCount,
    uint64 deleteCount
  ) internal {
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeSetRecord.selector, tableId), setRecordCount);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSetRecord.selector), 0);

    vm.expectCall(
      hookAddress,
      abi.encodeWithSelector(IStoreHook.onBeforeSpliceStaticData.selector, tableId),
      spliceStaticCount
    );
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSpliceStaticData.selector), 0);

    vm.expectCall(
      hookAddress,
      abi.encodeWithSelector(IStoreHook.onBeforeSpliceDynamicData.selector, tableId),
      spliceDynamicCount
    );
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSpliceDynamicData.selector), 0);

    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeDeleteRecord.selector, tableId), deleteCount);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterDeleteRecord.selector), 0);
  }
}
