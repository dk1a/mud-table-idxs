// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IStoreErrors } from "@latticexyz/store/src/IStoreErrors.sol";
import { IStoreHook } from "@latticexyz/store/src/IStoreHook.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { BasicIdxMetadata } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/codegen/tables/BasicIdxMetadata.sol";
import { BasicIdxHook } from "@dk1a/mud-table-idxs/src/namespaces/basicIdx/BasicIdxHook.sol";

import { BaseTest } from "./BaseTest.t.sol";

import { EquipmentType } from "../src/codegen/common.sol";
import { Equipment } from "../src/namespaces/root/codegen/tables/Equipment.sol";
import { Idx_Equipment_Entity } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_Entity.sol";
import { Idx_Equipment_Level } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_Level.sol";
import { Idx_Equipment_TypeLevel } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_TypeLevel.sol";
import { Idx_Equipment_Name } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_Name.sol";
import { Idx_Equipment_TypeNameSlots } from "../src/namespaces/root/codegen/idxs/Idx_Equipment_TypeNameSlots.sol";

struct TestData {
  bytes32 entity;
  EquipmentType equipmentType;
  uint32 level;
  string name;
  bytes32[] slots;
}

contract BasicIdxTest is BaseTest {
  address hookEntity;
  address hookLevel;
  address hookTypeLevel;
  address hookName;
  address hookTypeNameSlots;

  TestData d1;
  TestData d2;
  TestData d3;
  TestData d4;

  function setUp() public virtual override {
    super.setUp();

    hookEntity = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_Entity._indexesHash);
    hookLevel = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_Level._indexesHash);
    hookTypeLevel = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_TypeLevel._indexesHash);
    hookName = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_Name._indexesHash);
    hookTypeNameSlots = BasicIdxMetadata.getHookAddress(Equipment._tableId, Idx_Equipment_TypeNameSlots._indexesHash);

    bytes32[] memory d1Slots = new bytes32[](1);
    d1Slots[0] = "Hands";
    d1 = TestData({ entity: hex"1a", equipmentType: EquipmentType.Armor, level: 5, name: "gloves", slots: d1Slots });

    bytes32[] memory d2Slots = new bytes32[](2);
    d2Slots[0] = "Hand_L";
    d2Slots[1] = "Hand_R";
    d2 = TestData({ entity: hex"2b", equipmentType: EquipmentType.Weapon, level: 5, name: "sword", slots: d2Slots });

    bytes32[] memory d3Slots = new bytes32[](1);
    d3Slots[0] = "Head";
    d3 = TestData({ entity: hex"3c", equipmentType: EquipmentType.Armor, level: 5, name: "helmet", slots: d3Slots });

    bytes32[] memory d4Slots = new bytes32[](1);
    d4Slots[0] = "Hands";
    d4 = TestData({ entity: hex"4d", equipmentType: EquipmentType.Armor, level: 8, name: "gloves", slots: d4Slots });
  }

  function _expectCallHook(
    uint64 setRecordCount,
    uint64 spliceStaticCount,
    uint64 spliceDynamicCount,
    uint64 deleteCount
  ) internal {
    address[3] memory hookAddresses = [hookEntity, hookLevel, hookTypeLevel];

    for (uint256 i; i < hookAddresses.length; i++) {
      address hookAddress = hookAddresses[i];

      _expectCallHook({
        hookAddress: hookAddress,
        tableId: Equipment._tableId,
        setRecordCount: setRecordCount,
        spliceStaticCount: spliceStaticCount,
        spliceDynamicCount: spliceDynamicCount,
        deleteCount: deleteCount
      });
    }
  }

  function _testSetFirst() internal {
    Equipment.set(d1.entity, d1.equipmentType, d1.level, d1.name, d1.slots);

    // [entity] idx
    (bool has, uint40 index) = Idx_Equipment_Entity.has(d1.entity);
    assertEq(has, true);
    assertEq(index, 0);
    // [level] idx
    assertEq(Idx_Equipment_Level.length(d1.level), 1);
    assertEq(Idx_Equipment_Level.get(d1.level, 0), d1.entity);
    // [equipmentType,level] idx
    assertEq(Idx_Equipment_TypeLevel.length(d1.equipmentType, d1.level), 1);
    assertEq(Idx_Equipment_TypeLevel.get(d1.equipmentType, d1.level, 0), d1.entity);
    // [name] idx
    assertEq(Idx_Equipment_Name.length(d1.name), 1);
    assertEq(Idx_Equipment_Name.get(d1.name, 0), d1.entity);
    // [equipmentType,name,slots] idx
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, d1.name, d1.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d1.equipmentType, d1.name, d1.slots, 0), d1.entity);
  }

  function testSetOne() public {
    _expectCallHook({ setRecordCount: 1, spliceStaticCount: 0, spliceDynamicCount: 0, deleteCount: 0 });

    _testSetFirst();
  }

  function _testSetSecond() internal {
    Equipment.set(d2.entity, d2.equipmentType, d2.level, d2.name, d2.slots);

    // [entity] idx
    (bool has, uint40 index) = Idx_Equipment_Entity.has(d2.entity);
    assertEq(has, true);
    assertEq(index, 0);
    // [level] idx
    assertEq(Idx_Equipment_Level.length(d2.level), 2);
    assertEq(Idx_Equipment_Level.get(d2.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d2.level, 1), d2.entity);
    // [equipmentType,level] idx
    assertEq(Idx_Equipment_TypeLevel.length(d2.equipmentType, d2.level), 1);
    assertEq(Idx_Equipment_TypeLevel.get(d2.equipmentType, d2.level, 0), d2.entity);
    // Ensure data1 is still present
    assertEq(Idx_Equipment_TypeLevel.length(d1.equipmentType, d1.level), 1);
    assertEq(Idx_Equipment_TypeLevel.get(d1.equipmentType, d1.level, 0), d1.entity);
    // [name] idx
    assertEq(Idx_Equipment_Name.length(d2.name), 1);
    assertEq(Idx_Equipment_Name.get(d2.name, 0), d2.entity);
    // Ensure data1 is still present
    assertEq(Idx_Equipment_Name.length(d1.name), 1);
    assertEq(Idx_Equipment_Name.get(d1.name, 0), d1.entity);
    // [equipmentType,name,slots] idx
    assertEq(Idx_Equipment_TypeNameSlots.length(d2.equipmentType, d2.name, d2.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d2.equipmentType, d2.name, d2.slots, 0), d2.entity);
    // Ensure data1 is still present
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, d1.name, d1.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d1.equipmentType, d1.name, d1.slots, 0), d1.entity);
  }

  function testSetTwo() public {
    _expectCallHook({ setRecordCount: 2, spliceStaticCount: 0, spliceDynamicCount: 0, deleteCount: 0 });

    _testSetFirst();
    _testSetSecond();
  }

  function _testSetThird() internal {
    Equipment.set(d3.entity, d3.equipmentType, d3.level, d3.name, d3.slots);

    // [entity] idx
    (bool has, uint40 index) = Idx_Equipment_Entity.has(d3.entity);
    assertEq(has, true);
    assertEq(index, 0);
    // [level] idx
    assertEq(Idx_Equipment_Level.length(d3.level), 3);
    assertEq(Idx_Equipment_Level.get(d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d3.level, 1), d2.entity);
    assertEq(Idx_Equipment_Level.get(d3.level, 2), d3.entity);
    // [equipmentType,level] idx
    assertEq(Idx_Equipment_TypeLevel.length(d3.equipmentType, d3.level), 2);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 1), d3.entity);
    // Ensure data2 is still present
    assertEq(Idx_Equipment_TypeLevel.length(d2.equipmentType, d2.level), 1);
    assertEq(Idx_Equipment_TypeLevel.get(d2.equipmentType, d2.level, 0), d2.entity);
    // [name] idx
    assertEq(Idx_Equipment_Name.length(d3.name), 1);
    assertEq(Idx_Equipment_Name.get(d3.name, 0), d3.entity);
    // Ensure data1 and data2 are still present
    assertEq(Idx_Equipment_Name.length(d1.name), 1);
    assertEq(Idx_Equipment_Name.get(d1.name, 0), d1.entity);
    assertEq(Idx_Equipment_Name.length(d2.name), 1);
    assertEq(Idx_Equipment_Name.get(d2.name, 0), d2.entity);
    // [equipmentType,name,slots] idx
    assertEq(Idx_Equipment_TypeNameSlots.length(d3.equipmentType, d3.name, d3.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d3.equipmentType, d3.name, d3.slots, 0), d3.entity);
    // Ensure data1 and data2 are still present
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, d1.name, d1.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d1.equipmentType, d1.name, d1.slots, 0), d1.entity);
    assertEq(Idx_Equipment_TypeNameSlots.length(d2.equipmentType, d2.name, d2.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d2.equipmentType, d2.name, d2.slots, 0), d2.entity);
  }

  function testSetThree() public {
    _expectCallHook({ setRecordCount: 3, spliceStaticCount: 0, spliceDynamicCount: 0, deleteCount: 0 });

    _testSetFirst();
    _testSetSecond();
    _testSetThird();
  }

  function testUpdateSecondStaticFromThree() public {
    _expectCallHook({ setRecordCount: 3, spliceStaticCount: 1, spliceDynamicCount: 0, deleteCount: 0 });

    _testSetFirst();
    _testSetSecond();
    _testSetThird();

    d2.level = 8;
    Equipment.setLevel(d2.entity, d2.level);

    // [entity] idx (should be unaffected)
    (bool has, uint40 index) = Idx_Equipment_Entity.has(d1.entity);
    assertEq(has, true);
    assertEq(index, 0);
    (has, index) = Idx_Equipment_Entity.has(d2.entity);
    assertEq(has, true);
    assertEq(index, 0);
    (has, index) = Idx_Equipment_Entity.has(d3.entity);
    assertEq(has, true);
    assertEq(index, 0);
    // [level] idx
    assertEq(Idx_Equipment_Level.length(d2.level), 1);
    assertEq(Idx_Equipment_Level.get(d2.level, 0), d2.entity);
    // Ensure data1 and data3 are still present
    assertEq(Idx_Equipment_Level.length(d1.level), 2);
    assertEq(Idx_Equipment_Level.get(d1.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d1.level, 1), d3.entity);
    // [equipmentType,level] idx
    assertEq(Idx_Equipment_TypeLevel.length(d2.equipmentType, d2.level), 1);
    assertEq(Idx_Equipment_TypeLevel.get(d2.equipmentType, d2.level, 0), d2.entity);
    // Ensure data1 and data3 are still present
    assertEq(Idx_Equipment_TypeLevel.length(d3.equipmentType, d3.level), 2);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 1), d3.entity);
    // [name] idx (should be unaffected)
    assertEq(Idx_Equipment_Name.length(d1.name), 1);
    assertEq(Idx_Equipment_Name.get(d1.name, 0), d1.entity);
    assertEq(Idx_Equipment_Name.length(d2.name), 1);
    assertEq(Idx_Equipment_Name.get(d2.name, 0), d2.entity);
    assertEq(Idx_Equipment_Name.length(d3.name), 1);
    assertEq(Idx_Equipment_Name.get(d3.name, 0), d3.entity);
    // [equipmentType,name,slots] idx (should be unaffected)
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, d1.name, d1.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d1.equipmentType, d1.name, d1.slots, 0), d1.entity);
    assertEq(Idx_Equipment_TypeNameSlots.length(d2.equipmentType, d2.name, d2.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d2.equipmentType, d2.name, d2.slots, 0), d2.entity);
    assertEq(Idx_Equipment_TypeNameSlots.length(d3.equipmentType, d3.name, d3.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d3.equipmentType, d3.name, d3.slots, 0), d3.entity);
  }

  function testUpdateSecondDynamicFromThree() public {
    _expectCallHook({ setRecordCount: 3, spliceStaticCount: 0, spliceDynamicCount: 1, deleteCount: 0 });

    _testSetFirst();
    _testSetSecond();
    _testSetThird();

    d2.slots[0] = "Tail";
    Equipment.updateSlots(d2.entity, 0, d2.slots[0]);

    // [entity] idx (should be unaffected)
    (bool has, uint40 index) = Idx_Equipment_Entity.has(d1.entity);
    assertEq(has, true);
    assertEq(index, 0);
    (has, index) = Idx_Equipment_Entity.has(d2.entity);
    assertEq(has, true);
    assertEq(index, 0);
    (has, index) = Idx_Equipment_Entity.has(d3.entity);
    assertEq(has, true);
    assertEq(index, 0);
    // [level] idx (should be unaffected)
    assertEq(Idx_Equipment_Level.length(d1.level), 3);
    assertEq(Idx_Equipment_Level.get(d1.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d2.level, 1), d2.entity);
    assertEq(Idx_Equipment_Level.get(d1.level, 2), d3.entity);
    // [equipmentType,level] idx (should be unaffected)
    assertEq(Idx_Equipment_TypeLevel.length(d2.equipmentType, d2.level), 1);
    assertEq(Idx_Equipment_TypeLevel.get(d2.equipmentType, d2.level, 0), d2.entity);
    assertEq(Idx_Equipment_TypeLevel.length(d3.equipmentType, d3.level), 2);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 1), d3.entity);
    // [name] idx (should be unaffected)
    assertEq(Idx_Equipment_Name.length(d1.name), 1);
    assertEq(Idx_Equipment_Name.get(d1.name, 0), d1.entity);
    assertEq(Idx_Equipment_Name.length(d2.name), 1);
    assertEq(Idx_Equipment_Name.get(d2.name, 0), d2.entity);
    assertEq(Idx_Equipment_Name.length(d3.name), 1);
    assertEq(Idx_Equipment_Name.get(d3.name, 0), d3.entity);
    // [equipmentType,name,slots] idx
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, d1.name, d1.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d1.equipmentType, d1.name, d1.slots, 0), d1.entity);
    assertEq(Idx_Equipment_TypeNameSlots.length(d2.equipmentType, d2.name, d2.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d2.equipmentType, d2.name, d2.slots, 0), d2.entity);
    assertEq(Idx_Equipment_TypeNameSlots.length(d3.equipmentType, d3.name, d3.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d3.equipmentType, d3.name, d3.slots, 0), d3.entity);
  }

  function testDeleteSecondFromThree() public {
    _expectCallHook({ setRecordCount: 3, spliceStaticCount: 0, spliceDynamicCount: 0, deleteCount: 1 });

    _testSetFirst();
    _testSetSecond();
    _testSetThird();

    Equipment.deleteRecord(d2.entity);

    // [entity] idx
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
    // [level] idx
    assertEq(Idx_Equipment_Level.length(d2.level), 2);
    assertEq(Idx_Equipment_Level.get(d2.level, 0), d1.entity);
    assertEq(Idx_Equipment_Level.get(d2.level, 1), d3.entity);
    // [equipmentType,level] idx
    assertEq(Idx_Equipment_TypeLevel.length(d2.equipmentType, d2.level), 0);
    // Ensure data1 and data3 are still present
    assertEq(Idx_Equipment_TypeLevel.length(d3.equipmentType, d3.level), 2);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 0), d1.entity);
    assertEq(Idx_Equipment_TypeLevel.get(d3.equipmentType, d3.level, 1), d3.entity);
    // [name] idx
    assertEq(Idx_Equipment_Name.length(d2.name), 0);
    // Ensure data1 and data3 are still present
    assertEq(Idx_Equipment_Name.length(d1.name), 1);
    assertEq(Idx_Equipment_Name.get(d1.name, 0), d1.entity);
    assertEq(Idx_Equipment_Name.length(d3.name), 1);
    assertEq(Idx_Equipment_Name.get(d3.name, 0), d3.entity);
    // [equipmentType,name,slots] idx (should be unaffected)
    assertEq(Idx_Equipment_TypeNameSlots.length(d2.equipmentType, d2.name, d2.slots), 0);
    // Ensure data1 and data3 are still present
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, d1.name, d1.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d1.equipmentType, d1.name, d1.slots, 0), d1.entity);
    assertEq(Idx_Equipment_TypeNameSlots.length(d3.equipmentType, d3.name, d3.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d3.equipmentType, d3.name, d3.slots, 0), d3.entity);
  }

  function testSetAndSpliceFourth() public {
    _testSetFirst();
    _testSetSecond();
    _testSetThird();

    Equipment.set(d4.entity, d4.equipmentType, d4.level, d4.name, d4.slots);

    // [name] idx
    assertEq(Idx_Equipment_Name.length(d4.name), 2);
    assertEq(Idx_Equipment_Name.get(d4.name, 0), d1.entity);
    assertEq(Idx_Equipment_Name.get(d4.name, 1), d4.entity);
    // [equipmentType,name,slots] idx
    assertEq(Idx_Equipment_TypeNameSlots.length(d4.equipmentType, d4.name, d4.slots), 2);
    assertEq(Idx_Equipment_TypeNameSlots.get(d4.equipmentType, d4.name, d4.slots, 0), d1.entity);
    assertEq(Idx_Equipment_TypeNameSlots.get(d4.equipmentType, d4.name, d4.slots, 1), d4.entity);

    // In d4.name ("gloves") change the letter "l" at index 1 to "r"
    StoreSwitch.spliceDynamicData(Equipment._tableId, Equipment.encodeKeyTuple(d4.entity), 0, 1, 1, "r");
    d4.name = "groves";

    // Ensure it is now distinct in the idxs that include name
    assertEq(Idx_Equipment_Name.length(d1.name), 1);
    assertEq(Idx_Equipment_Name.get(d1.name, 0), d1.entity);
    assertEq(Idx_Equipment_Name.length(d4.name), 1);
    assertEq(Idx_Equipment_Name.get(d4.name, 0), d4.entity);
    // [equipmentType,name,slots] idx
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, d1.name, d1.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d1.equipmentType, d1.name, d1.slots, 0), d1.entity);
    assertEq(Idx_Equipment_TypeNameSlots.length(d4.equipmentType, d4.name, d4.slots), 1);
    assertEq(Idx_Equipment_TypeNameSlots.get(d4.equipmentType, d4.name, d4.slots, 0), d4.entity);
  }

  // Helper for testDynamicSplices to make repetitive asserts more readable
  function _assert3Names(uint256 idxLength0, uint256 idxLength1, uint256 idxLength2) internal view {
    string memory name0 = "gloves";
    string memory name1 = "gloves1";
    string memory name2 = "gloves2";

    assertEq(Idx_Equipment_Name.length(name0), idxLength0);
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, name0, d1.slots), idxLength0);

    assertEq(Idx_Equipment_Name.length(name1), idxLength1);
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, name1, d1.slots), idxLength1);

    assertEq(Idx_Equipment_Name.length(name2), idxLength2);
    assertEq(Idx_Equipment_TypeNameSlots.length(d1.equipmentType, name2, d1.slots), idxLength2);
  }

  function testDynamicSplices() public {
    EquipmentType equipmentType = d1.equipmentType;
    uint32 level = d1.level;
    bytes32[] memory slots = d1.slots;

    string memory name0 = "gloves";
    string memory name1 = "gloves1";
    string memory name2 = "gloves2";

    Equipment.set(hex"00", equipmentType, level, name0, slots);
    Equipment.set(hex"01", equipmentType, level, name0, slots);

    Equipment.set(hex"10", equipmentType, level, name1, slots);
    Equipment.set(hex"11", equipmentType, level, name1, slots);

    Equipment.set(hex"20", equipmentType, level, name2, slots);
    Equipment.set(hex"21", equipmentType, level, name2, slots);

    _assert3Names(2, 2, 2);

    // Change entity 11 into name0
    StoreSwitch.spliceDynamicData(Equipment._tableId, Equipment.encodeKeyTuple(hex"11"), 0, 6, 1, "");

    _assert3Names(3, 1, 2);

    // Change entity 20 into name1
    StoreSwitch.spliceDynamicData(Equipment._tableId, Equipment.encodeKeyTuple(hex"20"), 0, 6, 1, "1");

    _assert3Names(3, 2, 1);

    // Change entity 21 into name1
    StoreSwitch.spliceDynamicData(Equipment._tableId, Equipment.encodeKeyTuple(hex"21"), 0, 6, 1, "1");

    _assert3Names(3, 3, 0);

    // Change entity 01 into name1
    StoreSwitch.spliceDynamicData(Equipment._tableId, Equipment.encodeKeyTuple(hex"01"), 0, 6, 0, "1");

    _assert3Names(2, 4, 0);

    // Change entity 00 into name2
    StoreSwitch.spliceDynamicData(Equipment._tableId, Equipment.encodeKeyTuple(hex"00"), 0, 6, 0, "2");

    _assert3Names(1, 4, 1);
  }

  function testInvalidBasicGet() public {
    _testSetFirst();

    vm.expectPartialRevert(IStoreErrors.Store_IndexOutOfBounds.selector);
    Idx_Equipment_Level.get(d1.level, 1);
  }
}
