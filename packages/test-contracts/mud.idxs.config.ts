import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
      root: {
        tables: {
          Equipment: [
            {
              fields: ["equipmentType", "name"],
              unique: true,
            },
            // Not meaningful indexes, just testing various configs
            {
              fields: ["entity"],
              unique: false,
            },
            {
              fields: ["level"],
              unique: false,
            },
            {
              fields: ["equipmentType", "level"],
              unique: false,
            },
            {
              fields: ["name"],
              unique: false,
            },
            {
              label: "Idx_Equipment_TypeNameSlots",
              fields: ["equipmentType", "name", "slots"],
              unique: false,
            },
          ],
          Position: [
            {
              fields: ["matchEntity", "x", "y"],
              unique: false,
            },
          ],
        },
      },
    },
  },
  storeConfig,
);
