import { RenderType } from "@latticexyz/common/codegen";

/**
 * Renders solidity typecasts to get from `bytes32` to the given type
 * @param name variable name to be typecasted
 * @param param1 type data
 */
export function renderBytes32ToValueType(
  name: string,
  { typeUnwrap, internalTypeId }: Pick<RenderType, "typeUnwrap" | "internalTypeId">,
): string {
  const innerText = typeUnwrap.length ? `${typeUnwrap}(${name})` : name;

  if (internalTypeId === "bytes32") {
    return innerText;
  } else if (/^bytes\d{1,2}$/.test(internalTypeId)) {
    return `${internalTypeId}(${innerText})`;
  } else if (/^uint\d{1,3}$/.test(internalTypeId)) {
    return `${internalTypeId}(uint256(${innerText}))`;
  } else if (/^int\d{1,3}$/.test(internalTypeId)) {
    return `${internalTypeId}(int256(uint256(${innerText})))`;
  } else if (internalTypeId === "address") {
    return `${internalTypeId}(uint160(uint256(${innerText})))`;
  } else if (internalTypeId === "bool") {
    return `_bytes32ToBool(${innerText})`;
  } else {
    throw new Error(`Unknown value type id ${internalTypeId}`);
  }
}

interface RenderWithStoreArgCallbackData {
  _typedStore: string | undefined;
  _store: string | undefined;
}

// TODO this is quite different from mud's `renderWithStore`, name it something better and/or explain the diff better
export function renderWithStoreArg(
  storeArgument: boolean,
  callback: (data: RenderWithStoreArgCallbackData) => string,
): string {
  let result = "";
  result += callback({ _typedStore: undefined, _store: undefined });

  if (storeArgument) {
    result += "\n" + callback({ _typedStore: "IStore _store", _store: "_store" });
  }

  return result;
}
