// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { IStoreHook } from "@latticexyz/store/src/IStoreHook.sol";

import { UniqueIdxMetadata } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/codegen/tables/UniqueIdxMetadata.sol";
import { UniqueIdxHook } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/UniqueIdxHook.sol";

import { BaseTest } from "./BaseTest.t.sol";

import { Equipment } from "../src/codegen/tables/Equipment.sol";
import { UniqueIdx_Equipment_SlotName } from "../src/UniqueIdx_Equipment_SlotName.sol";

// Indexed columns: slot, name
contract UniqueIdx_Equipment_SlotNameTest is BaseTest {
  address hookAddress;

  function setUp() public virtual override {
    super.setUp();

    hookAddress = UniqueIdxMetadata.getHookAddress(Equipment._tableId, UniqueIdx_Equipment_SlotName.indexesHash());
  }

  function _expectCallSetHook() internal {
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeSetRecord.selector, Equipment._tableId), 1);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSetRecord.selector, Equipment._tableId), 1);

    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeSpliceStaticData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSpliceStaticData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeSpliceDynamicData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSpliceDynamicData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeDeleteRecord.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterDeleteRecord.selector), 0);
  }

  function testGet() public {
    bytes32 entity = hex"1a";
    bytes32 slot = "hands";
    uint32 level = 5;
    string memory name = "gloves";

    _expectCallSetHook();

    Equipment.set(entity, slot, level, name);

    assertEq(UniqueIdx_Equipment_SlotName.get(slot, name), entity);
  }

  function testSetUniqueDuplicateError() public {
    bytes32 slot = "hands";
    uint32 level = 5;
    string memory name = "gloves";

    Equipment.set(hex"1a", slot, level, name);

    vm.expectPartialRevert(UniqueIdxHook.UniqueIdxHook_UniqueValueDuplicate.selector);
    Equipment.set(hex"1b", slot, level, name);
  }
}
