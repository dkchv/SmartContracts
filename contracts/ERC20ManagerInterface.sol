pragma solidity ^0.4.8;

contract ERC20ManagerInterface {

    function getTokenAddressBySymbol(string _symbol) constant returns (address tokenAddress);

}


