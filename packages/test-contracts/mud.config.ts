import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  userTypes: {
    ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", type: "bytes32" },
    Uint8Map: { filePath: "./src/Uint8Map.sol", type: "bytes32" },
  },
  namespaces: {
    "": {
      tables: {
        Equipment: {
          key: ["entity"],
          schema: {
            entity: "bytes32",
            slot: "bytes32",
            level: "uint32",
            name: "string",
          },
        },
      },
    },
  },
  modules: [
    {
      artifactPath: "@dk1a/mud-table-idxs/out/UniqueIdxModule.sol/UniqueIdxModule.json",
      root: false,
    },
  ],
});
