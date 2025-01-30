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
            },
          },
        },
      },
    },
  },
  storeConfig,
);
