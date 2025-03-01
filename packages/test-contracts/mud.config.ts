import { basicIdxModule, uniqueIdxModule } from "@dk1a/mud-table-idxs";
import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  userTypes: {
    ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", type: "bytes32" },
    Uint8Map: { filePath: "./src/Uint8Map.sol", type: "bytes32" },
  },
  namespaces: {
    root: {
      namespace: "",
      tables: {
        Position: {
          key: ["matchEntity", "entity"],
          schema: {
            matchEntity: "bytes32",
            entity: "bytes32",
            x: "int32",
            y: "int32",
          },
        },
        Equipment: {
          key: ["entity"],
          schema: {
            entity: "bytes32",
            equipmentType: "EquipmentType",
            level: "uint32",
            name: "string",
            slots: "bytes32[]",
          },
        },
      },
    },
  },
  enums: {
    EquipmentType: ["Armor", "Weapon"],
  },
  modules: [
    {
      artifactPath: "@latticexyz/world-modules/out/StandardDelegationsModule.sol/StandardDelegationsModule.json",
      root: true,
      args: [],
    },
    basicIdxModule,
    uniqueIdxModule,
  ],
});
