import { TableIdxCodegen } from "./output";

export type TableIdxCodegenInput = Partial<TableIdxCodegen>;

export type TableIdxInput = {
  readonly label: string;
  readonly fields: readonly string[];
  readonly unique: boolean;

  readonly codegen?: TableIdxCodegenInput;
};

export type TableIdxsInput = {
  readonly [label: string]: Omit<TableIdxInput, "label">;
};

export type TablesInput = {
  readonly [label: string]: TableIdxsInput;
};

export type NamespaceInput = {
  readonly tables?: TablesInput;
};

export type NamespacesInput = {
  readonly [label: string]: NamespaceInput;
};

export type StoreIdxsInput = {
  readonly namespaces?: NamespacesInput;
};
