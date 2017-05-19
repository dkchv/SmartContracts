pragma solidity ^0.4.8;

import "./Configurable.sol";
import "./EternalStorage.sol";
import "./SharedLibrary.sol";

/** @title TODO */
library LOCLibrary {
    using LOCLibrary for LOCLibrary.LOC;

    /** @dev LaborX Offering Company Struct
    *   TODO: params
    */
    struct LOC {
        address eternalStorage;
        address owner;
        uint id;
        bytes32 name;
        bytes32 website;
        Configurable.Status status;
        uint issueLimit;
        uint issued;
        bytes32 ipfsHash;
        uint expireDate;
        uint createDate;
        uint updateDate;
        bytes32 securityPercentage;
    }

    /** @dev TODO
    * 
    */
    function isValid(LOC self) internal constant returns (bool valid) {
        // TODO: not yet implemented
        return true;
    }

    /** @dev TODO
   *
   */
    function getOwner(LOC self) internal constant returns (address owner) {
        owner = self.owner;
    }

    /** @dev TODO
    * 
    */
    function getId(LOC self) internal constant returns (uint id) {
        id = self.id;
    }

    /** @dev TODO
    * 
    */
    function setName(LOC self, bytes32 name) internal returns (bool success) {
        // TODO: check input value
        self.name = name;

        success = true;
    }

    /** @dev TODO
    * 
    */
    function getName(LOC self) internal constant returns (bytes32 name) {
        name = self.name;
    }

    /** @dev TODO
    * 
    */
    function setWebsite(LOC self, bytes32 website) internal returns (bool success) {
        // TODO: check input value
        self.website = website;

        success = true;
    }

    /** @dev TODO
    * 
    */
    function getWebsite(LOC self) internal constant returns (bytes32 website) {
        website = self.website;
    }

    /** @dev TODO
    * 
    */
    function setStatus(LOC self, Configurable.Status status) internal returns (bool success) {
        // TODO: check input value
        self.status = status;

        success = true;
    }

    /** @dev TODO
    * 
    */
    function getStatus(LOC self) internal constant returns (Configurable.Status status) {
        status = self.status;
    }

    /** @dev TODO
    * 
    */
    function setIssueLimit(LOC self, uint issueLimit) internal returns (bool success) {
        // TODO: check input value
        self.issueLimit = issueLimit;

        success = true;
    }

    function getIssueLimit(LOC self) internal constant returns (uint issueLimit) {
        issueLimit = self.issueLimit;
    }

    /** @dev TODO
    * 
    */
    function setIssued(LOC self, uint issued) internal returns (bool success) {
        if (issued > self.issueLimit) {
            return false;
        }

        self.issued = issued;

        success = true;
    }

    function getIssued(LOC self) internal constant returns (uint issued) {
        issued = self.issued;
    }

    /** @dev TODO
    * 
    */
    function setIpfsHash(LOC self, bytes32 ipfsHash) internal returns (bool success) {
        // TODO: check input value
        self.ipfsHash = ipfsHash;

        success = true;
    }

    function getIpfsHash(LOC self) internal constant returns (bytes32 ipfsHash) {
        ipfsHash = self.ipfsHash;
    }

    /** @dev TODO: docs
    *   
    */
    function setExpireDate(LOC self, uint expireDate) internal returns (bool success) {
        // TODO: check input value
        self.expireDate = expireDate;

        success = true;
    }

    /** @dev TODO: docs
    *   
    */
    function getExpireDate(LOC self) internal constant returns (uint expireDate) {
        expireDate = self.expireDate;
    }

    /** @dev TODO: docs
    *   
    */
    function setCreateDate(LOC self, uint createDate) internal returns (bool success) {
        if (createDate == 0x0) {
            return false;
            // Illegal agrument
        }

        if (self.createDate != 0x0) {
            return false;
            // It's not allowed to override creation date
        }

        self.createDate = createDate;

        success = true;
    }

    /** @dev TODO: docs
    *   
    */
    function getCreateDate(LOC self) internal constant returns (uint createDate) {
        createDate = self.createDate;
    }

    /*
    * Update Date getter/setter
    */

    /** @dev TODO: docs
    *   
    */
    function setUpdateDate(LOC self, uint updateDate) internal returns (bool success) {
        // TODO: check input value
        self.updateDate = updateDate;

        success = true;
    }

    /** @dev TODO: docs
    *   
    */
    function getUpdateDate(LOC self) internal constant returns (uint updateDate) {
        updateDate = self.updateDate;
    }

    /** @dev 
    *   TODO: docs
    */
    function isExists(uint locId, address eternalStorage) internal constant returns (bool) {
        if (locId == 0x0) return false;

        return (EternalStorage(eternalStorage).getUIntValue(sha3("loc/id", locId)) != 0x0);
    }

    /** @dev
    * TODO: docs
    */
    function isExistsWithIpfsHash(bytes32 ipfsHash, address eternalStorage) internal constant returns (bool) {
        if (ipfsHash == 0x0) return false;

        return (EternalStorage(eternalStorage).getUIntValue(sha3("ipfsHash/locId", ipfsHash)) != 0x0);
    }

    /** @dev Return count LOC's which are in storage
    * 
    */
    function getCount(address eternalStorage) internal constant returns (uint) {
        return SharedLibrary.getArrayItemsCount(eternalStorage, 1, "loc/count");
    }

    /** @dev 
    *   TODO: docs
    */
    function getIdAt(address eternalStorage, uint index) internal constant returns (uint) {
        return SharedLibrary.getItem(eternalStorage, 1, "loc/ids", index);
    }

    /** @dev 
    *   TODO: docs
    */
    function getIds(address eternalStorage) internal constant returns (uint[] ids) {
        ids = SharedLibrary.getUIntArray(eternalStorage, 1, "loc/ids", "loc/count");
        // TODO: replace '1'
    }

    /** @dev TODO
    * 
    */
    function getIdByIpfsHash(bytes32 ipfsHash, address eternalStorage) internal constant returns (uint) {
        return EternalStorage(eternalStorage).getUIntValue(sha3("ipfsHash/locId", ipfsHash));
    }

    /** @dev Creates new empty Loc object. Nothing is stored in Stroage at this stage. 
    *
    */
    function createEmpty(address eternalStorage) internal constant returns (LOC loc) {
        loc = LOCLibrary.LOC({
            eternalStorage : eternalStorage,
            owner : 0x0,
            id : 0x0,
            name : 0x0,
            website : 0x0,
            status : Configurable.Status.maintenance,
            issueLimit : 0x0,
            issued : 0x0,
            ipfsHash : 0x0,
            expireDate : 0x0,
            createDate : 0x0,
            updateDate : 0x0,
            securityPercentage : 0x0
        });
    }

    /** @dev Loads LOC info from Strogage
    *
    */
    function loadById(uint locId, address eternalStorage) internal constant returns (LOC loc) {
        if (!isExists(locId, eternalStorage)) throw;

        loc.eternalStorage = eternalStorage;
        loc.owner = EternalStorage(eternalStorage).getAddressValue(sha3("loc/owner", locId));
        loc.id = locId;

        loc.name = EternalStorage(eternalStorage).getBytes32Value(sha3("loc/name", locId));
        loc.website = EternalStorage(eternalStorage).getBytes32Value(sha3("loc/website", locId));
        loc.status = Configurable.Status(EternalStorage(eternalStorage).getUInt8Value(sha3("loc/status", locId)));
        loc.ipfsHash = EternalStorage(eternalStorage).getBytes32Value(sha3("loc/ipfsHash", locId));
        loc.issueLimit = EternalStorage(eternalStorage).getUIntValue(sha3("loc/issueLimit", locId));
        loc.issued = EternalStorage(eternalStorage).getUIntValue(sha3("loc/issued", locId));
        loc.expireDate = EternalStorage(eternalStorage).getUIntValue(sha3("loc/expireDate", locId));
        loc.createDate = EternalStorage(eternalStorage).getUIntValue(sha3("loc/createDate", locId));
        loc.updateDate = EternalStorage(eternalStorage).getUIntValue(sha3("loc/updateDate", locId));

        // just to be sure that valid data has been loaded from the storage
        if (!isValid(loc)) throw;
    }


    /** @dev Stores data
    * 
    */
    function save(LOC self) internal returns (bool success) {
        // Not properly created?
        if (self.eternalStorage == 0x0) throw;

        // Do not allow to store invalid or inconsistent data
        if (!isValid(self)) throw;

        // TODO: AG(11-05-2017) gas cost issue is possible here

        uint locId = self.id;
        if (locId == 0x0) {
            locId = SharedLibrary.createNext(self.eternalStorage, "loc/next");
            self.id = locId;
            self.owner = msg.sender;
            EternalStorage(self.eternalStorage).setAddressValue(sha3("loc/owner", locId), self.owner);
            EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/id", locId), locId);
            EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/createDate", locId), now);
            EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/expireDate", locId), self.expireDate);

            SharedLibrary.addItem(self.eternalStorage, 1, "loc/ids", "loc/count", locId);
        }
        else {
            EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/updateDate", locId), now);
        }

        EternalStorage(self.eternalStorage).setBytes32Value(sha3("loc/name", locId), self.name);
        EternalStorage(self.eternalStorage).setBytes32Value(sha3("loc/website", locId), self.website);
        EternalStorage(self.eternalStorage).setBytes32Value(sha3("loc/ipfsHash", locId), self.ipfsHash);
        EternalStorage(self.eternalStorage).setUInt8Value(sha3("loc/status", locId), uint8(self.status));
        EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/issueLimit", locId), self.issueLimit);
        EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/issued", locId), self.issued);

        EternalStorage(self.eternalStorage).setUIntValue(sha3("ipfsHash/locId", self.ipfsHash), locId);

        success = true;
    }

    /** @dev 
    * 
    */
    function remove(LOC self) internal returns (bool success) {
        if (!removeById(self.id, self.eternalStorage)) return false;

        self.eternalStorage = 0x0;
        self.owner = 0x0;
        self.id = 0x0;
        self.name = 0x0;
        self.website = 0x0;
        self.status = Configurable.Status.maintenance;
        self.issueLimit = 0x0;
        self.issued = 0x0;
        self.ipfsHash = 0x0;
        self.expireDate = 0x0;
        self.createDate = 0x0;
        self.updateDate = 0x0;
        self.securityPercentage = 0x0;

        success = true;
    }

    /**
    * TODO: docs
    * TODO: AG(11-05-2017) gas cost issue is possible here
    */
    function removeById(uint locId, address eternalStorage) internal returns (bool success) {
        bytes32 ipfsHash = EternalStorage(eternalStorage).getBytes32Value(sha3("loc/ipfsHash", locId));

        SharedLibrary.removeItem(eternalStorage, 1, "loc/ids", "loc/count", locId);

        EternalStorage(eternalStorage).deleteAddressValue(sha3("loc/owner", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("ipfsHash/locId", ipfsHash));
        EternalStorage(eternalStorage).deleteUInt8Value(sha3("loc/status", locId));
        EternalStorage(eternalStorage).deleteStringValue(sha3("loc/name", locId));
        EternalStorage(eternalStorage).deleteStringValue(sha3("loc/website", locId));
        EternalStorage(eternalStorage).deleteBytes32Value(sha3("loc/ipfsHash", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/issueLimit", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/issued", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/expireDate", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/createDate", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/updateDate", locId));

        success = true;
    }
}
