import { ErrorMessage } from "@ark/util";
import { Table } from "@latticexyz/config";
import { isObject, mergeIfUndefined, Store } from "@latticexyz/store/internal";
import { TableIdxsInput } from "./input";
import { validateTableIdx, resolveTableIdx } from "./tableIdx";

export type validateTableIdxs<
  tableIdxs,
  storeConfig extends Store,
  namespaceLabel extends string,
  tableLabel extends string,
> = {
  [label in keyof tableIdxs]: tableIdxs[label] extends object
    ? validateTableIdx<tableIdxs[label], storeConfig, namespaceLabel, tableLabel>
    : ErrorMessage<`Expected tableIdxs config.`>;
};

export function validateTableIdxs<storeTable extends Table>(
  input: unknown,
  storeTable: storeTable,
): asserts input is TableIdxsInput {
  if (isObject(input)) {
    for (const tableIdx of Object.values(input)) {
      validateTableIdx(tableIdx, storeTable);
    }
    return;
  }
  throw new Error(`Expected tableIdxs config, received ${JSON.stringify(input)}`);
}

export type resolveTableIdxs<tableIdxs, storeTable extends Table> = {
  readonly [label in keyof tableIdxs]: resolveTableIdx<
    mergeIfUndefined<tableIdxs[label], { readonly label: label }>,
    storeTable
  >;
};

export function resolveTableIdxs<tableIdxs extends TableIdxsInput, storeTable extends Table>(
  tableIdxs: tableIdxs,
  storeTable: storeTable,
): resolveTableIdxs<tableIdxs, storeTable> {
  return Object.fromEntries(
    Object.entries(tableIdxs).map(([label, tableIdx]) => {
      return [label, resolveTableIdx(mergeIfUndefined(tableIdx, { label }), storeTable)];
    }),
  ) as never;
}
