// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { BasicIdx } from "./codegen/tables/BasicIdx.sol";
import { BasicIdxDynamicFieldIndex } from "./BasicIdxDynamicFieldIndex.sol";

// TODO explain this 2d array approach a bit
library BasicIdx_KeyTuple {
  function length(ResourceId sourceTableId, bytes32 indexesHash, bytes32 valuesHash) internal view returns (uint256) {
    return BasicIdx.lengthKeyParts0(sourceTableId, indexesHash, valuesHash);
  }

  function length(
    IStore store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash
  ) internal view returns (uint256) {
    return BasicIdx.lengthKeyParts0(store, sourceTableId, indexesHash, valuesHash);
  }

  function getItem(
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 index,
    uint256 keyTupleLength
  ) internal view returns (bytes32[] memory keyTuple) {
    keyTuple = new bytes32[](keyTupleLength);
    for (uint8 i; i < keyTupleLength; i++) {
      keyTuple[i] = BasicIdxDynamicFieldIndex.getItemKeyParts(i, sourceTableId, indexesHash, valuesHash, index);
    }
  }

  function getItem(
    IStore store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 index,
    uint256 keyTupleLength
  ) internal view returns (bytes32[] memory keyTuple) {
    keyTuple = new bytes32[](keyTupleLength);
    for (uint8 i; i < keyTupleLength; i++) {
      keyTuple[i] = BasicIdxDynamicFieldIndex.getItemKeyParts(i, store, sourceTableId, indexesHash, valuesHash, index);
    }
  }

  function update(
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 index,
    bytes32[] memory keyTuple
  ) internal {
    for (uint8 i; i < keyTuple.length; i++) {
      BasicIdxDynamicFieldIndex.updateKeyParts(i, sourceTableId, indexesHash, valuesHash, index, keyTuple[i]);
    }
  }

  function update(
    IStore store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 index,
    bytes32[] memory keyTuple
  ) internal {
    for (uint8 i; i < keyTuple.length; i++) {
      BasicIdxDynamicFieldIndex.updateKeyParts(i, store, sourceTableId, indexesHash, valuesHash, index, keyTuple[i]);
    }
  }

  function pop(ResourceId sourceTableId, bytes32 indexesHash, bytes32 valuesHash, uint256 keyTupleLength) internal {
    for (uint8 i; i < keyTupleLength; i++) {
      BasicIdxDynamicFieldIndex.popKeyParts(i, sourceTableId, indexesHash, valuesHash);
    }
  }

  function pop(
    IStore store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 keyTupleLength
  ) internal {
    for (uint8 i; i < keyTupleLength; i++) {
      BasicIdxDynamicFieldIndex.popKeyParts(i, store, sourceTableId, indexesHash, valuesHash);
    }
  }

  function push(ResourceId sourceTableId, bytes32 indexesHash, bytes32 valuesHash, bytes32[] memory keyTuple) internal {
    for (uint8 i; i < keyTuple.length; i++) {
      BasicIdxDynamicFieldIndex.pushKeyParts(i, sourceTableId, indexesHash, valuesHash, keyTuple[i]);
    }
  }

  function push(
    IStore store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    bytes32[] memory keyTuple
  ) internal {
    for (uint8 i; i < keyTuple.length; i++) {
      BasicIdxDynamicFieldIndex.pushKeyParts(i, store, sourceTableId, indexesHash, valuesHash, keyTuple[i]);
    }
  }
}
