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
    function isValid(LOC self) constant internal returns (bool valid) {
        // TODO
        return true;
    }

    /** @dev TODO
    * 
    */
    function setId(LOC self, uint id) internal returns (bool success) {
        // TODO: check input value
        self.id = id;

        success = true;
    } 

    /** @dev TODO
    * 
    */
    function getId(LOC storage self) constant internal returns (uint id) {
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
    function getStatus(LOC self) constant internal returns  (Configurable.Status status) {
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

    function getIssueLimit(LOC self) constant internal returns (uint issueLimit) {
        issueLimit = self.issueLimit;
    } 

    /** @dev TODO
    * 
    */
    function setIssued(LOC self, uint issued) internal returns (bool success) {
        // TODO: check input value
        self.issued = issued;

        success = true;
    } 

    function getIssued(LOC self) constant internal returns (uint issued) {
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

    function getIpfsHash(LOC self) constant internal returns (bytes32 ipfsHash) {
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
    function getExpireDate(LOC self) constant internal returns (uint expireDate) {
        expireDate = self.expireDate;
    } 

    /** @dev TODO: docs
    *   
    */
    function setCreateDate(LOC self, uint createDate) internal returns (bool success) {
        if (createDate == 0x0) {
            return false; // Illegal agrument
        }

        if (self.createDate != 0x0) {
            return false; // It's not allowed to override creation date
        }

        self.createDate = createDate;

        success = true;
    } 

    /** @dev TODO: docs
    *   
    */
    function getCreateDate(LOC self) constant internal returns (uint createDate) {
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
    function getUpdateDate(LOC self) constant internal returns (uint updateDate) {
        updateDate = self.updateDate;
    } 

    /** @dev 
    *   TODO: docs
    */
    function isExists(uint locId, address eternalStorage) internal constant returns(bool) {
        if (locId == 0x0) return false;

        return (EternalStorage(eternalStorage).getUIntValue(sha3("loc/id", locId)) != 0x0);
    }

    /** @dev
    * TODO: docs
    */
    function isExistsWithIpfsHash(bytes32 ipfsHash, address eternalStorage) internal constant returns(bool) {
        if (ipfsHash == 0x0) return false;

        return (EternalStorage(eternalStorage).getUIntValue(sha3("ipfsHash/locId", ipfsHash)) != 0x0);
    }

    /** @dev Return count LOC's which are in storage
    * 
    */
    function getCount(address eternalStorage) constant returns(uint) {
        return SharedLibrary.getCount(eternalStorage, "loc/count");
    }

    /** 
    * 
    */
    function getIdByIpfsHash(bytes32 ipfsHash, address eternalStorage) constant returns(uint) {
        return EternalStorage(eternalStorage).getUIntValue(sha3("ipfsHash/locId", ipfsHash));
    }

    /** @dev Creates new empty Loc object. Nothing is stored in Stroage at this stage. 
    *
    */
    function createEmpty(address eternalStorage) internal returns (LOC loc) {
        loc = LOCLibrary.LOC({
                        eternalStorage: eternalStorage,
                        id: 0x0,
                        name: 0x0,
                        website: 0x0,
                        status: Configurable.Status.maintenance,
                        issueLimit: 0x0,
                        issued: 0x0,
                        ipfsHash: 0x0,
                        expireDate: 0x0,
                        createDate: 0x0,
                        updateDate: 0x0,
                        securityPercentage: 0x0
        });
    }

    /** @dev Loads LOC info from Strogage
    *
    */
    function loadById(uint locId, address eternalStorage) constant internal returns(LOC loc) {   
        if (!isExists(locId, eternalStorage)) throw;

        loc.eternalStorage = eternalStorage;
        loc.setId(locId);    
        loc.setName(EternalStorage(eternalStorage).getBytes32Value(sha3("loc/name", locId)));    
        loc.setWebsite(EternalStorage(eternalStorage).getBytes32Value(sha3("loc/website", locId)));    
        loc.setStatus(Configurable.Status(EternalStorage(eternalStorage).getUInt8Value(sha3("loc/status", locId))));        
        loc.setIpfsHash(EternalStorage(eternalStorage).getBytes32Value(sha3("loc/ipfsHash", locId)));
        loc.setIssueLimit(EternalStorage(eternalStorage).getUIntValue(sha3("loc/issueLimit", locId)));        
        loc.setExpireDate(EternalStorage(eternalStorage).getUIntValue(sha3("loc/expireDate", locId)));
        loc.setCreateDate(EternalStorage(eternalStorage).getUIntValue(sha3("loc/createDate", locId)));
        loc.setUpdateDate(EternalStorage(eternalStorage).getUIntValue(sha3("loc/updateDate", locId)));    

        // just to be sure that valid data has been loaded from the storage
        if(!isValid(loc)) throw;
    }


    /** @dev Stores data
    * 
    */
    function save(LOC self) internal returns(bool success) {
        // Not properly created?
        if(self.eternalStorage == 0x0) throw; 

        // Do not allow to store invalid or inconsistent data
        if(!isValid(self)) throw; 

        uint locId = self.id;    
        if (locId == 0x0) {            
            locId = SharedLibrary.createNext(self.eternalStorage, "loc/next");            
            EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/id", locId), locId);
            EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/createDate", locId), now);            

            SharedLibrary.increment(self.eternalStorage, "loc/count");
        } else {
            EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/updateDate", locId), now);
        }
                    
        EternalStorage(self.eternalStorage).setBytes32Value(sha3("loc/name", locId), self.name);
        EternalStorage(self.eternalStorage).setBytes32Value(sha3("loc/website", locId), self.website);
        EternalStorage(self.eternalStorage).setBytes32Value(sha3("loc/ipfsHash", locId), self.ipfsHash);
        EternalStorage(self.eternalStorage).setUInt8Value(sha3("loc/status", locId), uint8(self.status));
        EternalStorage(self.eternalStorage).setUIntValue(sha3("loc/issueLimit", locId), self.issueLimit);

        EternalStorage(self.eternalStorage).setUIntValue(sha3("ipfsHash/locId", self.ipfsHash), locId);

        success = true;
    }

    /** @dev 
    * 
    */
    function remove(LOC self) internal returns(bool success) {        
         if (!removeById(self.id, self.eternalStorage)) return false;

         self.eternalStorage = 0x0;
         self.id = 0x0;
         self.name = 0x0;
         self.website = 0x0;
         self.status = Configurable.Status.maintenance;
         self.issueLimit = 0x0;
         self.ipfsHash = 0x0;
         self.expireDate = 0x0;
         self.createDate = 0x0;
         self.updateDate = 0x0;
         self.securityPercentage = 0x0;

         success = true;
    }

    /**
    * TODO: docs
    */
    function removeById(uint locId, address eternalStorage) internal returns(bool success) {                        
        bytes32 ipfsHash = EternalStorage(eternalStorage).getBytes32Value(sha3("loc/ipfsHash", locId));
        
        EternalStorage(eternalStorage).deleteUIntValue(sha3("ipfsHash/locId", ipfsHash));        
        EternalStorage(eternalStorage).deleteUInt8Value(sha3("loc/status", locId));        
        EternalStorage(eternalStorage).deleteStringValue(sha3("loc/name", locId));
        EternalStorage(eternalStorage).deleteStringValue(sha3("loc/website", locId));
        EternalStorage(eternalStorage).deleteBytes32Value(sha3("loc/ipfsHash", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/issueLimit", locId));                
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/expireDate", locId));
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/createDate", locId));    
        EternalStorage(eternalStorage).deleteUIntValue(sha3("loc/updateDate", locId));

        SharedLibrary.decrement(eternalStorage, "loc/count");

        success = true;
    }
}
