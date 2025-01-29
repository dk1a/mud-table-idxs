import {
  ImportDatum,
  RenderField,
  RenderKeyTuple,
  RenderStaticField,
  StaticResourceData,
} from "@latticexyz/common/codegen";

export interface RenderTableIdxOptions {
  /** List of symbols to import, and their file paths */
  imports: ImportDatum[];
  /** Name of the library to render. */
  libraryName: string;
  /** Data used to statically register the table. If undefined, all relevant methods receive `_sourceTableId` as an argument. */
  staticResourceData?: StaticResourceData;
  /** Path for store package imports */
  storeImportPath: string;
  idxImportPath: string;
  keyTuple: RenderKeyTuple[];
  fields: RenderField[];
  selectedKeys: RenderStaticField[];
  selectedKeyIndexes: Uint8Array;
  selectedFields: RenderField[];
  selectedFieldIndexes: Uint8Array;
  /** Whether to render additional methods that accept a manual `IStore` argument */
  storeArgument: boolean;
}
