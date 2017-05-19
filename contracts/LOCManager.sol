pragma solidity ^0.4.8;


import "./Configurable.sol";
import "./LOCLibrary.sol";


contract LOCManager is Configurable {
    using Strings for *;
    using LOCLibrary for LOCLibrary.LOC;

    address private eternalStorage;

    function LOCManager(address _eternalStorage) {
        if (_eternalStorage == 0x0) throw;

        eternalStorage = _eternalStorage;
    }

    modifier restricted () {
        _;
        // TODO: AG
    }

    /** @dev
    *   TODO: docs
    */
    function getCount() external constant returns (uint locCount) {
        locCount = LOCLibrary.getCount(eternalStorage);
    }

    /** @dev
    *   TODO: docs
    */
    function getIdAt(uint index) external constant returns (uint locCount) {
        locCount = LOCLibrary.getIdAt(eternalStorage, index);
    }

    /** @dev
    *   TODO: docs
    */
    function getOwner(uint locId) external constant returns (address owner) {
        if (!LOCLibrary.isExists(locId, eternalStorage)) throw;

        LOCLibrary.LOC memory loc = getById(locId);
        owner = loc.getOwner();
    }

    /** @dev
    *   TODO: docs
    */
    function getIssued(uint locId) external constant returns (uint issued) {
        if (!LOCLibrary.isExists(locId, eternalStorage)) throw;

        LOCLibrary.LOC memory loc = getById(locId);
        issued = loc.getIssued();
    }

    /** @dev
    *   TODO: docs
    */
    function getIssueLimit(uint locId) external constant returns (uint issued) {
        if (!LOCLibrary.isExists(locId, eternalStorage)) throw;

        LOCLibrary.LOC memory loc = getById(locId);
        issued = loc.getIssueLimit();
    }

    /** @dev
    *   TODO: docs
    */
    function getString(uint locId, Configurable.Setting name) external constant returns (bytes32 value) {
        if (!LOCLibrary.isExists(locId, eternalStorage)) throw;

        LOCLibrary.LOC memory loc = getById(locId);

        if (name == Configurable.Setting.name) {
            value = loc.getName();
        } else if (name == Configurable.Setting.website) {
            value = loc.getWebsite();
        } else if (name == Configurable.Setting.publishedHash) {
            value = loc.getIpfsHash();
        } else {
            throw; // unexpected name
        }
    }

    /** @dev
    *   TODO: docs
    */
    function getIds() restricted external constant returns (uint[] ids) {
        ids = LOCLibrary.getIds(eternalStorage);
    }

    /** @dev
    *   TODO: docs
    */
    function getInfoById(uint locId) public constant 
    returns (
        bytes32 name,
        bytes32 website,
        uint issueLimit,
        bytes32 ipfsHash,
        uint expireDate,
        Configurable.Status status,
        address owner
    ) {
        LOCLibrary.LOC memory loc = LOCLibrary.loadById(locId, eternalStorage);

        name = loc.getName();
        website = loc.getWebsite();
        issueLimit = loc.getIssueLimit();
        ipfsHash = loc.getIpfsHash();
        expireDate = loc.getExpireDate();
        status = loc.getStatus();
        owner = loc.getOwner();
    }

    /** @dev
    *   TODO: docs
    */
    function create(
        bytes32 name, 
        bytes32 website, 
        uint issueLimit, 
        bytes32 ipfsHash, 
        uint expireDate
    ) external restricted returns (uint locId) {
        if (LOCLibrary.isExistsWithIpfsHash(ipfsHash, eternalStorage)) throw;

        LOCLibrary.LOC memory loc = LOCLibrary.createEmpty(eternalStorage);

        loc.setName(name);
        loc.setWebsite(website);
        loc.setIssueLimit(issueLimit);
        loc.setIpfsHash(ipfsHash);
        loc.setExpireDate(expireDate);
        loc.setStatus(Configurable.Status.maintenance);

        if (!loc.save()) throw;

        locId = loc.id;
    }

    /** @dev
    *   TODO: docs
    */
    function setStatus(uint locId, Configurable.Status status) external restricted returns (bool success) {
        if (!LOCLibrary.isExists(locId, eternalStorage)) throw;

        LOCLibrary.LOC memory loc = getById(locId);
        loc.setStatus(status);

        success = update(loc);
    }

    /** @dev
    *   TODO: docs
    */
    function setIssued(uint locId, uint issued) external restricted returns (bool success) {
        if (!LOCLibrary.isExists(locId, eternalStorage)) throw;

        LOCLibrary.LOC memory loc = getById(locId);
        success = loc.setIssued(issued);
        if (success) {
            success = update(loc);
        }
    }

    /** @dev
    *   TODO: docs
    */
    function setString(uint locId, Configurable.Setting name, bytes32 value) external restricted returns (bool success) {
        if (!LOCLibrary.isExists(locId, eternalStorage)) throw;

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
    function removeByIpfsHash(bytes32 ipfsHash) external restricted returns (bool success) {
        uint locId = LOCLibrary.getIdByIpfsHash(ipfsHash, eternalStorage);

        if (locId == 0x0) throw;

        return removeById(locId);
    }

    /** @dev
    *   TODO: docs
    */
    function removeById(uint locId) public restricted returns (bool success) {
        success = LOCLibrary.removeById(locId, eternalStorage);
    }

    /** @dev
    *   TODO: docs
    */
    function getById(uint locId) internal constant returns (LOCLibrary.LOC loc) {
        loc = LOCLibrary.loadById(locId, eternalStorage);
    }

    /** @dev
    *   TODO: docs
    */
    function update(LOCLibrary.LOC loc) internal restricted returns (bool success) {
        if (!LOCLibrary.isExists(loc.id, eternalStorage)) throw;

        if (!LOCLibrary.save(loc)) throw;

        return true;
    }

    function() {
        throw;
    }
}
