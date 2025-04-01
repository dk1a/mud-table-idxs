import { ErrorMessage } from "@ark/util";
import { Tables } from "@latticexyz/config";
import { get, hasOwnKey, isObject, Store } from "@latticexyz/store/internal";
import { TablesInput } from "./input";
import { validateTableIdxs, resolveTableIdxs } from "./tableIdxs";

export type validateTables<tables, storeConfig extends Store, namespaceLabel extends string> = {
  [label in keyof tables]: tables[label] extends object
    ? label extends string
      ? label extends keyof storeConfig["namespaces"][namespaceLabel]["tables"]
        ? validateTableIdxs<tables[label], storeConfig, namespaceLabel, label>
        : ErrorMessage<`Table \`${label & string}\` does not exist in the referenced store config.`>
      : ErrorMessage<`Expected table keys to be strings.`>
    : ErrorMessage<`Expected tables config.`>;
};

export function validateTables<storeTables extends Tables>(
  input: unknown,
  storeTables: storeTables,
): asserts input is TablesInput {
  if (isObject(input)) {
    for (const label of Object.keys(input)) {
      if (!hasOwnKey(storeTables, label)) {
        throw new Error(`Table \`${label}\` does not exist in the referenced store config.`);
      }
      if (storeTables[label].key.length === 0) {
        throw new Error(`Table \`${label}\` is a singleton without keys, and can not have idxs.`);
      }

      const tableIdxs: unknown = get(input, label);
      validateTableIdxs(tableIdxs, storeTables[label]);
    }
    return;
  }
  throw new Error(`Expected tables config, received ${JSON.stringify(input)}`);
}

export type resolveTables<tables, storeTables extends Tables> = {
  readonly [label in keyof tables]: resolveTableIdxs<tables[label], label extends string ? storeTables[label] : never>;
};

export function resolveTables<tables extends TablesInput, storeTables extends Tables>(
  tables: tables,
  storeTables: storeTables,
): resolveTables<tables, storeTables> {
  return Object.fromEntries(
    Object.entries(tables).map(([label, table]) => {
      return [label, resolveTableIdxs(table, storeTables[label])];
    }),
  ) as never;
}
