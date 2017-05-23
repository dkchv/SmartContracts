pragma solidity ^0.4.11;

import "./Managed.sol";
import "./Exchange.sol";
import "./KrakenPriceTicker.sol";
import {ERC20ManagerInterface as ERC20Manager} from "./ERC20ManagerInterface.sol";
import {ERC20Interface as Asset} from "./ERC20Interface.sol";

contract ExchangeManager is Managed {
    address erc20Manager;
    mapping(uint => address) exchanges;
    mapping(address => uint) exchangesIds;
    mapping(address => address) owners;
    uint exchangesCount = 1;
    uint[] deletedIds;

    //Exchanges APIs for rate tracking array
    mapping(uint => string) public URLs;
    mapping(bytes32 => uint) URLids;

    uint URLsCount = 1;

    modifier onlyExchangeOwner(uint _id) {
        if (msg.sender == owners[exchanges[_id]]) {
            _;
        }
    }

    function init(address _erc20Manager) returns(bool) {
        erc20Manager = _erc20Manager;
        return true;
    }

    function forward(uint _id, bytes data) onlyExchangeOwner(_id) returns (bool) {
        if (!Exchange(exchanges[_id]).call(data)) {
            throw;
        }
        return true;
    }

    function addURL(string _url) returns(bool) {
        bytes32 hash = sha3(_url);
        if(URLids[hash] == 0) {
            URLs[URLsCount] = _url;
            URLids[hash] = URLsCount;
            URLsCount++;
            return true;
        }
        return false;
    }

    function getURLid(string _url) returns(uint) {
        return URLids[sha3(_url)];
    }


    function removeURL(string _url) returns(bool) {

    }

    function addExchange(address _exchange) returns(uint) {
        Exchange(_exchange).sellPrice;
        Exchange(_exchange).buyPrice;
        if(exchangesIds[_exchange] == 0) {
            exchanges[exchangesCount] = _exchange;
            exchangesIds[_exchange] = exchangesCount;
            return exchangesCount++;
        }
        return 0;
    }

    function editExchange(uint _id, address _exchange) onlyExchangeOwner(_id) returns(bool) {
        if(exchanges[_id] > 0) {
            delete exchangesIds[exchanges[_id]];
            exchanges[_id] = _exchange;
            exchangesIds[_exchange] = _id;
            return true;
        }
        return false;
    }

    function removeExchange(uint _id) onlyExchangeOwner(_id) returns(bool) {
        return false;
    }

    function createExchange(string _symbol) returns(uint) {
        address tokenAddr = ERC20Manager(erc20Manager).getTokenAddressBySymbol(_symbol);
        if(tokenAddr != 0x0) {
            address exchangeAddr = new Exchange();
            address tickerAddr = new KrakenPriceTicker();
            Exchange(exchangeAddr).init(Asset(tokenAddr),0x0,tickerAddr,10);
            exchanges[exchangesCount] = exchangeAddr;
            exchangesIds[exchangeAddr] = exchangesCount;
            owners[exchangeAddr] = msg.sender;
            return exchangesCount++;
        }
    }
}
