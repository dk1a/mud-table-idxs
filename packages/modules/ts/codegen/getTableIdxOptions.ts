import path from "path";
import { maxUint8 } from "viem";
import { ImportDatum, RenderField, RenderStaticField } from "@latticexyz/common/codegen";
import { isDefined } from "@latticexyz/common/utils";
import { TableOptions } from "@latticexyz/store/codegen";
import { RenderTableIdxOptions } from "./types";
import { TableIdx } from "../config/output";
import { UserType } from "../tempcodegen/getUserTypes";

export interface TableIdxOptions {
  /** Path where the file is expected to be written (relative to project root) */
  outputPath: string;
  /** Name of the idx, as used in filename and library name */
  idxName: string;
  /** Options for `renderTableIdx` function */
  renderOptions: RenderTableIdxOptions;
}

/**
 * Transforms store and idx configs into useful options for `idxgen` and `renderTableIdx`
 */
export function getTableIdxOptions({
  tableOptions,
  tableIdxs,
  rootDir,
  codegenDir,
  userTypes,
  idxImportPath,
}: {
  readonly tableOptions: TableOptions;
  readonly tableIdxs: TableIdx[];
  readonly rootDir: string;
  /** namespace codegen output dir, relative to project root dir */
  readonly codegenDir: string;
  readonly userTypes: readonly UserType[];
  /** absolute import path or, if starting with `.`, relative to project root dir */
  readonly idxImportPath: string;
}): TableIdxOptions[] {
  const options = tableIdxs.map((tableIdx): TableIdxOptions => {
    const outputPath = path.join(rootDir, codegenDir, tableIdx.codegen.outputDirectory, `${tableIdx.label}.sol`);

    // TODO is the cast unavoidable?
    // Static fields have `arrayElement: undefined`, whereas keyTuple lacks `arrayElement` entirely
    const keyFields = tableOptions.renderOptions.keyTuple as RenderStaticField[];

    const [selectedKeys, selectedKeyIndexes] = selectFieldsAndIndexes(tableIdx.fields, keyFields);
    const [selectedFields, selectedFieldIndexes] = selectFieldsAndIndexes(
      tableIdx.fields,
      tableOptions.renderOptions.fields,
    );

    // list of any symbols that need to be imported
    const imports = [...selectedKeys, ...selectedFields]
      .map((field) => userTypes.find((type) => type.name === field.typeId))
      .filter(isDefined)
      .map((userType): ImportDatum => {
        return {
          // If it's a fully qualified name, remove trailing references
          // This enables support for user types inside libraries
          symbol: userType.name.replace(/\..*$/, ""),
          path: userType.importPath.startsWith(".")
            ? "./" + path.relative(path.dirname(outputPath), path.join(rootDir, userType.importPath))
            : userType.importPath,
        };
      });

    return {
      outputPath,
      idxName: tableIdx.label,
      renderOptions: {
        imports,
        libraryName: tableIdx.label,
        unique: tableIdx.unique,
        staticResourceData: tableOptions.renderOptions.staticResourceData,
        storeImportPath: tableOptions.renderOptions.storeImportPath,
        idxImportPath: idxImportPath.startsWith(".")
          ? "./" + path.relative(path.dirname(outputPath), path.join(rootDir, idxImportPath))
          : idxImportPath,
        keyTuple: tableOptions.renderOptions.keyTuple,
        fields: tableOptions.renderOptions.fields,
        selectedKeys,
        selectedKeyIndexes,
        selectedFields,
        selectedFieldIndexes,
        storeArgument: tableOptions.renderOptions.storeArgument,
      },
    };
  });

  return options;
}

function selectFieldsAndIndexes<T extends RenderField>(
  selectedNames: readonly string[],
  fields: readonly T[],
): [T[], Uint8Array] {
  if (fields.length > maxUint8) {
    throw new Error(`Invalid size of allFields: ${fields.length}`);
  }

  const selectedFields = [];
  const selectedIndexes = [];
  for (let i = 0; i < fields.length; i++) {
    const field = fields[i];
    if (selectedNames.includes(field.name)) {
      selectedFields.push(field);
      selectedIndexes.push(i);
    }
  }

  return [selectedFields, new Uint8Array(selectedIndexes)];
}
