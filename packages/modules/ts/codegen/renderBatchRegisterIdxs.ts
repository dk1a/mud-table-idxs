import path from "node:path";
import { renderImportPath, renderList, renderedSolidityHeader } from "@latticexyz/common/codegen";
import { TableIdxOptions } from "./getTableIdxOptions";

/**
 * Returns Solidity code for a function to batch register all the provided table idxs, except for tables with store/table argument
 * @param options table idx definitions
 * @returns string of Solidity code
 */
export function renderBatchRegisterIdxs(codegenIndexPath: string, options: TableIdxOptions[]) {
  const batchEligibleOptions = options.filter(({ renderOptions: { storeArgument, staticResourceData } }) => {
    const tableArgument = !staticResourceData;
    // Skip batch registering idxs for tables that require either table or store args
    if (storeArgument || tableArgument) return false;
    return true;
  });

  return `
    ${renderedSolidityHeader}

    ${renderList(batchEligibleOptions, ({ outputPath, renderOptions: { libraryName } }) => {
      return `import { ${libraryName} } from "${renderImportPath("./" + path.relative(path.dirname(codegenIndexPath), outputPath))}";`;
    })}

    function batchRegisterIdxs() {
      ${renderList(batchEligibleOptions, ({ renderOptions: { libraryName } }) => {
        return `${libraryName}.register();`;
      })}
    }
  `;
}
