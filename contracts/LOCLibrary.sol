pragma solidity ^0.4.8;

import "./EternalStorage.sol";
import "./SharedLibrary.sol";
import "./UserLibrary.sol";

library LOCLibrary {

    function getLOCCount(address db) internal returns(uint) {
        return EternalStorage(db).getUIntValue(sha3("loc/count"));
    }

    function getLOCId(address db, bytes32 ipfsHash) internal returns(uint){
        return EternalStorage(db).getUIntValue(sha3("loc/ids", ipfsHash));
    }

    function getLOCIds(address db, bytes32[] hashes) internal returns(uint[] result) {
   //     uint j;
   //     result = new uint[](addresses.length);
   //     for (uint i = 0; i < addresses.length ; i++) {
   //         result[i] = getLOCId(db, addresses[i]);
   //     }
   //     return result;
    }

    function getLOCAddress(address db, uint userId) internal returns(address){
        return EternalStorage(db).getAddressValue(sha3("loc/address", userId));
    }

    function setLOC(address db,
        string name,
        string website,
        uint issueLimit,
        bytes32 ipfsHash
    )
        internal returns (uint)
    {
        uint locId;
        uint existingLOCId = getLOCId(db, ipfsHash);
        if (existingLOCId > 0) {
            locId = existingLOCId;
        } else {
            locId = SharedLibrary.createNext(db, "loc/count");
            EternalStorage(db).setUIntValue(sha3("loc/created-on", locId), now);
            EternalStorage(db).setUIntValue(sha3("loc/ids", ipfsHash), locId);
            EternalStorage(db).setBytes32Value(sha3("user/ipfsHash", locId), ipfsHash);
            EternalStorage(db).setUInt8Value(sha3("user/status", locId), 1);
        }
        EternalStorage(db).setStringValue(sha3("loc/name", locId), name);
        EternalStorage(db).setStringValue(sha3("loc/website", locId), website);
        EternalStorage(db).setUIntValue(sha3("loc/issueLimit", locId), issueLimit);
        return locId;
    }
}
