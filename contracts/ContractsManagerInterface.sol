pragma solidity ^0.4.8;

contract ContractsManagerInterface {

    enum ContractType {LOCManager, PendingManager, UserManager, ERC20Manager, ExchangeManager, TrackersManager, Voting, Rewards, TIME, LH, Assets}
    address[] public contractAddresses;

}


