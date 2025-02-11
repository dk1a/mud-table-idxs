WIP, everything is subject to change

This is a package used on top of [MUD](https://github.com/latticexyz/mud) to create onchain indexes (think sql table indexes, basic or unique) for MUD tables.

It generates idx libraries, similar to MUD table libraries, using a secondary config derived from MUD config.

## Howto

Install the package:

```bash copy
pnpm add @dk1a/mud-table-idxs
```

Include idx modules in your `mud.config.ts`:

```ts
import { basicIdxModule, uniqueIdxModule } from "@dk1a/mud-table-idxs";
...

export default defineWorld({
  ...
  modules: [basicIdxModule, uniqueIdxModule],
  ...
});
```

Next to `mud.config.ts` add a file `mud.idxs.config.ts` (the name isn't important) like this:

```ts
import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
      root: {
        tables: {
          YourMudTable: {
            // Name your idx library however you want, onchain they are identified by their options/fields
            // (which is why you can't have 2 identical idxs that differ only by name)
            Idx_YourMudTable_Fields12: {
              fields: ["field1", "field2"],
              unique: false,
            },
          },
        },
      },
    },
  },
  storeConfig,
);
```

Then add `./ts/scripts/generate-idxs.ts` (the specific path/name isn't important) like this:

```ts
import path from "node:path";
import { fileURLToPath } from "node:url";
import { idxgen } from "@dk1a/mud-table-idxs";

import storeConfig from "../../mud.config";
// TODO change this if you named your idxs config something else
import idxsConfig from "../../mud.idxs.config";

const rootDir = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../..",
);

await idxgen({ rootDir, idxsConfig, storeConfig });
```

Finally call `generate-idxs.ts` in your `package.json`, **before(!)** `mud build`, e.g.:

```json
{
  "scripts": {
    "build": "pnpm run build:mudidx && pnpm run build:mud",
    "build:mudidx": "tsx ./ts/scripts/generate-test-idxs.ts",
    "build:mud": "mud build",
    ...
  }
}
```

## Description

`idx` is used for these onchain table indexes, instead of `index`, which is too generic a term and hard to search/refactor.

`mud-table-idxs` are beast compared to MUD's [KeysWithValue module](https://mud.dev/world/modules/keyswithvalue), which is essentially a basic onchain index, but it only indexes all non-key values at once, and has no typed codegen.

`mud-table-idxs` indexes any combination of fields, which can include key fields.

Caveats:

- Using only key fields for unique indexes isn't allowed, I assume there is no valid use-case for this, you should just change the number of key fields in your table's mud config
- Using only key fields for basic indexes is allowed, but the generated library will lack some methods, and using [KeysInTable module](https://mud.dev/world/modules/keysintable) instead of this will probably be more efficient
- Index libraries use the full primary key and the indexed fields as arguments/returns. So using key fields for indexes will exclude duplicate key arguments/returns from relevant methods (TODO explain this better with examples)
- This uses world modules and doesn't work with standalone store
