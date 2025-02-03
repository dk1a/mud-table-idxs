import { encodeAbiParameters, keccak256 } from "viem";
import {
  renderArguments,
  renderList,
  renderImports,
  renderTableId,
  renderTypeHelpers,
  renderedSolidityHeader,
  renderImportPath,
  renderCommonData,
  RenderKeyTuple,
  renderValueTypeToBytes32,
} from "@latticexyz/common/codegen";
import { renderEncodeFieldSingle } from "@latticexyz/store/codegen";
import { RenderTableIdxOptions } from "./types";
import { renderFromKeyTypeHelpers } from "./renderFromKeyTypeHelpers";
import { renderUint8Map } from "./renderUint8Map";
import { renderBytes32ToValueType, renderWithStoreArg } from "./common";

/**
 * Renders Solidity code for a table idx library, using the specified options
 * @param options options for rendering the table idx
 * @returns string of Solidity code
 */
export function renderTableIdx(options: RenderTableIdxOptions) {
  const {
    imports,
    libraryName,
    unique,
    staticResourceData,
    storeImportPath,
    idxImportPath,
    keyTuple,
    selectedKeys,
    selectedKeyIndexes,
    selectedFields,
    selectedFieldIndexes,
  } = options;

  const { _typedTableId, _typedKeyArgs } = renderCommonData({ staticResourceData, keyTuple });

  const _selectedArgs = renderArguments([...selectedKeys, ...selectedFields].map(({ name }) => name));
  const _typedSelectedArgs = renderArguments(
    [...selectedKeys, ...selectedFields].map(({ name, typeWithLocation }) => `${typeWithLocation} ${name}`),
  );

  const _keyIndexes = renderUint8Map(selectedKeyIndexes);
  const _fieldIndexes = renderUint8Map(selectedFieldIndexes);
  const _indexesHash = keccak256(
    encodeAbiParameters([{ type: "bytes32" }, { type: "bytes32" }], [_keyIndexes, _fieldIndexes]),
  );

  const registerFunction = unique ? "registerUniqueIdx" : "registerBasicIdx";

  let namespaceImports = "";
  if (unique) {
    namespaceImports += `
      import { registerUniqueIdx } from "${renderImportPath(idxImportPath, "namespaces/uniqueIdx/registerUniqueIdx.sol")}";
      import { UniqueIdx } from "${renderImportPath(idxImportPath, "namespaces/uniqueIdx/codegen/tables/UniqueIdx.sol")}";
    `;
  } else {
    namespaceImports += `
      import { registerBasicIdx } from "${renderImportPath(idxImportPath, "namespaces/basicIdx/registerBasicIdx.sol")}";
      import { BasicIdx } from "${renderImportPath(idxImportPath, "namespaces/basicIdx/codegen/tables/BasicIdx.sol")}";
      import { BasicIdxUsedKeys } from "${renderImportPath(idxImportPath, "namespaces/basicIdx/codegen/tables/BasicIdxUsedKeys.sol")}";
      import { BasicIdx_KeyTuple } from "${renderImportPath(idxImportPath, "namespaces/basicIdx/BasicIdx_KeyTuple.sol")}";
    `;
  }

  return `
    ${renderedSolidityHeader}

    // Import store internals
    import { ResourceId } from "${renderImportPath(storeImportPath, "ResourceId.sol")}";
    import { EncodeArray } from "${renderImportPath(storeImportPath, "tightcoder/EncodeArray.sol")}";

    // Import idx internals
    import { Uint8Map, Uint8MapLib } from "${renderImportPath(idxImportPath, "Uint8Map.sol")}";
    import { hashIndexes, hashValues } from "${renderImportPath(idxImportPath, "utils.sol")}";
    ${namespaceImports}

    ${
      imports.length > 0
        ? `
          // Import user types
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

      function valuesHash(${renderArguments([_typedSelectedArgs])}) internal pure returns (bytes32) {
        bytes32[] memory _partialKeyTuple = new bytes32[](_keyNumber);
        ${renderList(
          selectedKeys,
          (field, index) => `
          _partialKeyTuple[${index}] = ${renderValueTypeToBytes32(field.name, field)};
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

      // Should be called once in e.g. PostDeploy
      function register(${renderArguments([_typedTableId])}) internal {
        ${registerFunction}(_tableId, _keyIndexes, _fieldIndexes);
      }

      ${unique ? renderUniqueMethods(options, _selectedArgs, _typedSelectedArgs) : renderBasicMethods(options, _selectedArgs, _typedSelectedArgs)}

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

function renderUniqueMethods(
  { storeArgument, staticResourceData, keyTuple }: RenderTableIdxOptions,
  _selectedArgs: string,
  _typedSelectedArgs: string,
): string {
  const { _typedTableId, _typedKeyArgs } = renderCommonData({ staticResourceData, keyTuple });
  const _tableIdArg = _typedTableId ? "_tableId" : undefined;

  return renderWithStoreArg(
    storeArgument,
    ({ _typedStore, _store }) => `
      function has(${renderArguments([_typedStore, _typedTableId, _typedSelectedArgs])}) internal view returns (bool) {
        bytes32 _valuesHash = valuesHash(${_selectedArgs});

        return UniqueIdx.length(${renderArguments([_store, "_tableId", "_indexesHash", "_valuesHash"])}) > 0;
      }

      function getKeyTuple(${renderArguments([
        _typedStore,
        _typedTableId,
        _typedSelectedArgs,
      ])}) internal view returns (bytes32[] memory _keyTuple) {
        bytes32 _valuesHash = valuesHash(${_selectedArgs});

        return UniqueIdx.get(${renderArguments([_store, "_tableId", "_indexesHash", "_valuesHash"])});
      }

      function get(${renderArguments([
        _typedStore,
        _typedTableId,
        _typedSelectedArgs,
      ])}) internal view returns (${_typedKeyArgs}) {
        bytes32[] memory _keyTuple = getKeyTuple(${renderArguments([_store, _tableIdArg, _selectedArgs])});

        ${renderDecodeKeyTuple(keyTuple)}
      }
    `,
  );
}

function renderBasicMethods(
  { storeArgument, staticResourceData, keyTuple, selectedKeys }: RenderTableIdxOptions,
  _selectedArgs: string,
  _typedSelectedArgs: string,
): string {
  const { _typedTableId, _keyTupleDefinition } = renderCommonData({ staticResourceData, keyTuple });
  const _tableIdArg = _typedTableId ? "_tableId" : undefined;

  // A part of keyTuple can already be passed as selected keys, so skip them since they can't differ
  const selectedKeyNames = selectedKeys.map((selectedKey) => selectedKey.name);
  const keyTupleWithoutSelectedKeys = keyTuple.filter(({ name }) => !selectedKeyNames.includes(name));
  const _typedKeyArgsWithoutSelected = renderArguments(
    keyTupleWithoutSelectedKeys.map(({ name, typeWithLocation }) => `${typeWithLocation} ${name}`),
  );

  let result = renderWithStoreArg(
    storeArgument,
    ({ _typedStore, _store }) => `
      function length(${renderArguments([_typedStore, _typedTableId, _typedSelectedArgs])}) internal view returns (uint256) {
        bytes32 _valuesHash = valuesHash(${_selectedArgs});

        return BasicIdx_KeyTuple.length(${renderArguments([_store, "_tableId", "_indexesHash", "_valuesHash"])});
      }

      function hasKeyTuple(${renderArguments([
        _typedStore,
        _typedTableId,
        _typedSelectedArgs,
        "bytes32[] memory _keyTuple",
      ])}) internal view returns (bool _has, uint40 _index) {
        bytes32 _valuesHash = valuesHash(${_selectedArgs});
        bytes32 _keyTupleHash = keccak256(abi.encode(_keyTuple));

        return BasicIdxUsedKeys.get(${renderArguments([_store, "_tableId", "_indexesHash", "_valuesHash", "_keyTupleHash"])});
      }

      function has(${renderArguments([
        _typedStore,
        _typedTableId,
        _typedSelectedArgs,
        _typedKeyArgsWithoutSelected,
      ])}) internal view returns (bool _has, uint40 _index) {
        ${_keyTupleDefinition}

        return hasKeyTuple(${renderArguments([_store, _tableIdArg, _selectedArgs, "_keyTuple"])});
      }
    `,
  );

  // Having the entire keyTuple be part of selected keys makes some methods meaningless
  // TODO decide if this should even be allowed at the config level
  if (keyTupleWithoutSelectedKeys.length > 0) {
    result += renderWithStoreArg(
      storeArgument,
      ({ _typedStore, _store }) => `
        function getKeyTuple(${renderArguments([
          _typedStore,
          _typedTableId,
          _typedSelectedArgs,
          "uint256 _index",
        ])}) internal view returns (bytes32[] memory _keyTuple) {
          bytes32 _valuesHash = valuesHash(${_selectedArgs});

          return BasicIdx_KeyTuple.getItem(${renderArguments([
            _store,
            "_tableId",
            "_indexesHash",
            "_valuesHash",
            "_index",
            `${keyTuple.length}`,
          ])});
        }

        function get(${renderArguments([
          _typedStore,
          _typedTableId,
          _typedSelectedArgs,
          "uint256 _index",
        ])}) internal view returns (${_typedKeyArgsWithoutSelected}) {
          bytes32[] memory _keyTuple = getKeyTuple(${renderArguments([_store, _tableIdArg, _selectedArgs, "_index"])});

          ${renderDecodeKeyTuple(keyTuple)}
        }
      `,
    );
  }

  return result;
}
