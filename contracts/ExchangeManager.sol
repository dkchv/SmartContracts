pragma solidity ^0.4.11;

import "./Managed.sol";
import "./Exchange.sol";
import "./KrakenPriceTicker.sol";
import "./ContractsManager.sol";
//import "./StrToBytes32Array.sol";
import {ERC20Interface as Asset} from "./ERC20Interface.sol";

contract ExchangeManager is Managed {
    address contractsManager;
    mapping(uint => address) exchanges;
    mapping(address => uint) exchangesIds;
    uint exchangesCount = 1;
    uint[] deletedIds;

    //Exchanges APIs for rate tracking array
    mapping(uint => bytes32[]) public URLs;
    mapping(bytes32 => uint) URLids;
    uint URLCount = 1;

    modifier onlyExchangeOwner(uint _id) {
        if (msg.sender == Exchange(exchanges[_id]).contractOwner()) {
            _;
        }
    }

    function init(address _contractsManager) onlyAuthorized returns(bool) {
        contractsManager = _contractsManager;
        return true;
    }

    function addURL(string _url) returns(bool) {
        //URLs[URLCount] = StrToBytes32Array(_url);
        //URLCount++;
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

    function createExchange(uint _token, bytes32 _symbol) returns(uint) {
        if(_symbol == 0x0)
            return 0;
        address exchangeAddr = new Exchange();
        Exchange(exchangeAddr).init(Asset(ContractsManager(contractsManager).getAddress(_token)));
        exchanges[exchangesCount] = exchangeAddr;
        exchangesIds[exchangeAddr] = exchangesCount;
        return exchangesCount++;
    }
}
