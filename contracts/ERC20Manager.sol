pragma solidity ^0.4.8;

import "./Managed.sol";
import "./ChronoBankPlatformInterface.sol";
import "./ERC20Interface.sol";
import "./ExchangeInterface.sol";
import "./OwnedInterface.sol";
import "./LOCInterface.sol";
import "./ChronoMintInterface.sol";
import "./FeeInterface.sol";
import "./ChronoBankAssetProxyInterface.sol";

contract ERC20Manager is Managed {
    uint contractsCounter = 1;
    mapping (uint => address) internal contracts;
    uint[] deletedIds;
    mapping (address => uint) public contractsId;
    mapping (uint => bytes32) internal contractsHash;
    event UpdateContract(address contractAddress, uint id);

    function init(address _userStorage, address _shareable) returns (bool) {
        if (userStorage != 0x0) {
            return false;
        }
        userStorage = _userStorage;
        shareable = _shareable;
        return true;
    }

    function getContractsCounter() constant returns(uint) {
        return contractsCounter - deletedIds.length - 1;
    }

    function setContractHash(uint _id, bytes32 _hash) onlyAuthorized() returns (bool) {
        contractsHash[_id] = _hash;
        return true;
    }

    function getContractHash(uint _id) constant returns (bytes32) {
        return (contractsHash[_id]);
    }

    function getContracts() constant returns (address[] result) {
        result = new address[](contractsCounter - 1);
        for (uint i = 0; i < contractsCounter - 1; i++) {
            if(contracts[i + 1] != 0x0)
            result[i] = contracts[i + 1];
        }
        return result;
    }

    function claimContractOwnership(address _addr, bool _erc20) onlyAuthorized() returns (bool) {
        if (OwnedInterface(_addr).claimContractOwnership()) {
            if(_erc20) {
                setAddressInt(_addr);
            }
            else {
                setOtherAddressInt(_addr);
            }
            return true;
        }
re

}