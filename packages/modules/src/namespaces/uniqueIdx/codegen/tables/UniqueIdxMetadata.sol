// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";
import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

// Import user types
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { Uint8Map } from "../../../../Uint8Map.sol";

struct UniqueIdxMetadataData {
  bool has;
  address hookAddress;
  Uint8Map keyIndexes;
  Uint8Map fieldIndexes;
  Uint8Map staticIndexes;
  Uint8Map dynamicIndexes;
}

library UniqueIdxMetadata {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "uniqueIdx", name: "UniqueIdxMetadat", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462756e697175654964780000000000556e697175654964784d657461646174);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0095060001142020202000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32, bytes32)
  Schema constant _keySchema = Schema.wrap(0x004002005f5f0000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (bool, address, bytes32, bytes32, bytes32, bytes32)
  Schema constant _valueSchema = Schema.wrap(0x0095060060615f5f5f5f00000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](2);
    keyNames[0] = "sourceTableId";
    keyNames[1] = "indexesHash";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](6);
    fieldNames[0] = "has";
    fieldNames[1] = "hookAddress";
    fieldNames[2] = "keyIndexes";
    fieldNames[3] = "fieldIndexes";
    fieldNames[4] = "staticIndexes";
    fieldNames[5] = "dynamicIndexes";
  }

  /**
   * @notice Register the table with its config.
   */
  function register() internal {
    StoreSwitch.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register() internal {
    StoreCore.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config (using the specified store).
   */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get has.
   */
  function getHas(ResourceId sourceTableId, bytes32 indexesHash) internal view returns (bool has) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get has.
   */
  function _getHas(ResourceId sourceTableId, bytes32 indexesHash) internal view returns (bool has) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get has (using the specified store).
   */
  function getHas(IStore _store, ResourceId sourceTableId, bytes32 indexesHash) internal view returns (bool has) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Set has.
   */
  function setHas(ResourceId sourceTableId, bytes32 indexesHash, bool has) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((has)), _fieldLayout);
  }

  /**
   * @notice Set has.
   */
  function _setHas(ResourceId sourceTableId, bytes32 indexesHash, bool has) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((has)), _fieldLayout);
  }

  /**
   * @notice Set has (using the specified store).
   */
  function setHas(IStore _store, ResourceId sourceTableId, bytes32 indexesHash, bool has) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((has)), _fieldLayout);
  }

  /**
   * @notice Get hookAddress.
   */
  function getHookAddress(ResourceId sourceTableId, bytes32 indexesHash) internal view returns (address hookAddress) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (address(bytes20(_blob)));
  }

  /**
   * @notice Get hookAddress.
   */
  function _getHookAddress(ResourceId sourceTableId, bytes32 indexesHash) internal view returns (address hookAddress) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (address(bytes20(_blob)));
  }

  /**
   * @notice Get hookAddress (using the specified store).
   */
  function getHookAddress(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (address hookAddress) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (address(bytes20(_blob)));
  }

  /**
   * @notice Set hookAddress.
   */
  function setHookAddress(ResourceId sourceTableId, bytes32 indexesHash, address hookAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((hookAddress)), _fieldLayout);
  }

  /**
   * @notice Set hookAddress.
   */
  function _setHookAddress(ResourceId sourceTableId, bytes32 indexesHash, address hookAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((hookAddress)), _fieldLayout);
  }

  /**
   * @notice Set hookAddress (using the specified store).
   */
  function setHookAddress(IStore _store, ResourceId sourceTableId, bytes32 indexesHash, address hookAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((hookAddress)), _fieldLayout);
  }

  /**
   * @notice Get keyIndexes.
   */
  function getKeyIndexes(ResourceId sourceTableId, bytes32 indexesHash) internal view returns (Uint8Map keyIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get keyIndexes.
   */
  function _getKeyIndexes(ResourceId sourceTableId, bytes32 indexesHash) internal view returns (Uint8Map keyIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get keyIndexes (using the specified store).
   */
  function getKeyIndexes(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map keyIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Set keyIndexes.
   */
  function setKeyIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map keyIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked(Uint8Map.unwrap(keyIndexes)), _fieldLayout);
  }

  /**
   * @notice Set keyIndexes.
   */
  function _setKeyIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map keyIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked(Uint8Map.unwrap(keyIndexes)), _fieldLayout);
  }

  /**
   * @notice Set keyIndexes (using the specified store).
   */
  function setKeyIndexes(IStore _store, ResourceId sourceTableId, bytes32 indexesHash, Uint8Map keyIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked(Uint8Map.unwrap(keyIndexes)), _fieldLayout);
  }

  /**
   * @notice Get fieldIndexes.
   */
  function getFieldIndexes(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map fieldIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get fieldIndexes.
   */
  function _getFieldIndexes(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map fieldIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get fieldIndexes (using the specified store).
   */
  function getFieldIndexes(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map fieldIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Set fieldIndexes.
   */
  function setFieldIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map fieldIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked(Uint8Map.unwrap(fieldIndexes)), _fieldLayout);
  }

  /**
   * @notice Set fieldIndexes.
   */
  function _setFieldIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map fieldIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked(Uint8Map.unwrap(fieldIndexes)), _fieldLayout);
  }

  /**
   * @notice Set fieldIndexes (using the specified store).
   */
  function setFieldIndexes(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    Uint8Map fieldIndexes
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked(Uint8Map.unwrap(fieldIndexes)), _fieldLayout);
  }

  /**
   * @notice Get staticIndexes.
   */
  function getStaticIndexes(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map staticIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get staticIndexes.
   */
  function _getStaticIndexes(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map staticIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get staticIndexes (using the specified store).
   */
  function getStaticIndexes(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map staticIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Set staticIndexes.
   */
  function setStaticIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map staticIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked(Uint8Map.unwrap(staticIndexes)), _fieldLayout);
  }

  /**
   * @notice Set staticIndexes.
   */
  function _setStaticIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map staticIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked(Uint8Map.unwrap(staticIndexes)), _fieldLayout);
  }

  /**
   * @notice Set staticIndexes (using the specified store).
   */
  function setStaticIndexes(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    Uint8Map staticIndexes
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked(Uint8Map.unwrap(staticIndexes)), _fieldLayout);
  }

  /**
   * @notice Get dynamicIndexes.
   */
  function getDynamicIndexes(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map dynamicIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get dynamicIndexes.
   */
  function _getDynamicIndexes(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map dynamicIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Get dynamicIndexes (using the specified store).
   */
  function getDynamicIndexes(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (Uint8Map dynamicIndexes) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return Uint8Map.wrap(bytes32(_blob));
  }

  /**
   * @notice Set dynamicIndexes.
   */
  function setDynamicIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map dynamicIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked(Uint8Map.unwrap(dynamicIndexes)), _fieldLayout);
  }

  /**
   * @notice Set dynamicIndexes.
   */
  function _setDynamicIndexes(ResourceId sourceTableId, bytes32 indexesHash, Uint8Map dynamicIndexes) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked(Uint8Map.unwrap(dynamicIndexes)), _fieldLayout);
  }

  /**
   * @notice Set dynamicIndexes (using the specified store).
   */
  function setDynamicIndexes(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    Uint8Map dynamicIndexes
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked(Uint8Map.unwrap(dynamicIndexes)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (UniqueIdxMetadataData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get(
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (UniqueIdxMetadataData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data (using the specified store).
   */
  function get(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash
  ) internal view returns (UniqueIdxMetadataData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = _store.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bool has,
    address hookAddress,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes,
    Uint8Map staticIndexes,
    Uint8Map dynamicIndexes
  ) internal {
    bytes memory _staticData = encodeStatic(has, hookAddress, keyIndexes, fieldIndexes, staticIndexes, dynamicIndexes);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bool has,
    address hookAddress,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes,
    Uint8Map staticIndexes,
    Uint8Map dynamicIndexes
  ) internal {
    bytes memory _staticData = encodeStatic(has, hookAddress, keyIndexes, fieldIndexes, staticIndexes, dynamicIndexes);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using individual values (using the specified store).
   */
  function set(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    bool has,
    address hookAddress,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes,
    Uint8Map staticIndexes,
    Uint8Map dynamicIndexes
  ) internal {
    bytes memory _staticData = encodeStatic(has, hookAddress, keyIndexes, fieldIndexes, staticIndexes, dynamicIndexes);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(ResourceId sourceTableId, bytes32 indexesHash, UniqueIdxMetadataData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.has,
      _table.hookAddress,
      _table.keyIndexes,
      _table.fieldIndexes,
      _table.staticIndexes,
      _table.dynamicIndexes
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(ResourceId sourceTableId, bytes32 indexesHash, UniqueIdxMetadataData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.has,
      _table.hookAddress,
      _table.keyIndexes,
      _table.fieldIndexes,
      _table.staticIndexes,
      _table.dynamicIndexes
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct (using the specified store).
   */
  function set(
    IStore _store,
    ResourceId sourceTableId,
    bytes32 indexesHash,
    UniqueIdxMetadataData memory _table
  ) internal {
    bytes memory _staticData = encodeStatic(
      _table.has,
      _table.hookAddress,
      _table.keyIndexes,
      _table.fieldIndexes,
      _table.staticIndexes,
      _table.dynamicIndexes
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(
    bytes memory _blob
  )
    internal
    pure
    returns (
      bool has,
      address hookAddress,
      Uint8Map keyIndexes,
      Uint8Map fieldIndexes,
      Uint8Map staticIndexes,
      Uint8Map dynamicIndexes
    )
  {
    has = (_toBool(uint8(Bytes.getBytes1(_blob, 0))));

    hookAddress = (address(Bytes.getBytes20(_blob, 1)));

    keyIndexes = Uint8Map.wrap(Bytes.getBytes32(_blob, 21));

    fieldIndexes = Uint8Map.wrap(Bytes.getBytes32(_blob, 53));

    staticIndexes = Uint8Map.wrap(Bytes.getBytes32(_blob, 85));

    dynamicIndexes = Uint8Map.wrap(Bytes.getBytes32(_blob, 117));
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   * @param _staticData Tightly packed static fields.
   *
   *
   */
  function decode(
    bytes memory _staticData,
    EncodedLengths,
    bytes memory
  ) internal pure returns (UniqueIdxMetadataData memory _table) {
    (
      _table.has,
      _table.hookAddress,
      _table.keyIndexes,
      _table.fieldIndexes,
      _table.staticIndexes,
      _table.dynamicIndexes
    ) = decodeStatic(_staticData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(ResourceId sourceTableId, bytes32 indexesHash) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(ResourceId sourceTableId, bytes32 indexesHash) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Delete all data for given keys (using the specified store).
   */
  function deleteRecord(IStore _store, ResourceId sourceTableId, bytes32 indexesHash) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    _store.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    bool has,
    address hookAddress,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes,
    Uint8Map staticIndexes,
    Uint8Map dynamicIndexes
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(has, hookAddress, keyIndexes, fieldIndexes, staticIndexes, dynamicIndexes);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    bool has,
    address hookAddress,
    Uint8Map keyIndexes,
    Uint8Map fieldIndexes,
    Uint8Map staticIndexes,
    Uint8Map dynamicIndexes
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(has, hookAddress, keyIndexes, fieldIndexes, staticIndexes, dynamicIndexes);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(ResourceId sourceTableId, bytes32 indexesHash) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = ResourceId.unwrap(sourceTableId);
    _keyTuple[1] = indexesHash;

    return _keyTuple;
  }
}

/**
 * @notice Cast a value to a bool.
 * @dev Boolean values are encoded as uint8 (1 = true, 0 = false), but Solidity doesn't allow casting between uint8 and bool.
 * @param value The uint8 value to convert.
 * @return result The boolean value.
 */
function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
