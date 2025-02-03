// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { IStoreHook } from "@latticexyz/store/src/IStoreHook.sol";

import { BasicIdxMetadata } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/codegen/tables/BasicIdxMetadata.sol";
import { BasicIdxHook } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/BasicIdxHook.sol";

import { BaseTest } from "./BaseTest.t.sol";

import { EquipmentSlot } from "../src/codegen/common.sol";
import { Equipment } from "../src/namespaces/root/codegen/tables/Equipment.sol";
import { Idx_Equipment_Entity } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_Entity.sol";
import { Idx_Equipment_Level } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_Level.sol";
import { Idx_Equipment_SlotLevel } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_SlotLevel.sol";

struct TestData {
  bytes32 entity;
  EquipmentSlot slot;
  uint32 level;
  string name;
}

contract BasicIdxTest is BaseTest {
  address hookEntity;
  address hookLevel;
  address hookSlotLevel;

  TestData d1;
  TestData d2;
  TestData d3;

  function setUp() public virtual override {
    super.setUp();

    hookEntity = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_Entity._indexesHash);
    hookLevel = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_Level._indexesHash);
    hookSlotLevel = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_SlotLevel._indexesHash);

    d1 = TestData({ entity: hex"1a", slot: EquipmentSlot.Armor, level: 5, name: "gloves" });

    d2 = TestData({ entity: hex"2b", slot: EquipmentSlot.Weapon, level: 5, name: "sword" });

    d3 = TestData({ entity: hex"3c", slot: EquipmentSlot.Armor, level: 5, name: "helmet" });
  }

  function _expectCallSetHook(address hookAddress, uint64 count) internal {
    vm.expectCall(
      hookAddress,
      abi.encodeWithSelector(IStoreHook.onBeforeSetRecord.selector, Equipment._tableId),
      count
    );
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSetRecord.selector, Equipment._tableId), count);

    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeSpliceStaticData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSpliceStaticData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeSpliceDynamicData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterSpliceDynamicData.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeDeleteRecord.selector), 0);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterDeleteRecord.selector), 0);
  }

  function _expectCallDeleteHook(address hookAddress, uint64 count) internal {
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onBeforeDeleteRecord.selector), count);
    vm.expectCall(hookAddress, abi.encodeWithSelector(IStoreHook.onAfterDeleteRecord.selector), 0);
  }

  function _testSetFirst() internal {
    Equipment.set(d1.entity, d1.slot, d1.level, d1.name);

    (bool has, uint40 index) = Idx_Equipment_Entity.has(d1.entity);
    assertEq(has, true);
    assertEq(index, 0);

    assertEq(Idx_Equipment_Level.length(d1.level), 1);
    assertEq(Idx_Equipment_Level.get(d1.level, 0), d1.entity);

    assertEq(Idx_Equipment_SlotLevel.length(d1.slot, d1.level), 1);
    assertEq(Idx_Equipment_SlotLevel.get(d1.slot, d1.level, 0), d1.entity);
  }

  function testSetOne() public {
    _expectCallSetHook(hookEntity, 1);
    _expectCallSetHook(hookLevel, 1);
    _expectCallSetHook(hookSlotLevel, 1);

    _testSetFirst();
  }

  function _testSetSecond() internal {
    Equipment.set(d2.entity, d2.slot, d2.level, d2.name);

    (bool has, uint40 index) = Idx_Equipment_Entity.has(d2.entity);
    assertEq(has, true);
    assertEq(index, 0);

    assertEq(Idx_Equipment_Level.length(d2.level), 2);
    assertEq(Idx_Equipment_Level.get(d2.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d2.level, 1), d2.entity);

    assertEq(Idx_Equipment_SlotLevel.length(d2.slot, d2.level), 1);
    assertEq(Idx_Equipment_SlotLevel.get(d2.slot, d2.level, 0), d2.entity);

    // Ensure data1 is still present
    assertEq(Idx_Equipment_SlotLevel.length(d1.slot, d1.level), 1);
    assertEq(Idx_Equipment_SlotLevel.get(d1.slot, d1.level, 0), d1.entity);
  }

  function testSetTwo() public {
    _expectCallSetHook(hookEntity, 2);
    _expectCallSetHook(hookLevel, 2);
    _expectCallSetHook(hookSlotLevel, 2);

    _testSetFirst();
    _testSetSecond();
  }

  function _testSetThird() internal {
    Equipment.set(d3.entity, d3.slot, d3.level, d3.name);

    (bool has, uint40 index) = Idx_Equipment_Entity.has(d3.entity);
    assertEq(has, true);
    assertEq(index, 0);

    assertEq(Idx_Equipment_Level.length(d3.level), 3);
    assertEq(Idx_Equipment_Level.get(d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d3.level, 1), d2.entity);
    assertEq(Idx_Equipment_Level.get(d3.level, 2), d3.entity);

    assertEq(Idx_Equipment_SlotLevel.length(d3.slot, d3.level), 2);
    assertEq(Idx_Equipment_SlotLevel.get(d3.slot, d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_SlotLevel.get(d3.slot, d3.level, 1), d3.entity);

    // Ensure data2 is still present
    assertEq(Idx_Equipment_SlotLevel.length(d2.slot, d2.level), 1);
    assertEq(Idx_Equipment_SlotLevel.get(d2.slot, d2.level, 0), d2.entity);
  }

  function testSetThree() public {
    _expectCallSetHook(hookEntity, 3);
    _expectCallSetHook(hookLevel, 3);
    _expectCallSetHook(hookSlotLevel, 3);

    _testSetFirst();
    _testSetSecond();
    _testSetThird();
  }

  function testDeleteSecondFromThree() public {
    _testSetFirst();
    _testSetSecond();
    _testSetThird();

    _expectCallDeleteHook(hookEntity, 1);
    _expectCallDeleteHook(hookLevel, 1);
    _expectCallDeleteHook(hookSlotLevel, 1);

    Equipment.deleteRecord(d2.entity);

    (bool has, uint40 index) = Idx_Equipment_Entity.has(d2.entity);
    assertEq(has, false);
    assertEq(index, 0);

    // Ensure data1 and data3 are still present
    (has, index) = Idx_Equipment_Entity.has(d1.entity);
    assertEq(has, true);
    assertEq(index, 0);

    (has, index) = Idx_Equipment_Entity.has(d3.entity);
    assertEq(has, true);
    assertEq(index, 0);

    assertEq(Idx_Equipment_Level.length(d2.level), 2);
    assertEq(Idx_Equipment_Level.get(d2.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d2.level, 1), d3.entity);

    assertEq(Idx_Equipment_SlotLevel.length(d2.slot, d2.level), 0);

    assertEq(Idx_Equipment_SlotLevel.length(d3.slot, d3.level), 2);
    assertEq(Idx_Equipment_SlotLevel.get(d3.slot, d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_SlotLevel.get(d3.slot, d3.level, 1), d3.entity);
  }
}
