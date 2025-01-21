import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  userTypes: {
    ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", type: "bytes32" },
    Uint8Map: { filePath: "./src/Uint8Map.sol", type: "bytes32" },
  },
  namespaces: {
    uniqueIdx: {
      tables: {
        /************************************************************************
         *
         *    UNIQUE INDEX MODULE
         *
         ************************************************************************/
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
          codegen: {
            storeArgument: true,
          },
        },
      },
    },
  },
});
