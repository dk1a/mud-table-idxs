import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
      root: {
        tables: {
          Equipment: {
            UniqueIdx_Equipment_TypeName: {
              fields: ["equipmentType", "name"],
              unique: true,
            },
            // Not meaningful indexes, just testing various configs
            Idx_Equipment_Entity: {
              fields: ["entity"],
              unique: false,
            },
            Idx_Equipment_Level: {
              fields: ["level"],
              unique: false,
            },
            Idx_Equipment_TypeLevel: {
              fields: ["equipmentType", "level"],
              unique: false,
            },
            Idx_Equipment_Name: {
              fields: ["name"],
              unique: false,
            },
            Idx_Equipment_TypeNameSlots: {
              fields: ["equipmentType", "name", "slots"],
              unique: false,
            },
          },
          Position: {
            Idx_Position_MatchEntityXY: {
              fields: ["matchEntity", "x", "y"],
              unique: false,
            },
          },
        },
      },
    },
  },
  storeConfig,
);
