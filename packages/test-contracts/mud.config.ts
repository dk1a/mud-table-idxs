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
            slot: "EquipmentSlot",
            level: "uint32",
            name: "string",
          },
        },
      },
    },
  },
  enums: {
    EquipmentSlot: ["Armor", "Weapon"],
  },
  modules: [basicIdxModule, uniqueIdxModule],
});
