pragma solidity ^0.4.8;

import "./Managed.sol";
import "./LOCManager.sol";

contract ChronoMint is Managed {
    address private locManager;
    address private contractManager;

    event newLOC(address from, uint locId);
    event remLOC(address from, uint locId);
    event updLOCStatus(address from, uint locId, Configurable.Status status);
    event updLOCValue(address from, uint locId, uint value, Configurable.Setting name);
    event updLOCString(address from, uint locId, bytes32 value, Configurable.Setting name);

    function init(address _userStorage, address _shareable, address _contractManager, address _locManager) returns(bool) {
        if (_userStorage == 0x0) throw;
        if (_shareable == 0x0) throw;
        if (_contractManager == 0x0) throw;
        if (_locManager == 0x0) throw;

        userStorage = _userStorage;
        shareable = _shareable;
        contractManager = _contractManager;
        locManager = _locManager;

        return true;
    }

    modifier isContractManager() {
        if (msg.sender == contractManager) {
            _;
        }
    }

    function setLOCIssued(uint locId, uint issued) isContractManager returns (bool success) {
        success = LOCManager(locManager).setIssued(locId, issued);

        if (success) {
            updLOCValue(this, locId, issued, Configurable.Setting.issued);
        }
    }

    function getLOCIssued(uint locId ) constant returns (uint issued) {
        issued = LOCManager(locManager).getIssued(locId);
    }

    function getLOCIssueLimit(uint locId) constant returns (uint issueLimit) {
        issueLimit = LOCManager(locManager).getIssueLimit(locId);
    }

    // function addLOC (uint locId) multisig {
    //     //TODO: not yet implemented

    //     newLOC(msg.sender, locId);
    // }

    function removeLOC(uint locId) multisig returns (bool success) {        
        success = LOCManager(locManager).removeById(locId);

        if (success) {
            remLOC(msg.sender, locId);
        }
    }

    function proposeLOC(bytes32 name, bytes32 website, uint issueLimit, bytes32 publishedHash, uint expDate) onlyAuthorized() returns(uint locId) {
        locId = LOCManager(locManager).create(name, website, issueLimit, publishedHash, expDate);
        newLOC(msg.sender, locId);
    }

    function setLOCStatus(uint locId, Configurable.Status status) multisig returns (bool success) {
        success = LOCManager(locManager).setStatus(locId, status);

        if (success) {
            updLOCStatus(msg.sender, locId, status);
        }
    }

    function setLOCString(uint locId, Configurable.Setting name, bytes32 value) multisig returns (bool success) {
        success = LOCManager(locManager).setString(locId, name, value);

        if (success) {
            updLOCString(msg.sender, locId, value, name);
        }
    }
     
     function getLOCString(uint locId, Configurable.Setting name) constant returns (bytes32 value) {
        value = LOCManager(locManager).getString(locId, name);
    }

    function getLOCbyID(uint locId) constant returns (bytes32 name, bytes32 website, uint issueLimit, bytes32 ipfsHash, uint expireDate, Configurable.Status status, address owner) {
        return LOCManager(locManager).getInfoById(locId);
    }

    function getLOCs() constant public returns(uint[] ids) {
        var count = LOCManager(locManager).getCount();
        ids = new uint[](count);
        for (uint i = 0; i < count; i++) {
            ids[i] = LOCManager(locManager).getIdAt(i);
        }
    }

    function getLOCCount () constant returns(uint count) {
        count = LOCManager(locManager).getCount();
    }

    function() {
        throw;
    }
}
