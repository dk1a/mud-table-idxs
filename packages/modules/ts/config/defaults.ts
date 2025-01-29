import { TableIdxCodegenInput } from "./input";

export const TABLE_IDX_CODEGEN_DEFAULTS = {
  outputDirectory: "idxs" as string,
  tableIdArgument: false,
  storeArgument: false,
} as const satisfies TableIdxCodegenInput;

export type TABLE_IDX_CODEGEN_DEFAULTS = typeof TABLE_IDX_CODEGEN_DEFAULTS;
