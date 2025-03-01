// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { BasicIdx } from "./codegen/tables/BasicIdx.sol";

// TODO consider forking `store/ts/codegen/field.ts` to codegen this
/**
 * Manually modified BasicIdx where methods take fieldIndex as argument instead of having it be part of the field name
 * E.g. you would call `getItemKeyParts(0, ...)` instead of `getItemKeyParts0(...)`, otherwise the methods are identical
 * This simulates a 2d array with less hardcode, and works because all the fields have the same dynamic type
 * The main advantage is significant codesize reduction, since it's 4 methods instead of 20 (5 of each getItem/update/pop/push)
 * But at the cost of having to manually maintain a copy of the needed methods from BasicIdx
 */
library BasicIdxDynamicFieldIndex {
  ResourceId constant _tableId = BasicIdx._tableId;

  function getItemKeyParts(
    uint8 _fieldIndex,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 _index
  ) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(
        _tableId,
        _keyTuple,
        _fieldIndex,
        _index * 32,
        (_index + 1) * 32
      );
      return (bytes32(_blob));
    }
  }

  function getItemKeyParts(
    uint8 _fieldIndex,
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 _index
  ) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    unchecked {
      bytes memory _blob = _store.getDynamicFieldSlice(
        _tableId,
        _keyTuple,
        _fieldIndex,
        _index * 32,
        (_index + 1) * 32
      );
      return (bytes32(_blob));
    }
  }

  function pushKeyParts(
    uint8 _fieldIndex,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    bytes32 _element
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, _fieldIndex, abi.encodePacked((_element)));
  }

  function pushKeyParts(
    uint8 _fieldIndex,
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    bytes32 _element
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    _store.pushToDynamicField(_tableId, _keyTuple, _fieldIndex, abi.encodePacked((_element)));
  }

  function popKeyParts(uint8 _fieldIndex, ResourceId sourceTableId, bytes32 indexesHash, bytes32 valuesHash) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, _fieldIndex, 32);
  }

  function popKeyParts(
    uint8 _fieldIndex,
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    _store.popFromDynamicField(_tableId, _keyTuple, _fieldIndex, 32);
  }

  function updateKeyParts(
    uint8 _fieldIndex,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 _index,
    bytes32 _element
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(
        _tableId,
        _keyTuple,
        _fieldIndex,
        uint40(_index * 32),
        uint40(_encoded.length),
        _encoded
      );
    }
  }

  function updateKeyParts(
    uint8 _fieldIndex,
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 _index,
    bytes32 _element
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;
    _keyTuple[2] = valuesHash;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      _store.spliceDynamicData(
        _tableId,
        _keyTuple,
        _fieldIndex,
        uint40(_index * 32),
        uint40(_encoded.length),
        _encoded
      );
    }
  }
}
