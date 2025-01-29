export type TableIdxCodegen = {
  readonly outputDirectory: string;
  readonly tableIdArgument: boolean;
  readonly storeArgument: boolean;
};

export type TableIdx = {
  readonly label: string;
  readonly fields: readonly string[];
  readonly unique: boolean;

  readonly codegen: TableIdxCodegen;
};

export type TableIdxs = {
  readonly [label: string]: TableIdx;
};

export type Tables = {
  readonly [label: string]: TableIdxs;
};

export type Namespace = {
  readonly tables: Tables;
};

export type Namespaces = {
  readonly [label: string]: Namespace;
};

export type StoreIdxsConfig = {
  readonly namespaces: Namespaces;
};
