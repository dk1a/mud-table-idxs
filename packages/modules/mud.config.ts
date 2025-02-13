import { defineWorld } from "@latticexyz/world";

const tableIdxMetadata = {
  key: ["sourceTableId", "indexesHash"],
  schema: {
    sourceTableId: "ResourceId",
    // Hash of key and field indexes - 1 per table hook
    indexesHash: "bytes32",
    has: "bool",
    hookAddress: "address",
    keyIndexes: "Uint8Map",
    fieldIndexes: "Uint8Map",
    staticIndexes: "Uint8Map",
    dynamicIndexes: "Uint8Map",
  },
} as const;

export default defineWorld({
  userTypes: {
    ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", type: "bytes32" },
    Uint8Map: { filePath: "./src/Uint8Map.sol", type: "bytes32" },
  },
  namespaces: {
    /************************************************************************
     *
     *    BASIC INDEX MODULE
     *
     ************************************************************************/
    basicIdx: {
      tables: {
        BasicIdx: {
          schema: {
            sourceTableId: "ResourceId",
            // Hash of key and field indexes - 1 per table hook
            indexesHash: "bytes32",
            // Hash of key and field values - 1 per table row
            valuesHash: "bytes32",
            // The indexed values hash may be associated with any number of keys
            // But the indexed table's keyTuple length cannot be greater than 5
            keyParts0: "bytes32[]",
            keyParts1: "bytes32[]",
            keyParts2: "bytes32[]",
            keyParts3: "bytes32[]",
            keyParts4: "bytes32[]",
          },
          key: ["sourceTableId", "indexesHash", "valuesHash"],
          codegen: {
            storeArgument: true,
          },
        },
        BasicIdxUsedKeys: {
          schema: {
            sourceTableId: "ResourceId",
            // Hash of key and field indexes - 1 per table hook
            indexesHash: "bytes32",
            // Hash of keyTuple (the combination of keyParts)
            keyTupleHash: "bytes32",
            has: "bool",
            index: "uint40",
          },
          key: ["sourceTableId", "indexesHash", "keyTupleHash"],
          codegen: {
            dataStruct: false,
            storeArgument: true,
          },
        },
        BasicIdxMetadata: {
          ...tableIdxMetadata,
          codegen: {
            storeArgument: true,
          },
        },
      },
    },
    /************************************************************************
     *
     *    UNIQUE INDEX MODULE
     *
     ************************************************************************/
    uniqueIdx: {
      tables: {
        UniqueIdx: {
          key: ["sourceTableId", "indexesHash", "valuesHash"],
          schema: {
            sourceTableId: "ResourceId",
            // Hash of key and field indexes - 1 per table hook
            indexesHash: "bytes32",
            // Hash of key and field values - 1 per table row
            valuesHash: "bytes32",
            // The unique values hash may at most be associated with 1 keyTuple of the original table
            keyTuple: "bytes32[]",
          },
          codegen: {
            storeArgument: true,
          },
        },
        UniqueIdxMetadata: {
          ...tableIdxMetadata,
          codegen: {
            storeArgument: true,
          },
        },
      },
    },
  },
});
