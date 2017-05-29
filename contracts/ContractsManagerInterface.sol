pragma solidity ^0.4.8;

contract ContractsManagerInterface {

    enum ContractType {LOCManager, PendingManager, UserManager, ERC20Manager, ExchangeManager, TrackersManager, Voting, Rewards, TIME, LH, Assets}
    function getContractAddressByType(ContractType _type) constant returns (address contractAddress);

}


