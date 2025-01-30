import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
      "": {
        tables: {
          Equipment: {
            slotName: {
              fields: ["slot", "name"],
            },
          },
        },
      },
    },
  },
  storeConfig,
);
