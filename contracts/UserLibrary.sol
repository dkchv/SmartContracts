pragma solidity ^0.4.8;

import "./EternalStorage.sol";
import "./SharedLibrary.sol";

library UserLibrary {

    function getUserCount(address db) internal returns(uint) {
        return EternalStorage(db).getUIntValue(sha3("user/count"));
    }

    function getUserId(address db, address userAddress) internal returns(uint){
        return EternalStorage(db).getUIntValue(sha3("user/ids", userAddress));
    }

    function getUserIds(address db, address[] addresses) internal returns(uint[] result) {
        uint j;
        result = new uint[](addresses.length);
        for (uint i = 0; i < addresses.length ; i++) {
            result[i] = getUserId(db, addresses[i]);
        }
        return result;
    }

    function getUserAddress(address db, uint userId) internal returns(address) {
        return EternalStorage(db).getAddressValue(sha3("user/address", userId));
    }
   
    function getUserName(address db, uint userId) internal returns(bytes32[] result) {
        // result = EternalStorage(db).getStringValue(sha3("user/name", userId));        
        // return result;
    }

    function setUser(address db, address key, string name) internal returns (uint) {
        uint userId;
        uint existingUserId = getUserId(db, key);
        if (existingUserId > 0) {
            userId = existingUserId;
        } else {
            userId = SharedLibrary.createNext(db, "user/count");
            EternalStorage(db).setUIntValue(sha3("user/created-on", userId), now);
            EternalStorage(db).setUIntValue(sha3("user/ids", key), userId);
            EternalStorage(db).setAddressValue(sha3("user/address", userId), key);
        }
        EternalStorage(db).setStringValue(sha3("user/name", userId), name);
        return userId;
    }

}
