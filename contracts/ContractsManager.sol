pragma solidity ^0.4.11;

import "./Managed.sol";
import "./ExchangeInterface.sol";
import "./OwnedInterface.sol";

contract ContractsManager is Managed {

    enum ContractType {LOCManager, PendingManager, UserManager, ERC20Manager, ExchangeManager, TrackersManager, Voting, Rewards, TIME, LH, Assets}

    event LogAddContract(
    address contractAddr,
    ContractType tp,
    string description,
    bytes32 ipfsHash,
    bytes32 swarmHash
    );

    event LogRemoveContract(
    address contractAddr,
    ContractType tp,
    string description,
    bytes32 ipfsHash,
    bytes32 swarmHash
    );

    struct ContractMetadata {
    address contractAddr;
    ContractType tp;
    string description;
    bytes32 ipfsHash;
    bytes32 swarmHash;
    }

    event LogContractDescriptionChange(address contractAddr, string oldDescription, string newDescription);
    event LogContractAddressChange(address oldAddr, address newAddr);

    address[] public contractAddresses;

    mapping (address => bool) public timeHolder;

    mapping (address => ContractMetadata) contracts;
    mapping (uint => address) public contractByType;

    modifier contractExists(address _contract) {
        if (contracts[_contract].contractAddr != address(0)) {
            _;
        }
    }

    modifier contractDoesNotExist(address _contract) {
        if (contracts[_contract].contractAddr == address(0)) {
            _;
        }
    }

    function init(address _userStorage, address _shareable) returns (bool) {
        if (userStorage != 0x0) {
            return false;
        }
        userStorage = _userStorage;
        shareable = _shareable;
        return true;
    }

    /// @dev Returns an array containing all contracts addresses.
    /// @return Array of token addresses.
    function getContractAddresses() constant returns (address[]) {
        return contractAddresses;
    }

    function claimContractOwnership(address _addr, ContractType _type) contractDoesNotExist(_addr) onlyAuthorized() returns (bool) {
        if (OwnedInterface(_addr).claimContractOwnership()) {
            contractAddresses.push(_addr);
            contractByType[uint(_type)] = _addr;
            contracts[_addr] = ContractMetadata({
            contractAddr: _addr,
            tp: _type,
            description: '',
            ipfsHash: '',
            swarmHash: ''
            });
            return true;
        }
        return false;
    }

    function forward(ContractType _type, bytes data) onlyAuthorized() returns (bool) {
        if (!contractByType[uint(_type)].call(data)) {
            throw;
        }
        return true;
    }

    function getContractAddressByType(ContractType _type) constant returns (address contractAddress) {
        return contractByType[uint(_type)];
    }

    /// @dev Allow owner to add new contract
    function addContract(
    address _contractAddr,
    ContractType _type,
    string _description,
    bytes32 _ipfsHash,
    bytes32 _swarmHash)
    public
    multisig
    contractDoesNotExist(_contractAddr)
    {
        contracts[_contractAddr] = ContractMetadata({
        contractAddr: _contractAddr,
        tp: _type,
        description: _description,
        ipfsHash: _ipfsHash,
        swarmHash: _swarmHash
        });
        contractAddresses.push(_contractAddr);
        contractByType[uint(_type)] = _contractAddr;
        LogAddContract(
        _contractAddr,
        _type,
        _description,
        _ipfsHash,
        _swarmHash
        );
    }

    /// @dev Allows owner to remove an existing contract from the registry.
    /// @param _contractAddr Address of existing token.
    function removeContract(address _contractAddr)
    public
    onlyAuthorized()
    contractExists(_contractAddr)
    {
        for (uint i = 0; i < contractAddresses.length; i++) {
            if (contractAddresses[i] == _contractAddr) {
                contractAddresses[i] = contractAddresses[contractAddresses.length - 1];
                contractAddresses.length -= 1;
                break;
            }
        }
        ContractMetadata _contract = contracts[_contractAddr];
        LogRemoveContract(
        _contract.contractAddr,
        _contract.tp,
        _contract.description,
        _contract.ipfsHash,
        _contract.swarmHash
        );
        delete contractByType[uint(_contract.tp)];
        delete contracts[_contract.contractAddr];
    }

    /// @dev Allows owner to modify an existing contract's address.
    /// @param _contractAddr Address of contract.
    /// @param _newAddr New address of contract.
    function setContractAddress(address _contractAddr, address _newAddr)
    public
    onlyAuthorized()
    contractExists(_contractAddr)
    {
        ContractMetadata _contract = contracts[_contractAddr];
        _contract.contractAddr = _newAddr;
        contractByType[uint(_contract.tp)] = _newAddr;
        for (uint i = 0; i < contractAddresses.length; i++) {
            if (contractAddresses[i] == _contractAddr) {
                contractAddresses[i] = _newAddr;
                break;
            }
        }
        LogContractAddressChange(_contractAddr, _newAddr);
    }

    /// @dev Allows owner to modify an existing token's name.
    /// @param _contractAddr Address of contract.
    /// @param _description New description.
    function setContractDescription(address _contractAddr, string _description)
    public
    onlyAuthorized()
    contractExists(_contractAddr)
    {
        ContractMetadata _contract = contracts[_contractAddr];
        LogContractDescriptionChange(_contractAddr, _contract.description, _description);
        _contract.description = _description;
    }

    /// @dev Provides a registered token's metadata, looked up by address.
    /// @param _contractAddr Address of contract.
    /// @return Contract metadata.
    function getContractMetaData(address _contractAddr)
    constant returns (
    address contractAddr,
    ContractType tp,
    string description,
    bytes32 ipfsHash,
    bytes32 swarmHash
    )
    {
        ContractMetadata memory _contract = contracts[_contractAddr];
        return (
        _contract.contractAddr,
        _contract.tp,
        _contract.description,
        _contract.ipfsHash,
        _contract.swarmHash
        );
    }

    function()
    {
        throw;
    }
}
