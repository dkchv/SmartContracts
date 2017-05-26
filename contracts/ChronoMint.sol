pragma solidity ^0.4.8;

import "./Managed.sol";
import "./ContractsManager.sol";
import "./ChronoBankPlatformInterface.sol";
import "./ERC20Interface.sol";
import "./ERC20ManagerInterface.sol";
import "./FeeInterface.sol";
import "./ChronoBankAssetProxyInterface.sol";

contract Emitter {

    function newLOC(bytes32 locName);
    function remLOC(bytes32 locName);
    function updLOCStatus(bytes32 locName, uint _oldStatus, uint _newStatus);
    function updLOCValue(bytes32 locName);
    function reissue(uint value, bytes32 locName);
    function hashUpdate(bytes32 oldHash, bytes32 newHash);
    function emitError(bytes32 _message);
}

contract ChronoMint is Managed {
    address contractsManager;
    mapping (address => bool) timeHolder;
    mapping (bytes32 => LOC) offeringCompanies;
    bytes32[] public offeringCompaniesNames;

    enum Status {maintenance, active, suspended, bankrupt}

    struct LOC {
    bytes32 name;
    bytes32 website;
    uint issued;
    uint issueLimit;
    bytes32 publishedHash;
    uint expDate;
    Status status;
    uint securityPercentage;
    }

    function init(address _userStorage, address _shareable, address _contractsManager) returns(bool) {
        if (userStorage != 0x0) {
            return false;
        }
        userStorage = _userStorage;
        shareable = _shareable;
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
    function setupEventsHistory(address _eventsHistory) returns(bool) {
        if (address(eventsHistory) != 0) {
            return false;
        }
        eventsHistory = Emitter(_eventsHistory);
        return true;
    }

    // this method is implemented only for test purposes
    function sendTime() returns (bool) {
        if(!timeHolder[msg.sender]) {
            timeHolder[msg.sender] = true;
            return ERC20Interface(ERC20ManagerInterface(ContractsManager(contractsManager).contractByType(uint(ContractsManager.ContractType.ERC20Manager))).getTokenAddressBySymbol('TIME')).transfer(msg.sender, 1000000000);
        }
        else {
            return false;
        }
    }

    function getBalance(string symbol) constant returns (uint) {
        return ERC20Interface(ERC20ManagerInterface(ContractsManager(contractsManager).contractByType(uint(ContractsManager.ContractType.ERC20Manager))).getTokenAddressBySymbol(symbol)).balanceOf(this);
    }

    modifier locExists(bytes32 _locName) {
        if (offeringCompanies[_locName].name != bytes32(0)) {
            _;
        }
    }

    modifier locDoesNotExist(bytes32 _locName) {
        if (offeringCompanies[_locName].name == bytes32(0)) {
            _;
        }
    }

    function sendAsset(string symbol, address _to, uint _value) onlyAuthorized() returns (bool) {
        if(sha3(symbol) == sha3('LHT')) {
            uint feePercent = FeeInterface(ChronoBankAssetProxyInterface(ERC20ManagerInterface(ContractsManager(contractsManager).contractByType(uint(ContractsManager.ContractType.ERC20Manager))).getTokenAddressBySymbol(symbol)).getLatestVersion()).feePercent();
            uint amount = (_value * 10000)/(10000 + feePercent);
            return ERC20Interface(ERC20ManagerInterface(ContractsManager(contractsManager).contractByType(uint(ContractsManager.ContractType.ERC20Manager))).getTokenAddressBySymbol(symbol)).transfer(_to, amount);
        }
        return ERC20Interface(ERC20ManagerInterface(ContractsManager(contractsManager).contractByType(uint(ContractsManager.ContractType.ERC20Manager))).getTokenAddressBySymbol(symbol)).transfer(_to, _value);
    }

    function reissueAsset(bytes32 symbol, uint _value, bytes32 _locName) multisig returns (bool) {
        if(symbol != 0x0) {
            address platform = ContractsManager(contractsManager).contractByType(uint(ContractsManager.ContractType.LH));
            if (platform != 0x0 && ChronoBankPlatformInterface(platform).isReissuable(symbol)) {
                uint issued = offeringCompanies[_locName].issued;
                if(_value <= offeringCompanies[_locName].issueLimit - issued) {
                    if(ChronoBankPlatformInterface(platform).reissueAsset(symbol, _value)) {
                        offeringCompanies[_locName].issued = issued + _value;
                        eventsHistory.reissue(_value,_locName);
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function revokeAsset(bytes32 symbol, uint _value, bytes32 _locName) multisig returns (bool) {
        if(symbol != 0x0) {
            address platform = ContractsManager(contractsManager).contractByType(uint(ContractsManager.ContractType.LH));
            if (platform != 0x0 && ChronoBankPlatformInterface(platform).isReissuable(symbol)) {
                uint issued = offeringCompanies[_locName].issued;
                if(_value <= issued) {
                    if(ChronoBankPlatformInterface(platform).revokeAsset(symbol, _value)) {
                        offeringCompanies[_locName].issued = issued - _value;
                        eventsHistory.reissue(_value, _locName);
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function removeLOC(bytes32 _name) locExists(_name) multisig returns (bool) {
        for (uint i = 0; i < offeringCompaniesNames.length; i++) {
            if (offeringCompaniesNames[i] == _name) {
                offeringCompaniesNames[i] = offeringCompaniesNames[offeringCompaniesNames.length - 1];
                offeringCompaniesNames.length -= 1;
                break;
            }
        }
        delete offeringCompanies[_name];
        eventsHistory.remLOC(_name);
        return true;
    }

    function addLOC(bytes32 _name, bytes32 _website, uint _issueLimit, bytes32 _publishedHash, uint _expDate) onlyAuthorized() locDoesNotExist(_name) returns(uint) {
        offeringCompanies[_name] = LOC({name: _name,website:_website,issued:0,issueLimit:_issueLimit,publishedHash:_publishedHash,expDate:_expDate, status:Status.maintenance,securityPercentage:0});
        offeringCompaniesNames.push(_name);
        eventsHistory.newLOC(_name);
        return offeringCompaniesNames.length;
    }

    function setLOC(bytes32 _name, bytes32 _website, uint _issueLimit, bytes32 _publishedHash, uint _expDate) onlyAuthorized() locExists(_name) returns(uint) {
        LOC loc = offeringCompanies[_name];
        bool changed;
        uint _id;
        for (uint i = 0; i < offeringCompaniesNames.length; i++) {
            if (offeringCompaniesNames[i] == loc.name) {
                _id = i;
                break;
            }
        }
        if(!(_name == loc.name)) {
            offeringCompaniesNames[_id] = _name;
            loc.name = _name;
            changed = true;
        }
        if(!(_website == loc.website)) {
            loc.website = _website;
            changed = true;
        }
        if(!(_issueLimit == loc.issueLimit)) {
            loc.issueLimit = _issueLimit;
            changed = true;
        }
        if(!(_publishedHash == loc.publishedHash)) {
            eventsHistory.hashUpdate(loc.publishedHash,_publishedHash);
            loc.publishedHash = _publishedHash;
            changed = true;
        }
        if(!(_expDate == loc.expDate)) {
            loc.expDate = _expDate;
            changed = true;
        }
        if(changed) {
            offeringCompanies[_name] = loc;
            eventsHistory.updLOCValue(_name);
        }
        return offeringCompaniesNames.length;
    }

    function setStatus(bytes32 _name, Status status) locExists(_name) multisig {
        LOC loc = offeringCompanies[_name];
        if(!(loc.status == status)) {
            eventsHistory.updLOCStatus(_name, uint(loc.status), uint(status));
            loc.status = status;
        } else {

        }
    }

    function getLOCByName(bytes32 _locName) constant returns(bytes32 name,
    bytes32 website,
    uint issued,
    uint issueLimit,
    bytes32 publishedHash,
    uint expDate,
    Status status,
    uint securityPercentage) {
        LOC loc = offeringCompanies[_locName];
        return(loc.name, loc.website, loc.issued, loc.issueLimit, loc.publishedHash, loc.expDate, loc.status, loc.securityPercentage);
    }

    function getLOCById(uint _id) constant returns(bytes32 name,
    bytes32 website,
    uint issued,
    uint issueLimit,
    bytes32 publishedHash,
    uint expDate,
    Status status,
    uint securityPercentage) {
        LOC loc = offeringCompanies[offeringCompaniesNames[_id]];
        return(loc.name, loc.website, loc.issued, loc.issueLimit, loc.publishedHash, loc.expDate, loc.status, loc.securityPercentage);
    }

    function getLOCNames() constant returns(bytes32[]) {
        return offeringCompaniesNames;
    }

    function getLOCCount() constant returns(uint) {
        return offeringCompaniesNames.length;
    }

    function()
    {
        throw;
    }
}
