pragma solidity ^0.4.11;

import "./Managed.sol";
import "./ChronoBankPlatformInterface.sol";
import "./ERC20Interface.sol";
import "./ExchangeInterface.sol";
import "./OwnedInterface.sol";
import "./LOCInterface.sol";
import "./ChronoMintInterface.sol";
import "./FeeInterface.sol";
import "./ChronoBankAssetProxyInterface.sol";

contract ContractsManager is Managed {

    enum ContractType {LOCManager, PendingManager, UserManager, ERC20Manager, ExchangeManager, Platform, TIME, LHAU}

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

    event Reissue(uint value, address locAddr);

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

    // this method is implemented only for test purposes
    function sendTime() returns (bool) {
        if(!timeHolder[msg.sender]) {
            timeHolder[msg.sender] = true;
            return ERC20Interface(contractByType[uint(ContractType.TIME)]).transfer(msg.sender, 1000000000);
        }
        else {
            return false;
        }
    }

    function claimContractOwnership(address _addr, ContractType _type) onlyAuthorized() returns (bool) {
        if (OwnedInterface(_addr).claimContractOwnership()) {
            contractByType[uint(_type)] = _addr;
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

    function reissueAsset(uint _id, bytes32 symbol, uint _value, address _locAddr) multisig returns (bool) {
        if(symbol != 0x0) {
            address platform = ChronoBankAssetProxyInterface(contractByType[uint(ContractType.TIME)]).chronoBankPlatform();
            if (platform != 0x0 && ChronoBankPlatformInterface(platform).isReissuable(symbol)) {
                uint issued = LOCInterface(_locAddr).getIssued();
                if(_value <= LOCInterface(_locAddr).getIssueLimit() - issued) {
                    if(ChronoBankPlatformInterface(platform).reissueAsset(symbol, _value)) {
                        address Mint = LOCInterface(_locAddr).getContractOwner();
                        Reissue(_value, _locAddr);
                        return ChronoMintInterface(Mint).call(bytes4(sha3("setLOCIssued(address,uint256)")), _locAddr, issued + _value);
                    }
                }
            }
        }
        return false;
    }

    function revokeAsset(uint _id, bytes32 symbol, uint _value, address _locAddr) multisig returns (bool) {
        if(symbol != 0x0) {
            address platform = ChronoBankAssetProxyInterface(contractByType[uint(ContractType.TIME)]).chronoBankPlatform();
            if (platform != 0x0 && ChronoBankPlatformInterface(platform).isReissuable(symbol)) {
                uint issued = LOCInterface(_locAddr).getIssued();
                if(_value <= issued) {
                    if(ChronoBankPlatformInterface(platform).revokeAsset(symbol, _value)) {
                        address Mint = LOCInterface(_locAddr).getContractOwner();
                        Reissue(_value, _locAddr);
                        return ChronoMintInterface(Mint).call(bytes4(sha3("setLOCIssued(address,uint256)")), _locAddr, issued - _value);
                    }
                }
            }
        }
        return false;
    }

 //   function sendAsset(uint _id, address _to, uint _value) onlyAuthorized() returns (bool) {
 //       if(contracts[_id] != 0x0) {
 //           address assetProxy = contracts[_id];
 //           if(ChronoBankAssetProxyInterface(contracts[_id]).smbl() == 'LHT') {
 //               uint feePercent = FeeInterface(ChronoBankAssetProxyInterface(assetProxy).getLatestVersion()).feePercent();
 //               uint amount = (_value * 10000)/(10000 + feePercent);
 //               return ERC20Interface(assetProxy).transfer(_to, amount);
 //           }
 //           return ERC20Interface(assetProxy).transfer(_to, _value);
 //       }
 //       return false;
 //   }


    function addContract(
    address _contractAddr,
    ContractType _type,
    string _description,
    bytes32 _ipfsHash,
    bytes32 _swarmHash)
    public
    onlyAuthorized()
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

    /// @dev Allows owner to remove an existing token from the registry.
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
