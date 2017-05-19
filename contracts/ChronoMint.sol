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

    function init(address _userStorage, address _shareable, address _contractManager, address _locManager) returns (bool) {
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

    /** @dev TODO
    *
    */
    function getLOCbyID(uint locId) constant returns (
        bytes32 name, 
        bytes32 website, 
        uint issueLimit, 
        bytes32 ipfsHash, 
        uint expireDate, 
        Configurable.Status status, 
        address owner
    ) {
        return LOCManager(locManager).getInfoById(locId);
    }

    /** @dev TODO
    *
    */
    function getLOCCount() public constant returns (uint count) {
        count = LOCManager(locManager).getCount();
    }

    /** @dev TODO
    *
    */
    function getLOCs() public constant returns (uint[] ids) {
        var count = LOCManager(locManager).getCount();
        ids = new uint[](count);
        for (uint i = 0; i < count; i++) {
            ids[i] = LOCManager(locManager).getIdAt(i);
        }
    }

    /** @dev TODO
    *
    */
    function getLOCIssued(uint locId) public constant returns (uint issued) {
        issued = LOCManager(locManager).getIssued(locId);
    }

    /** @dev TODO
    *
    */
    function getLOCString(uint locId, Configurable.Setting name) public constant returns (bytes32 value) {
        value = LOCManager(locManager).getString(locId, name);
    }

    /** @dev TODO
    *
    */
    function getLOCIssueLimit(uint locId) public constant returns (uint issueLimit) {
        issueLimit = LOCManager(locManager).getIssueLimit(locId);
    }

    /** @dev TODO
    *
    */
    function setLOCIssued(uint locId, uint issued) public isContractManager returns (bool success) {
        success = LOCManager(locManager).setIssued(locId, issued);

        if (success) {
            updLOCValue(this, locId, issued, Configurable.Setting.issued);
        }
    }

    /** @dev TODO
    *
    */
    function setLOCStatus(uint locId, Configurable.Status status) public multisig returns (bool success) {
        success = LOCManager(locManager).setStatus(locId, status);

        if (success) {
            updLOCStatus(msg.sender, locId, status);
        }
    }

    /** @dev TODO
    *
    */
    function setLOCString(uint locId, Configurable.Setting name, bytes32 value) public multisig returns (bool success) {
        success = LOCManager(locManager).setString(locId, name, value);

        if (success) {
            updLOCString(msg.sender, locId, value, name);
        }
    } 

    /** @dev TODO
    *
    */
    function removeLOC(uint locId) public multisig returns (bool success) {
        success = LOCManager(locManager).removeById(locId);

        if (success) {
            remLOC(msg.sender, locId);
        }
    }

    /** @dev TODO
    *
    */
    function proposeLOC(
        bytes32 name, 
        bytes32 website, 
        uint issueLimit, 
        bytes32 publishedHash, 
        uint expDate
    ) public onlyAuthorized() returns (uint locId) {
        locId = LOCManager(locManager).create(name, website, issueLimit, publishedHash, expDate);
        newLOC(msg.sender, locId);
    }   

    function() {
        throw;
    }
}
