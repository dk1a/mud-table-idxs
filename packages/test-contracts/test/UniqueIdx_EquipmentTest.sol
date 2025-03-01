// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { IStoreHook } from "@latticexyz/store/src/IStoreHook.sol";

import { UniqueIdxMetadata } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/codegen/tables/UniqueIdxMetadata.sol";
import { UniqueIdxHook } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/UniqueIdxHook.sol";

import { BaseTest } from "./BaseTest.t.sol";

import { EquipmentType } from "../src/codegen/common.sol";
import { Equipment } from "../src/namespaces/root/codegen/tables/Equipment.sol";
import { UniqueIdx_Equipment_TypeName } from "../src/namespaces/root/codegen/idxs/UniqueIdx_Equipment_TypeName.sol";

struct TestData {
  bytes32 entity;
  EquipmentType equipmentType;
  uint32 level;
  string name;
  bytes32[] slots;
}

contract UniqueIdx_EquipmentTest is BaseTest {
  address hookAddress;

  TestData d1;

  function setUp() public virtual override {
    super.setUp();

    // This idx is not globally registered in PostDeploy
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startPrank(vm.addr(deployerPrivateKey));
    UniqueIdx_Equipment_TypeName.register();
    vm.stopPrank();

    hookAddress = UniqueIdxMetadata.getHookAddress(Equipment._tableId, UniqueIdx_Equipment_TypeName._indexesHash);

    bytes32[] memory d1Slots = new bytes32[](1);
    d1Slots[0] = "Hands";
    d1 = TestData({ entity: hex"1a", equipmentType: EquipmentType.Armor, level: 5, name: "gloves", slots: d1Slots });
  }

  function _expectCallHook(
    uint64 setRecordCount,
    uint64 spliceStaticCount,
    uint64 spliceDynamicCount,
    uint64 deleteCount
  ) internal {
    _expectCallHook({
      hookAddress: hookAddress,
      tableId: Equipment._tableId,
      setRecordCount: setRecordCount,
      spliceStaticCount: spliceStaticCount,
      spliceDynamicCount: spliceDynamicCount,
      deleteCount: deleteCount
    });
  }

  function testGet() public {
    _expectCallHook({ setRecordCount: 1, spliceStaticCount: 0, spliceDynamicCount: 0, deleteCount: 0 });

    Equipment.set(d1.entity, d1.equipmentType, d1.level, d1.name, d1.slots);

    assertEq(UniqueIdx_Equipment_TypeName.get(d1.equipmentType, d1.name), d1.entity);
  }

  function testSetUniqueDuplicateError() public {
    Equipment.set(d1.entity, d1.equipmentType, d1.level, d1.name, d1.slots);

    vm.expectPartialRevert(UniqueIdxHook.UniqueIdxHook_UniqueValueDuplicate.selector);
    Equipment.set(hex"1b", d1.equipmentType, d1.level, d1.name, d1.slots);
  }
}
