import { ErrorMessage } from "@ark/util";
import { Table } from "@latticexyz/config";
import { Store } from "@latticexyz/store/internal";
import { TableIdxsInput } from "./input";
import { validateTableIdx, resolveTableIdx } from "./tableIdx";

export type validateTableIdxs<
  tableIdxs,
  storeConfig extends Store,
  namespaceLabel extends string,
  tableLabel extends string,
> = tableIdxs extends readonly unknown[]
  ? {
      [key in keyof tableIdxs]: tableIdxs[key] extends object
        ? validateTableIdx<tableIdxs[key], storeConfig, namespaceLabel, tableLabel>
        : ErrorMessage<`Expected tableIdx config.`>;
    }
  : ErrorMessage<`Expected array of tableIdx configs.`>;

export function validateTableIdxs<storeTable extends Table>(
  input: unknown,
  storeTable: storeTable,
): asserts input is TableIdxsInput {
  if (Array.isArray(input)) {
    for (const tableIdx of input) {
      validateTableIdx(tableIdx, storeTable);
    }
    return;
  }
  throw new Error(`Expected tableIdxs config, received ${JSON.stringify(input)}`);
}

export type resolveTableIdxs<tableIdxs, storeTable extends Table> = {
  readonly [key in keyof tableIdxs]: resolveTableIdx<tableIdxs[key], storeTable>;
};

export function resolveTableIdxs<tableIdxs extends TableIdxsInput, storeTable extends Table>(
  tableIdxs: tableIdxs,
  storeTable: storeTable,
): resolveTableIdxs<tableIdxs, storeTable> {
  return Object.values(tableIdxs).map((tableIdx) => {
    return resolveTableIdx(tableIdx, storeTable);
  }) as never;
}
