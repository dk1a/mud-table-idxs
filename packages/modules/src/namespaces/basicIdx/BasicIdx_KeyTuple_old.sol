// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { BasicIdx } from "./codegen/tables/BasicIdx.sol";

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
    if (keyTupleLength > 0) {
      keyTuple[0] = BasicIdx.getItemKeyParts0(sourceTableId, indexesHash, valuesHash, index);

      if (keyTupleLength > 1) {
        keyTuple[1] = BasicIdx.getItemKeyParts1(sourceTableId, indexesHash, valuesHash, index);

        if (keyTupleLength > 2) {
          keyTuple[2] = BasicIdx.getItemKeyParts2(sourceTableId, indexesHash, valuesHash, index);

          if (keyTupleLength > 3) {
            keyTuple[3] = BasicIdx.getItemKeyParts3(sourceTableId, indexesHash, valuesHash, index);

            if (keyTupleLength > 4) {
              keyTuple[4] = BasicIdx.getItemKeyParts4(sourceTableId, indexesHash, valuesHash, index);
            }
          }
        }
      }
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
    if (keyTupleLength > 0) {
      keyTuple[0] = BasicIdx.getItemKeyParts0(store, sourceTableId, indexesHash, valuesHash, index);

      if (keyTupleLength > 1) {
        keyTuple[1] = BasicIdx.getItemKeyParts1(store, sourceTableId, indexesHash, valuesHash, index);

        if (keyTupleLength > 2) {
          keyTuple[2] = BasicIdx.getItemKeyParts2(store, sourceTableId, indexesHash, valuesHash, index);

          if (keyTupleLength > 3) {
            keyTuple[3] = BasicIdx.getItemKeyParts3(store, sourceTableId, indexesHash, valuesHash, index);

            if (keyTupleLength > 4) {
              keyTuple[4] = BasicIdx.getItemKeyParts4(store, sourceTableId, indexesHash, valuesHash, index);
            }
          }
        }
      }
    }
  }

  function update(
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 index,
    bytes32[] memory keyTuple
  ) internal {
    if (keyTuple.length > 0) {
      BasicIdx.updateKeyParts0(sourceTableId, indexesHash, valuesHash, index, keyTuple[0]);

      if (keyTuple.length > 1) {
        BasicIdx.updateKeyParts1(sourceTableId, indexesHash, valuesHash, index, keyTuple[1]);

        if (keyTuple.length > 2) {
          BasicIdx.updateKeyParts2(sourceTableId, indexesHash, valuesHash, index, keyTuple[2]);

          if (keyTuple.length > 3) {
            BasicIdx.updateKeyParts3(sourceTableId, indexesHash, valuesHash, index, keyTuple[3]);

            if (keyTuple.length > 4) {
              BasicIdx.updateKeyParts4(sourceTableId, indexesHash, valuesHash, index, keyTuple[4]);
            }
          }
        }
      }
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
    if (keyTuple.length > 0) {
      BasicIdx.updateKeyParts0(store, sourceTableId, indexesHash, valuesHash, index, keyTuple[0]);

      if (keyTuple.length > 1) {
        BasicIdx.updateKeyParts1(store, sourceTableId, indexesHash, valuesHash, index, keyTuple[1]);

        if (keyTuple.length > 2) {
          BasicIdx.updateKeyParts2(store, sourceTableId, indexesHash, valuesHash, index, keyTuple[2]);

          if (keyTuple.length > 3) {
            BasicIdx.updateKeyParts3(store, sourceTableId, indexesHash, valuesHash, index, keyTuple[3]);

            if (keyTuple.length > 4) {
              BasicIdx.updateKeyParts4(store, sourceTableId, indexesHash, valuesHash, index, keyTuple[4]);
            }
          }
        }
      }
    }
  }

  function pop(ResourceId sourceTableId, bytes32 indexesHash, bytes32 valuesHash, uint256 keyTupleLength) internal {
    if (keyTupleLength > 0) {
      BasicIdx.popKeyParts0(sourceTableId, indexesHash, valuesHash);

      if (keyTupleLength > 1) {
        BasicIdx.popKeyParts1(sourceTableId, indexesHash, valuesHash);

        if (keyTupleLength > 2) {
          BasicIdx.popKeyParts2(sourceTableId, indexesHash, valuesHash);

          if (keyTupleLength > 3) {
            BasicIdx.popKeyParts3(sourceTableId, indexesHash, valuesHash);

            if (keyTupleLength > 4) {
              BasicIdx.popKeyParts4(sourceTableId, indexesHash, valuesHash);
            }
          }
        }
      }
    }
  }

  function pop(
    IStore store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    uint256 keyTupleLength
  ) internal {
    if (keyTupleLength > 0) {
      BasicIdx.popKeyParts0(store, sourceTableId, indexesHash, valuesHash);

      if (keyTupleLength > 1) {
        BasicIdx.popKeyParts1(store, sourceTableId, indexesHash, valuesHash);

        if (keyTupleLength > 2) {
          BasicIdx.popKeyParts2(store, sourceTableId, indexesHash, valuesHash);

          if (keyTupleLength > 3) {
            BasicIdx.popKeyParts3(store, sourceTableId, indexesHash, valuesHash);

            if (keyTupleLength > 4) {
              BasicIdx.popKeyParts4(store, sourceTableId, indexesHash, valuesHash);
            }
          }
        }
      }
    }
  }

  function push(ResourceId sourceTableId, bytes32 indexesHash, bytes32 valuesHash, bytes32[] memory keyTuple) internal {
    if (keyTuple.length > 0) {
      BasicIdx.pushKeyParts0(sourceTableId, indexesHash, valuesHash, keyTuple[0]);

      if (keyTuple.length > 1) {
        BasicIdx.pushKeyParts1(sourceTableId, indexesHash, valuesHash, keyTuple[1]);

        if (keyTuple.length > 2) {
          BasicIdx.pushKeyParts2(sourceTableId, indexesHash, valuesHash, keyTuple[2]);

          if (keyTuple.length > 3) {
            BasicIdx.pushKeyParts3(sourceTableId, indexesHash, valuesHash, keyTuple[3]);

            if (keyTuple.length > 4) {
              BasicIdx.pushKeyParts4(sourceTableId, indexesHash, valuesHash, keyTuple[4]);
            }
          }
        }
      }
    }
  }

  function push(
    IStore store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bytes32 valuesHash,
    bytes32[] memory keyTuple
  ) internal {
    if (keyTuple.length > 0) {
      BasicIdx.pushKeyParts0(store, sourceTableId, indexesHash, valuesHash, keyTuple[0]);

      if (keyTuple.length > 1) {
        BasicIdx.pushKeyParts1(store, sourceTableId, indexesHash, valuesHash, keyTuple[1]);

        if (keyTuple.length > 2) {
          BasicIdx.pushKeyParts2(store, sourceTableId, indexesHash, valuesHash, keyTuple[2]);

          if (keyTuple.length > 3) {
            BasicIdx.pushKeyParts3(store, sourceTableId, indexesHash, valuesHash, keyTuple[3]);

            if (keyTuple.length > 4) {
              BasicIdx.pushKeyParts4(store, sourceTableId, indexesHash, valuesHash, keyTuple[4]);
            }
          }
        }
      }
    }
  }
}
