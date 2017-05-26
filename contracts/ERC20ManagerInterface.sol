pragma solidity ^0.4.8;

contract ERC20ManagerInterface {

    function getTokenAddressBySymbol(string _symbol) constant returns (address tokenAddress);

    function addToken(
    address _token,
    string _name,
    string _symbol,
    string _url,
    uint8 _decimals,
    bytes32 _ipfsHash,
    bytes32 _swarmHash);

}


