// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WORD_SIZE, WORD_LAST_INDEX, BYTE_TO_BITS } from "@latticexyz/store/src/constants.sol";

/// @dev Represents the maximum number of items a Uint8Map can handle.
uint256 constant MAX_UINT8_MAP_ITEMS = 31;

library LayoutOffsets {
  /// @notice Represents the total length offset within the EVM word.
  uint256 internal constant TOTAL_LENGTH = (WORD_SIZE - 1) * BYTE_TO_BITS;
}

/**
 * @title Uint8Map
 * @dev Represents a uint8 array encoded into a single bytes32.
 * From left to right, the bytes are laid out as follows:
 * - 1 byte for array length, which can be no larger than 31
 * - 31 bytes for 31 potential array members
 */
type Uint8Map is bytes32;

// When importing FieldLayout, attach FieldLayoutInstance to it
using Uint8MapInstance for Uint8Map global;

library Uint8MapLib {
  error Uint8MapLib_TooManyFields(uint256 numFields, uint256 maxFields);

  function encode(uint256[] memory array) internal pure returns (Uint8Map) {
    uint256 uint8Map;
    if (array.length > MAX_UINT8_MAP_ITEMS) revert Uint8MapLib_TooManyFields(array.length, MAX_UINT8_MAP_ITEMS);

    // Store the array items in the encoded uint8Map
    for (uint256 i; i < array.length; ) {
      unchecked {
        // Sequentially store lengths after the first 1 byte (which is reserved for total length)
        // (safe because of the initial array.length check)
        uint8Map |= uint256(array[i]) << ((WORD_LAST_INDEX - 1 - i) * BYTE_TO_BITS);
        i++;
      }
    }

    // Store total length in the first 1 byte
    uint8Map |= array.length << LayoutOffsets.TOTAL_LENGTH;

    return Uint8Map.wrap(bytes32(uint8Map));
  }
}

/**
 * @title Uint8MapInstance
 * @dev Provides instance functions for obtaining information from an encoded Uint8Map.
 */
library Uint8MapInstance {
  /**
   * @notice Get the array item at the given index from the Uint8Map.
   */
  function atIndex(Uint8Map uint8Map, uint256 index) internal pure returns (uint8) {
    unchecked {
      return uint8(uint256(uint8Map.unwrap()) >> ((WORD_LAST_INDEX - 1 - index) * BYTE_TO_BITS));
    }
  }

  /**
   * @notice Get the total number of items for the given Uint8Map.
   */
  function length(Uint8Map uint8Map) internal pure returns (uint256) {
    return uint256(Uint8Map.unwrap(uint8Map)) >> LayoutOffsets.TOTAL_LENGTH;
  }

  /**
   * @notice Convert the given Uint8Map to an equivalent memory array.
   * @dev This function is primarily for more readable debugging/logs.
   */
  function toArray(Uint8Map uint8Map) internal pure returns (uint256[] memory array) {
    array = new uint256[](uint8Map.length());

    for (uint256 i; i < uint8Map.length(); i++) {
      array[i] = uint8Map.atIndex(i);
    }
  }

  /**
   * @notice Unwrap the Uint8Map to obtain the raw bytes32 representation.
   */
  function unwrap(Uint8Map uint8Map) internal pure returns (bytes32) {
    return Uint8Map.unwrap(uint8Map);
  }
}
