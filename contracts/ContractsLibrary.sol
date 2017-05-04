pragma solidity ^0.4.8;

import "./EternalStorage.sol";
import "./SharedLibrary.sol";

library ContractsLibrary {

    function getContractsCount(address db, uint tp) internal returns(uint) {
        return EternalStorage(db).getUIntValue(sha3("contracts/count",tp));
    }

    function getContractId(address db, address contractAddress) internal returns(uint){
        return EternalStorage(db).getUIntValue(sha3("contracts/ids", contractAddress));
    }
    
    function getContractAddress(address db, uint contractId) internal returns(address){
        return EternalStorage(db).getAddressValue(sha3("contracts/address", contractId));
    }

    function getContracts(address db, uint tp) internal returns(address[] result) {
        uint j = getContractsCount(db,tp);
        result = new address[](j);
        for(uint i = 0; i < j; i++) {
           result[i] = getContractAddress(db,i);
        }
        return result;
    }

    function setContract(address db,
        uint tp,
        address contractAddress
    )
        internal returns (uint)
    {
        uint contractId;
        uint existingContractId = getContractId(db, contractAddress);
        if (existingContractId > 0) {
           contractId = existingContractId;
        } else {
            contractId = SharedLibrary.createNext(db, "contracts/count");
            EternalStorage(db).setUIntValue(sha3("contracts/created-on", contractId), now);
            EternalStorage(db).setUIntValue(sha3("contracts/ids", contractAddress), contractId);
            EternalStorage(db).setAddressValue(sha3("contracts/address", contractId), contractAddress);
        }
        EternalStorage(db).setUIntValue(sha3("contracts/type", contractId), tp);
        return contractId;
    }

    function removeContract(address db, uint contractId) internal {
        address contractAddress = getContractAddress(db, contractId);

        EternalStorage(db).deleteUIntValue(sha3("contracts/ids", contractId));
        EternalStorage(db).deleteAddressValue(sha3("contracts/address", contractAddress));
        EternalStorage(db).deleteUIntValue(sha3("contracts/created-on", contractId));
        EternalStorage(db).deleteUIntValue(sha3("contracts/type", contractId));
    }

}
