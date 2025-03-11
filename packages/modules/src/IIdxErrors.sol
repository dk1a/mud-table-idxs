// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

interface IIdxErrors {
  /**
   * @notice Error raised if the requested value is not indexed, and has no corresponding keyTuple.
   * @param tableId The ID of the table.
   * @param libraryName The plaintext name of the idx library that raised this error.
   * @param valuesBlob ABI encodePacked values used for the getter (this simpler blob structure may not hash to `valuesHash`).
   * @param indexesHash The hash of indexed columns used to uniquely identify an idx.
   * @param valuesHash The hash of values used for the getter, which may be mapped to keyTuple(s).
   */
  error UniqueIdx_InvalidGet(
    ResourceId tableId,
    string libraryName,
    bytes valuesBlob,
    bytes32 indexesHash,
    bytes32 valuesHash
  );
  // TODO consider similar error for BasicIdx, currently it just propagates store's out of bounds
}
