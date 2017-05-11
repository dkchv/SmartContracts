pragma solidity ^0.4.8;

import "./Configurable.sol";
import "./SharedLibrary.sol";
import "./LOCLibrary.sol";
import "./EternalStorage.sol";
import "./Strings.sol";

contract LOCManager is Configurable {    
    using Strings for *;
    using LOCLibrary for LOCLibrary.LOC;

    address private eternalStorage;

function LOCManager(address _eternalStorage) {
     if(_eternalStorage == 0x0) throw;

    eternalStorage = _eternalStorage;
}

modifier restricted () {
    _; // TODO: AG 
}

/** @dev 
*   TODO: docs
*/
function getCount() constant public returns (uint locCount) {
    locCount = LOCLibrary.getCount(eternalStorage);
}

/** @dev
*   TODO: docs
*/
function create(bytes32 name, bytes32 website, uint issueLimit, bytes32 ipfsHash, uint expireDate) restricted public returns (uint locId) {
    if(LOCLibrary.isExistsWithIpfsHash(ipfsHash, eternalStorage)) throw;
    
    LOCLibrary.LOC memory loc = LOCLibrary.createEmpty(eternalStorage);

    loc.setName(name);
    loc.setWebsite(website);
    loc.setIssueLimit(issueLimit);
    loc.setIpfsHash(ipfsHash);
    loc.setExpireDate(expireDate);

    if (!loc.save()) throw;
    
    return loc.id;
}


function setIssued(uint locId, uint issued) restricted public returns  (bool success) {
    if(!LOCLibrary.isExists(loc.id, eternalStorage)) throw;

    LOCLibrary.LOC memory loc = getById(locId);
    loc.setIssued(issued);

    success = update(loc);
}

function setStatus(uint locId, Configurable.Status status) restricted public returns  (bool success) {
    if(!LOCLibrary.isExists(loc.id, eternalStorage)) throw;

    LOCLibrary.LOC memory loc = getById(locId);
    loc.setStatus(status);

    success = update(loc);
}

function setString(uint locId, Configurable.Setting name, bytes32 value) restricted public returns  (bool success) {
    if(!LOCLibrary.isExists(loc.id, eternalStorage)) throw;

    LOCLibrary.LOC memory loc = getById(locId);

    if (name == Configurable.Setting.name) {
        loc.setName(value);
    } else if (name == Configurable.Setting.website) {
        loc.setWebsite(value);
    } else if (name == Configurable.Setting.publishedHash) {
        loc.setIpfsHash(value);
    } else {
        throw; // unexpected name
    }        

    success = update(loc);
}

/** @dev 
*   TODO: docs
*/
function removeByIpfsHash(bytes32 ipfsHash) restricted public returns (bool success) {    
    uint locId = LOCLibrary.getIdByIpfsHash(ipfsHash, eternalStorage);

    if (locId == 0x0) throw;

    return removeById(locId);    
}

/** @dev
*   TODO: docs
*/
function removeById(uint locId) restricted public returns (bool success) {
    success = LOCLibrary.removeById(locId, eternalStorage);
}

/** @dev 
*   TODO: docs
*/
function getInfoById(uint locId) restricted public returns (bytes32 name, bytes32 website, uint issueLimit, bytes32 ipfsHash, uint expireDate) {
    LOCLibrary.LOC memory loc = LOCLibrary.loadById(locId, eternalStorage);

    name = loc.name;
    website = loc.website;
    issueLimit = loc.issueLimit;
    ipfsHash = loc.ipfsHash;
    expireDate = loc.expireDate;
}

/** @dev 
*   TODO: docs
*/
function getById(uint locId) restricted internal returns (LOCLibrary.LOC loc) {
    loc = LOCLibrary.loadById(locId, eternalStorage);
}

/** @dev 
*   TODO: docs
*/
function update(LOCLibrary.LOC loc) restricted internal returns (bool success) {
    if(!LOCLibrary.isExists(loc.id, eternalStorage)) throw;
      
    if (!LOCLibrary.save(loc)) throw;

    return true;
}

function() {
    throw;
}

// ---------

// function deletedIdsLength() constant returns  (uint) {
//         return deletedIds.length;
//     }

//     function setLOCIssued(address _LOCaddr, uint _issued) isContractManager returns  (bool) {
//         updLOCValue(this, _LOCaddr, _issued, Configurable.Setting.issued);
//         return LOC(_LOCaddr).setIssued(_issued);
//     }

//     function addLOC (address _locAddr) multisig {
//         if(deletedIds.length != 0) {
//             offeringCompaniesIDs[_locAddr] = deletedIds[deletedIds.length-1];
//             offeringCompanies[deletedIds[deletedIds.length-1]] = _locAddr;
//             deletedIds.length--;
//         }
//         else {
//             offeringCompaniesIDs[_locAddr] = offeringCompaniesCounter;
//             offeringCompanies[offeringCompaniesIDs[_locAddr]] = _locAddr;
//             offeringCompaniesCounter++;

//         }
//         newLOC(msg.sender, _locAddr);
//     }

//     function removeLOC(address _locAddr) multisig returns  (bool) {
//         delete offeringCompanies[offeringCompaniesIDs[_locAddr]];
//         deletedIds.push(offeringCompaniesIDs[_locAddr]);
//         delete offeringCompaniesIDs[_locAddr];
//         remLOC(msg.sender, _locAddr);
//         return true;
//     }

//     function proposeLOC(bytes32 _name, bytes32 _website, uint _issueLimit, bytes32 _publishedHash, uint _expDate) onlyAuthorized() returns (address) {
//         address locAddr = new LOC();
//         LOC(locAddr).setLOC(_name,_website,_issueLimit,_publishedHash, _expDate);
//         if(deletedIds.length != 0) {
//             offeringCompaniesIDs[locAddr] = deletedIds[deletedIds.length-1];
//             offeringCompanies[deletedIds[deletedIds.length-1]] = locAddr;
//             deletedIds.length--;
//         }
//         else {
//             offeringCompaniesIDs[locAddr] = offeringCompaniesCounter;
//             offeringCompanies[offeringCompaniesIDs[locAddr]] = locAddr;
//             offeringCompaniesCounter++;

//         }
//         newLOC(msg.sender, locAddr);
//         return locAddr;
//     }

//     function setLOCStatus(address _LOCaddr, LOC.Status status) multisig {
//         LOC(_LOCaddr).setStatus(status);
//         updLOCStatus(msg.sender, _LOCaddr, status);
//     }

//     function setLOCString(address _LOCaddr, LOC.Setting name, bytes32 value) multisig {
//         LOC(_LOCaddr).setString(uint(name),value);
//         updLOCString(msg.sender, _LOCaddr, value, name);
//     }

//     function getLOCs() constant returns (address[] result) {
//         result = new address[](offeringCompaniesCounter);
//         for(uint i=0; i<offeringCompaniesCounter; i++) {
//             result[i]=offeringCompanies[i];
//         }
//         return result;
//     }
}
