import { Table } from "@latticexyz/config";
import { TableIdxInput } from "./input";

const prefixBasic = "Idx" as const;
const prefixUnique = "UniqueIdx" as const;

/**
 * For a tuple of string literals this is like a `.join()`
 * E.g. returns `"Value1Value2"` for `["value1", "Value2"]`
 * Returns the basic `string` type if it's not a tuple of string literals (i.e. `string[]` or `[string, string]`)
 */
type JoinAndCapitalizeTupleOfStringLiterals<T, Result extends string = ""> = T extends [
  infer First extends string,
  ...infer Rest,
]
  ? string extends First
    ? string
    : JoinAndCapitalizeTupleOfStringLiterals<Rest, `${Result}${Capitalize<First>}`>
  : [] extends T
    ? string extends Result
      ? string
      : Result
    : string;

type TableLabelPrefix<input extends TableIdxInput> = input["unique"] extends true
  ? typeof prefixUnique
  : input["unique"] extends false
    ? typeof prefixBasic
    : string;

type JoinIfLiteral<Prefix extends string, TableLabel extends string, FieldNames extends string> = string extends Prefix
  ? string
  : string extends TableLabel
    ? string
    : string extends FieldNames
      ? string
      : `${Prefix}_${TableLabel}_${FieldNames}`;

export type resolveTableIdxLabel<input extends TableIdxInput, storeTable extends Table> = input["label"] extends string
  ? input["label"]
  : JoinIfLiteral<
      TableLabelPrefix<input>,
      storeTable["label"],
      JoinAndCapitalizeTupleOfStringLiterals<input["fields"]>
    >;

export function resolveTableIdxLabel<input extends TableIdxInput, storeTable extends Table>(
  input: input,
  storeTable: storeTable,
): resolveTableIdxLabel<input, storeTable> {
  const prefix = input.unique ? prefixUnique : prefixBasic;
  const tableLabel = storeTable.label;
  // Capitalize and join, mirrors JoinAndCapitalizeTupleOfStringLiterals
  const fieldNames = input.fields.map((fieldName) => fieldName.charAt(0).toUpperCase() + fieldName.slice(1)).join("");

  return `${prefix}_${tableLabel}_${fieldNames}` as never;
}
