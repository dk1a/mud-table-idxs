import { ErrorMessage, show } from "@ark/util";
import { TableIdxInput } from "./input";
import { get, hasOwnKey, Store } from "@latticexyz/store/internal";
import { Table } from "@latticexyz/config";
import { TableIdxCodegen } from "./output";
import { TABLE_IDX_CODEGEN_DEFAULTS } from "./defaults";

export type validateFields<validFields extends PropertyKey, fields> = fields extends readonly string[]
  ? {
      readonly [i in keyof fields]: fields[i] extends validFields ? fields[i] : validFields;
    }
  : readonly string[];

export function validateFields<storeTable extends Table>(
  validFields: (keyof storeTable["schema"])[],
  fields: unknown,
): asserts fields is (keyof storeTable["schema"])[] {
  const isValid = Array.isArray(fields) && fields.every((field) => validFields.includes(field));

  if (!isValid) {
    throw new Error(
      `Invalid key. Expected \`(${validFields.map((item) => `"${String(item)}"`).join(" | ")})[]\`, received \`${
        Array.isArray(fields) ? `[${fields.map((item) => `"${item}"`).join(", ")}]` : String(fields)
      }\``,
    );
  }
}

// TODO fix store labels, they dont narrow
export type validateTableIdx<
  input,
  storeConfig extends Store,
  namespaceLabel extends string,
  tableLabel extends string,
> = {
  [key in keyof input]: key extends "fields"
    ? validateFields<keyof storeConfig["namespaces"][namespaceLabel]["tables"][tableLabel]["schema"], get<input, key>>
    : key extends keyof TableIdxInput
      ? TableIdxInput[key]
      : ErrorMessage<`Key \`${key & string}\` does not exist in TableIdxInput`>;
};

export function validateTableIdx<input, storeTable extends Table>(
  input: input,
  storeTable: storeTable,
): asserts input is TableIdxInput & input {
  if (typeof input !== "object" || input == null) {
    throw new Error(`Expected full tableIdx config, got \`${JSON.stringify(input)}\``);
  }

  if (!hasOwnKey(input, "fields")) {
    throw new Error("Missing fields input");
  }
  validateFields(Object.keys(storeTable.schema), input.fields);
}

export type resolveTableIdxCodegen<input extends TableIdxInput> = show<{
  [key in keyof TableIdxCodegen]-?: key extends keyof input["codegen"]
    ? undefined extends input["codegen"][key]
      ? key extends keyof TABLE_IDX_CODEGEN_DEFAULTS
        ? TABLE_IDX_CODEGEN_DEFAULTS[key]
        : never
      : input["codegen"][key]
    : key extends keyof TABLE_IDX_CODEGEN_DEFAULTS
      ? TABLE_IDX_CODEGEN_DEFAULTS[key]
      : never;
}>;

export function resolveTableIdxCodegen<input extends TableIdxInput>(input: input): resolveTableIdxCodegen<input> {
  const options = input.codegen;
  return {
    outputDirectory: get(options, "outputDirectory") ?? TABLE_IDX_CODEGEN_DEFAULTS.outputDirectory,
    tableIdArgument: get(options, "tableIdArgument") ?? TABLE_IDX_CODEGEN_DEFAULTS.tableIdArgument,
    storeArgument: get(options, "storeArgument") ?? TABLE_IDX_CODEGEN_DEFAULTS.storeArgument,
  } satisfies TableIdxCodegen as never;
}

export type resolveTableIdx<input, storeTable extends Table> = input extends TableIdxInput
  ? {
      readonly fields: keyof storeTable["schema"];
      readonly unique: boolean;
    }
  : never;

export function resolveTableIdx<input extends TableIdxInput, storeTable extends Table>(
  input: input,
  storeTable: storeTable,
): resolveTableIdx<input, storeTable> {
  const label = input.label;
  const fields = input.fields;
  const unique = input.unique ?? true;

  input.codegen;

  return {
    label,
    fields,
    unique,
    codegen: resolveTableIdxCodegen(input),
  } as never;
}
