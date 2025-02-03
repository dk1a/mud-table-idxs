import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
      root: {
        tables: {
          Equipment: {
            UniqueIdx_Equipment_SlotName: {
              fields: ["slot", "name"],
              unique: true,
            },
            // Not meaningful indexes, just testing various configs
            Idx_Equipment_Entity: {
              fields: ["entity"],
              unique: false,
            },
            Idx_Equipment_SlotLevel: {
              fields: ["slot", "level"],
              unique: false,
            },
            Idx_Equipment_Level: {
              fields: ["level"],
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
