// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";

// Import idx internals
import { Uint8Map, Uint8MapLib } from "@dk1a/mud-table-idxs/src/Uint8Map.sol";
import { hashIndexes, hashValues } from "@dk1a/mud-table-idxs/src/utils.sol";

import { IIdxErrors } from "@dk1a/mud-table-idxs/src/IIdxErrors.sol";

import { registerUniqueIdx } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/registerUniqueIdx.sol";
import { UniqueIdx } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/codegen/tables/UniqueIdx.sol";

// Import user types
import { EquipmentType } from "../../../../codegen/common.sol";

library UniqueIdx_Equipment_TypeName {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Equipment", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462000000000000000000000000000045717569706d656e7400000000000000);

  uint256 constant _keyNumber = 0;
  uint256 constant _fieldNumber = 2;

  Uint8Map constant _keyIndexes = Uint8Map.wrap(0x0000000000000000000000000000000000000000000000000000000000000000);
  Uint8Map constant _fieldIndexes = Uint8Map.wrap(0x0200020000000000000000000000000000000000000000000000000000000000);

  bytes32 constant _indexesHash = 0xc5b3d1bcb4537e0f59045c610d26e1b8695de46428683ca630b31174203c999c;

  function valuesHash(EquipmentType equipmentType, string memory name) internal pure returns (bytes32) {
    bytes32[] memory _partialKeyTuple = new bytes32[](_keyNumber);

    bytes[] memory _partialValues = new bytes[](_fieldNumber);

    _partialValues[0] = abi.encodePacked(uint8(equipmentType));

    _partialValues[1] = bytes((name));

    return hashValues(_partialKeyTuple, _partialValues);
  }

  // Should be called once in e.g. PostDeploy
  function register() internal {
    registerUniqueIdx(_tableId, _keyIndexes, _fieldIndexes);
  }

  function has(EquipmentType equipmentType, string memory name) internal view returns (bool) {
    bytes32 _valuesHash = valuesHash(equipmentType, name);

    return UniqueIdx.length(_tableId, _indexesHash, _valuesHash) > 0;
  }

  function getKeyTuple(
    EquipmentType equipmentType,
    string memory name
  ) internal view returns (bytes32[] memory _keyTuple) {
    bytes32 _valuesHash = valuesHash(equipmentType, name);

    _keyTuple = UniqueIdx.get(_tableId, _indexesHash, _valuesHash);

    if (_keyTuple.length == 0) {
      revert IIdxErrors.UniqueIdx_InvalidGet({
        tableId: _tableId,
        libraryName: "UniqueIdx_Equipment_TypeName",
        valuesBlob: abi.encodePacked(equipmentType, name),
        indexesHash: _indexesHash,
        valuesHash: _valuesHash
      });
    }
  }

  function get(EquipmentType equipmentType, string memory name) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = getKeyTuple(equipmentType, name);

    entity = _keyTuple[0];
  }

  /**
   * @notice Decode keys from a bytes32 array using the source table's field layout.
   */
  function decodeKeyTuple(bytes32[] memory _keyTuple) internal pure returns (bytes32 entity) {
    entity = _keyTuple[0];
  }
}
