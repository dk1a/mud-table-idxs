// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_TABLE } from "@latticexyz/store/src/storeResourceTypes.sol";
import { RESOURCE_SYSTEM, RESOURCE_NAMESPACE } from "@latticexyz/world/src/worldResourceTypes.sol";

bytes14 constant NAMESPACE = "uniqueIdx";

ResourceId constant NAMESPACE_ID = ResourceId.wrap(bytes32(abi.encodePacked(RESOURCE_NAMESPACE, NAMESPACE)));

ResourceId constant SYSTEM_ID = ResourceId.wrap(
  bytes32(abi.encodePacked(RESOURCE_SYSTEM, NAMESPACE, bytes16("UniqueIdxRegistr")))
);
