import {
  renderArguments,
  renderList,
  renderImports,
  renderTableId,
  renderTypeHelpers,
  renderWithStore,
  renderedSolidityHeader,
  renderImportPath,
  renderCommonData,
  RenderKeyTuple,
} from "@latticexyz/common/codegen";
import { RenderTableIdxOptions } from "./types";
import { renderFromKeyTypeHelpers } from "./renderFromKeyTypeHelpers";
import { renderEncodeFieldSingle } from "@latticexyz/store/codegen";
import { renderUint8Map } from "./renderUint8Map";
import { encodeAbiParameters, keccak256 } from "viem";
import { renderBytes32ToValueType } from "./common";

/**
 * Renders Solidity code for a table idx library, using the specified options
 * @param options options for rendering the table idx
 * @returns string of Solidity code
 */
export function renderTableIdx(options: RenderTableIdxOptions) {
  const {
    imports,
    libraryName,
    staticResourceData,
    storeImportPath,
    idxImportPath,
    keyTuple,
    fields,
    selectedKeys,
    selectedKeyIndexes,
    selectedFields,
    selectedFieldIndexes,
    storeArgument,
  } = options;

  const { _typedTableId, _typedKeyArgs } = renderCommonData({ staticResourceData, keyTuple });

  const _fieldArgs = renderArguments(fields.map(({ name }) => name));
  const _typedFieldArgs = renderArguments(fields.map(({ name, typeWithLocation }) => `${typeWithLocation} ${name}`));

  const _keyIndexes = renderUint8Map(selectedKeyIndexes);
  const _fieldIndexes = renderUint8Map(selectedFieldIndexes);
  const _indexesHash = keccak256(
    encodeAbiParameters([{ type: "bytes32" }, { type: "bytes32" }], [_keyIndexes, _fieldIndexes]),
  );

  return `
    ${renderedSolidityHeader}

    // Import store internals
    import { ResourceId } from "${renderImportPath(storeImportPath, "ResourceId.sol")}";
    import { EncodeArray } from "${renderImportPath(storeImportPath, "tightcoder/EncodeArray.sol")}";

    // Import idx internals
    import { Uint8Map, Uint8MapLib } from "${renderImportPath(idxImportPath, "Uint8Map.sol")}";
    import { registerUniqueIdx } from "${renderImportPath(idxImportPath, "namespaces/uniqueIdx/registerUniqueIdx.sol")}";
    import { hashIndexes, hashValues } from "${renderImportPath(idxImportPath, "namespaces/uniqueIdx/utils.sol")}";
    import { UniqueIdx } from "${renderImportPath(idxImportPath, "namespaces/uniqueIdx/codegen/tables/UniqueIdx.sol")}";

    ${
      imports.length > 0
        ? `
          ${renderImports(imports)}
          `
        : ""
    }

    library ${libraryName} {
      ${staticResourceData ? renderTableId(staticResourceData) : ""}

      uint256 constant _keyNumber = ${selectedKeyIndexes.length};
      uint256 constant _fieldNumber = ${selectedFieldIndexes.length};

      Uint8Map constant _keyIndexes = Uint8Map.wrap(${_keyIndexes});
      Uint8Map constant _fieldIndexes = Uint8Map.wrap(${_fieldIndexes});

      bytes32 constant _indexesHash = ${_indexesHash};

      function valuesHash(${renderArguments([_typedFieldArgs])}) internal pure returns (bytes32) {
        bytes32[] memory _partialKeyTuple = new bytes32[](_keyNumber);
        ${renderList(
          selectedKeys,
          (field, index) => `
          _partialKeyTuple[${index}] = ${renderEncodeFieldSingle(field)};
          `,
        )}

        bytes[] memory _partialValues = new bytes[](_fieldNumber);
        ${renderList(
          selectedFields,
          (field, index) => `
          _partialValues[${index}] = ${renderEncodeFieldSingle(field)};
          `,
        )}

        return hashValues(_partialKeyTuple, _partialValues);
      }

      ${renderWithStore(
        storeArgument,
        ({ _typedStore }) => `
          // Should be called once in e.g. PostDeploy
          function register(${renderArguments([_typedStore, _typedTableId])}) internal {
            registerUniqueIdx(_tableId, _keyIndexes, _fieldIndexes);
          }

          function has(${renderArguments([_typedStore, _typedTableId, _typedFieldArgs])}) internal view returns (bool) {
            bytes32 _valuesHash = valuesHash(${_fieldArgs});

            return UniqueIdx.length(_tableId, _indexesHash, _valuesHash) > 0;
          }

          function getKeyTuple(${renderArguments([
            _typedStore,
            _typedTableId,
            _typedFieldArgs,
          ])}) internal view returns (bytes32[] memory _keyTuple) {
            bytes32 _valuesHash = valuesHash(${_fieldArgs});

            return UniqueIdx.get(_tableId, _indexesHash, _valuesHash);
          }

          function get(${renderArguments([
            _typedStore,
            _typedTableId,
            _typedFieldArgs,
          ])}) internal view returns (${_typedKeyArgs}) {
            bytes32[] memory _keyTuple = getKeyTuple(${_fieldArgs});

            ${renderDecodeKeyTuple(keyTuple)}
          }
        `,
      )}

      /**
       * @notice Decode keys from a bytes32 array using the source table's field layout.
       */
      function decodeKeyTuple(bytes32[] memory _keyTuple) internal pure returns (${_typedKeyArgs}) {
        ${renderDecodeKeyTuple(keyTuple)}
      }
    }

    ${renderTypeHelpers(options)}
    ${renderFromKeyTypeHelpers(options)}
  `;
}

export function renderDecodeKeyTuple(keyTuple: RenderKeyTuple[]) {
  return renderList(
    keyTuple,
    (key, index) => `
    ${key.name} = ${renderBytes32ToValueType(`_keyTuple[${index}]`, key)};
    `,
  );
}
