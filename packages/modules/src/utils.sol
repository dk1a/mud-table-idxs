// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Uint8Map } from "./Uint8Map.sol";

function hashIndexes(Uint8Map keyIndexes, Uint8Map fieldIndexes) pure returns (bytes32) {
  return keccak256(abi.encode(keyIndexes, fieldIndexes));
}

function hashValues(bytes32[] memory partialKeyTuple, bytes[] memory partialValues) pure returns (bytes32) {
  return keccak256(abi.encode(partialKeyTuple, partialValues));
}
