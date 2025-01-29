import { RenderKeyTuple } from "@latticexyz/common/codegen";

/**
 * Renders the necessary helper functions to typecast from the types of given keys
 *
 */
export function renderFromKeyTypeHelpers(options: { keyTuple: RenderKeyTuple[] }): string {
  const { keyTuple } = options;

  let result = "";

  if (keyTuple.some(({ internalTypeId }) => internalTypeId.match("bool"))) {
    result += `
    /**
     * @notice Cast a bytes32 to a bool.
     * @dev The bytes32 value is casted to a boolean value with 0 or 1 at the least significant bit.
     */
    function _bytes32ToBool(bytes32 value) pure returns (bool result) {
      assembly {
        result := value
      }
    }
    `;
  }

  return result;
}
