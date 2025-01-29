import { concat, Hex, pad, toHex } from "viem";

export function renderUint8Map(array: Uint8Array) {
  return uint8ArrayToBytemap(array);
}

export function uint8ArrayToBytemap(array: Uint8Array): Hex {
  if (array.length > 31) {
    throw new Error(`Uint8Map can only hold up to 31 elements, received ${array.length}.`);
  }

  const unpaddedMap = concat([new Uint8Array([array.length]), array]);
  const map = pad(unpaddedMap, { dir: "right", size: 32 });

  return toHex(map);
}
