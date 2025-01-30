import fs from "node:fs/promises";
import path from "node:path";
import debug from "debug";
import { formatAndWriteSolidity } from "@latticexyz/common/codegen";
import { uniqueBy } from "@latticexyz/common/utils";
import { getTableOptions } from "@latticexyz/store/codegen";
import { Store as StoreConfig } from "@latticexyz/store";
import { getUserTypes } from "../tempcodegen/getUserTypes";
import { StoreIdxsConfig } from "../config/output";
import { getTableIdxOptions } from "./getTableIdxOptions";
import { renderTableIdx } from "./renderTableIdx";

export type IdxgenOptions = {
  /**
   * MUD project root directory where all other relative paths are resolved from.
   */
  rootDir: string;
  idxsConfig: StoreIdxsConfig;
  storeConfig: StoreConfig;
};

export async function idxgen({ rootDir, idxsConfig, storeConfig }: IdxgenOptions) {
  const userTypes = getUserTypes({ config: storeConfig });

  await Promise.all(
    Object.keys(idxsConfig.namespaces).map(async (namespaceKey) => {
      const storeNamespace = storeConfig.namespaces[namespaceKey];
      const sourceDir = path.join(storeConfig.sourceDirectory, "namespaces", storeNamespace.label);
      const codegenDir = path.join(sourceDir, storeConfig.codegen.outputDirectory);

      const tables = idxsConfig.namespaces[namespaceKey].tables;
      const storeTables = Object.values(storeNamespace.tables);
      if (storeTables.length === 0 || Object.values(tables).length === 0) return;

      const tableOptions = getTableOptions({
        tables: storeTables,
        rootDir,
        codegenDir,
        userTypes,
        storeImportPath: storeConfig.codegen.storeImportPath,
      });

      await Promise.all(
        Object.keys(tables).map(async (tableKey) => {
          const singleTableOptions = tableOptions.find(
            ({ tableName }) => tableName === storeNamespace.tables[tableKey].label,
          );
          if (singleTableOptions === undefined) {
            throw new Error(`No tableOptions for \`${tableKey}\` in namespace \`${namespaceKey}\`.`);
          }

          const tableIdxs = Object.values(tables[tableKey]);

          const tableIdxOptions = getTableIdxOptions({
            tableOptions: singleTableOptions,
            tableIdxs,
            rootDir,
            codegenDir,
            // TODO move to defaults properly or remove the option entirely
            idxImportPath: "@dk1a/mud-table-idxs/src",
          });

          const tableIdxDirs = uniqueBy(
            tableIdxOptions.map(({ outputPath }) => path.dirname(outputPath)),
            (dir) => dir,
          );
          await Promise.all(tableIdxDirs.map((dir) => fs.rm(dir, { recursive: true, force: true })));

          await Promise.all(
            Object.values(tableIdxOptions).map(async ({ outputPath, renderOptions }) => {
              const source = renderTableIdx(renderOptions);
              // TODO without @solidity-parser/parser the bundled version breaks here,
              // probably because of prettier-solidity-plugin
              await formatAndWriteSolidity(source, outputPath, "Generated table idx");
            }),
          );
        }),
      );
    }),
  );

  debug("Generated table idxs");
}
