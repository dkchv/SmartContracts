pragma solidity ^0.4.8;

import "./Managed.sol";
import "./UserStorage.sol";

contract Emitter {
    function cbeUpdate(address key);
    function setRequired(uint required);
    function hashUpdate(bytes32 oldHash, bytes32 newHash);
    function emitError(bytes32 _message);
}

contract UserManager is Managed {
    address userStorage;

    function init(address _userStorage, address _contractsManager) returns (bool) {
        if (userStorage != 0x0) {
            return false;
        }
        userStorage = _userStorage;
        UserStorage(userStorage).addMember(msg.sender, true);
        if(contractsManager != 0x0)
        return false;
        if(!ContractsManagerInterface(_contractsManager).addContract(this,ContractsManagerInterface.ContractType.UserManager,'Users Manager',0x0,0x0))
        return false;
        contractsManager = _contractsManager;
        return true;
    }

    // Should use interface of the emitter, but address of events history.
    Emitter public eventsHistory;

    /**
     * Emits Error event with specified error message.
     *
     * Should only be used if no state changes happened.
     *
     * @param _message error message.
     */
    function _error(bytes32 _message) internal {
        eventsHistory.emitError(_message);
    }
    /**
     * Sets EventsHstory contract address.
     *
     * Can be set only once, and only by contract owner.
     *
     * @param _eventsHistory EventsHistory contract address.
     *
     * @return success.
     */
    function setupEventsHistory(address _eventsHistory) onlyAuthorized returns(bool) {
        if (address(eventsHistory) != 0) {
            return false;
        }
        eventsHistory = Emitter(_eventsHistory);
        return true;
    }

    function addCBE(address _key, bytes32 _hash) multisig {
        if (!UserStorage(userStorage).getCBE(_key)) { // Make sure that the key being submitted isn't already CBE
            if (UserStorage(userStorage).addMember(_key, true) || UserStorage(userStorage).setCBE(_key, true)) {
                setMemberHash(_key, _hash);
                eventsHistory.cbeUpdate(_key);
            }
        } else {
            _error("This address is already CBE");
        }
    }

    function revokeCBE(address _key) multisig {
        if (UserStorage(userStorage).getCBE(_key)) { // Make sure that the key being revoked is exist and is CBE
            UserStorage(userStorage).setCBE(_key, false);
            eventsHistory.cbeUpdate(_key);
        }
        else {
            _error("This address in not CBE");
        }
    }

    function createMemberIfNotExist(address key) internal returns (bool) {
        return UserStorage(userStorage).addMember(key, false);
    }

    function setMemberHash(address key, bytes32 _hash) onlyAuthorized returns (bool) {
        return setMemberHashInt(key, _hash);
    }

    function setMemberHashInt(address key, bytes32 _hash) internal returns (bool) {
        createMemberIfNotExist(key);
        bytes32 oldHash = getMemberHash(key);
        if(!(_hash == oldHash)) {
            eventsHistory.hashUpdate(oldHash, _hash);
            UserStorage(userStorage).setHashes(key, _hash);
            return true;
        }
        _error("Same hash set");
        return false;
    }

    function setOwnHash(bytes32 _hash) returns (bool) {
        return setMemberHashInt(msg.sender, _hash);
    }

    function setRequired(uint _required) multisig returns (bool) {
        if (UserStorage(userStorage).setRequired(_required)) {
            eventsHistory.setRequired(_required);
            return true;
        }
        _error("Required to high");
        return false;
    }

    function getMemberHash(address key) constant returns (bytes32) {
        return UserStorage(userStorage).getHash(key);
    }

    function getCBE(address key) constant returns (bool) {
        return UserStorage(userStorage).getCBE(key);
    }

    function getMemberId(address sender) constant returns (uint) {
        return UserStorage(userStorage).getMemberId(sender);
    }

    function required() constant returns (uint) {
        return UserStorage(userStorage).required();
    }

    function adminCount() constant returns (uint) {
        return UserStorage(userStorage).adminCount();
    }

    function userCount() constant returns (uint) {
        return UserStorage(userStorage).userCount();
    }

    function getCBEMembers() constant returns (address[] addresses, bytes32[] hashes) {
        addresses = new address[](UserStorage(userStorage).adminCount());
        hashes = new bytes32[](UserStorage(userStorage).adminCount());
        uint j = 0;
        address memberAddr;
        bytes32 hash;
        bool isCBE;
        for (uint i = 1; i < UserStorage(userStorage).userCount(); i++) {
            (memberAddr,hash,isCBE) = UserStorage(userStorage).members(i);
            if (isCBE) {
                addresses[j] = memberAddr;
                hashes[j] = hash;
                j++;
            }
        }
        return (addresses, hashes);
    }

    function()
    {
        throw;
    }
}
