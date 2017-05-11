pragma solidity ^0.4.8;

import "./SafeMath.sol";
import "./Owned.sol";
import "./Strings.sol";

contract EternalStorage is Owned {    
    using Strings for *;

    mapping(bytes32 => uint) UIntStorage;
    mapping(bytes32 => uint8) UInt8Storage;
    mapping(bytes32 => int) IntStorage;    
    mapping(bytes32 => bytes) BytesStorage;
    mapping(bytes32 => bytes32) Bytes32Storage;
    mapping(bytes32 => bool) BooleanStorage;
    mapping(bytes32 => bytes32[]) StringStorage;
    mapping(bytes32 => address) AddressStorage;
    
    address[] private allowedContractsKeys;
    mapping(address => bool) private allowedContracts;

    function addAllowedContracts(address[] addresses) onlyContractOwner {
        for (uint i = 0; i < addresses.length; i++) {
            allowedContracts[addresses[i]] = true;
            allowedContractsKeys.push(addresses[i]);
        }
    }

    function removeAllowedContracts(address[] addresses) onlyContractOwner {
        for (uint i = 0; i < addresses.length; i++) {
            allowedContracts[addresses[i]] = false;
        }
    }

    function allowedContractsCount() constant returns(uint count) {
        for (uint i = 0; i < allowedContractsKeys.length; i++) {
            if (allowedContracts[allowedContractsKeys[i]]) {
                count++;
            }
        }
        return count;
    }

    function getAllowedContracts() constant returns(address[] addresses) {
        addresses = new address[](allowedContractsCount());

        for (uint i = 0; i < allowedContractsKeys.length; i++) {
            if (allowedContracts[allowedContractsKeys[i]]) {
                addresses[i] = allowedContractsKeys[i];
            }
        }

        return addresses;
    }

    /**
    *  @dev UInt Storage
    */

    function getUIntValue(bytes32 record) constant returns (uint) {
        return UIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint value) onlyAllowedContractOrOwner {
        UIntStorage[record] = value;
    }

    function deleteUIntValue(bytes32 record) onlyAllowedContractOrOwner {
        delete UIntStorage[record];
    }

    function addUIntValue(bytes32 record, uint value) onlyAllowedContractOrOwner returns (uint result) {
        result = SafeMath.safeAdd(UIntStorage[record], value);
        UIntStorage[record] = result;
    }

    function subUIntValue(bytes32 record, uint value) onlyAllowedContractOrOwner returns (uint result) {
        result =  SafeMath.safeSub(UIntStorage[record], value);
        UIntStorage[record] = result;
    }

    /**
    *  @dev UInt8 Storage
    */
    
    function getUInt8Value(bytes32 record) constant returns (uint8) {
        return UInt8Storage[record];
    }

    function setUInt8Value(bytes32 record, uint8 value) onlyAllowedContractOrOwner {
        UInt8Storage[record] = value;
    }

    function deleteUInt8Value(bytes32 record) onlyAllowedContractOrOwner {
        delete UInt8Storage[record];
    }

    /**
    *  @dev String Storage 
    */

    function getStringValue(bytes32 record) constant returns (bytes32[] name) {
        name =  StringStorage[record];
        return name;
    }

    function setStringValue(bytes32 record, string value) onlyAllowedContractOrOwner {
        StringStorage[record] = value.toBytes32Array();
    }

    function deleteStringValue(bytes32 record) onlyAllowedContractOrOwner {
        delete StringStorage[record];
    }

    /**
    *  @dev Address Storage 
    */

    function getAddressValue(bytes32 record) constant returns (address) {
        return AddressStorage[record];
    }

    function setAddressValue(bytes32 record, address value) onlyAllowedContractOrOwner {
        AddressStorage[record] = value;
    }

    function deleteAddressValue(bytes32 record) onlyAllowedContractOrOwner {
        delete AddressStorage[record];
    }    

    /**
    *  @dev Bytes Storage 
    */

    function getBytesValue(bytes32 record) constant returns (bytes) {
        return BytesStorage[record];
    }

    function setBytesValue(bytes32 record, bytes value) onlyAllowedContractOrOwner{
        BytesStorage[record] = value;
    }

    function deteleBytesValue(bytes32 record) onlyAllowedContractOrOwner{
        delete BytesStorage[record];
    }

    /**
    *  @dev Bytes32 Storage 
    */

    function getBytes32Value(bytes32 record) constant returns (bytes32) {
        return Bytes32Storage[record];
    }

    function setBytes32Value(bytes32 record, bytes32 value) onlyAllowedContractOrOwner {
        Bytes32Storage[record] = value;
    }

    function deleteBytes32Value(bytes32 record) onlyAllowedContractOrOwner {
        delete Bytes32Storage[record];
    }

    /**
    *  @dev Boolean Storage 
    */
    
    function getBooleanValue(bytes32 record) constant returns (bool){
        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value) onlyAllowedContractOrOwner {
        BooleanStorage[record] = value;
    }
    
    function deleteBooleanValue(bytes32 record) onlyAllowedContractOrOwner {
        delete BooleanStorage[record];
    }

    /**
    *  @dev Int Storage 
    */

    function getIntValue(bytes32 record) constant returns (int){
        return IntStorage[record];
    }

    function setIntValue(bytes32 record, int value) onlyAllowedContractOrOwner {
        IntStorage[record] = value;
    }

    function deleteIntValue(bytes32 record) onlyAllowedContractOrOwner {
        delete IntStorage[record];
    }

    /**
    *  @dev 
    */
    modifier onlyAllowedContractOrOwner {    
        //  if (allowedContracts[msg.sender] != true && msg.sender != contractOwner) {
        //      throw;  
        //  }         
        _;    
    }
}
