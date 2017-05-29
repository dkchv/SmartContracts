pragma solidity ^0.4.11;

import "./Managed.sol";
import "./Exchange.sol";
//import "./KrakenPriceTicker.sol";
import {ERC20ManagerInterface as ERC20Manager} from "./ERC20ManagerInterface.sol";
import {ERC20Interface as Asset} from "./ERC20Interface.sol";
import {ContractsManagerInterface as ContractsManager} from "./ContractsManagerInterface.sol";

contract ExchangeManager is Managed {
    address contractsManager;
    address[] public exchanges;
    mapping(address => address) owners;

    //Exchanges APIs for rate tracking array
    //string[] public URLs;
    //mapping(bytes32 => bool) URLexsist;

    event exchangeRemoved(address user, address exchange);

    modifier onlyExchangeOwner(address _exchange) {
        if (msg.sender == owners[_exchange]) {
            _;
        }
    }

    function init(address _contractsManager) returns(bool) {
        contractsManager = _contractsManager;
        return true;
    }

    function forward(address _exchange, bytes data) onlyExchangeOwner(_exchange) returns (bool) {
        if (!Exchange(_exchange).call(data)) {
            throw;
        }
        return true;
    }

    function addExchange(address _exchange) returns(uint) {
        Exchange(_exchange).sellPrice;
        Exchange(_exchange).buyPrice;
        if(owners[_exchange] == 0x0) {
            exchanges.push(_exchange);
            owners[_exchange] = msg.sender;
            return exchanges.length;
        }
        return 0;
    }

    function editExchange(address _exchangeOld, address _exchangeNew) onlyExchangeOwner(_exchangeOld) returns(bool) {
        for (uint i = 0; i < exchanges.length; i++) {
            if (exchanges[i] == _exchangeOld) {
                exchanges[i] = _exchangeNew;
                exchanges.length -= 1;
                return true;
            }
        }
        return false;
    }

    function removeExchange(address _exchange) onlyExchangeOwner(_exchange) returns(bool) {
        for (uint i = 0; i < exchanges.length; i++) {
            if (exchanges[i] == _exchange) {
                exchanges[i] = exchanges[exchanges.length - 1];
                exchanges.length -= 1;
                break;
            }
        }
        delete owners[_exchange];
        exchangeRemoved(msg.sender, _exchange);
        return true;
    }

    function createExchange(string _symbol, bool _useTicker) returns(uint) {
        address tokenAddr = ERC20Manager(ContractsManager(contractsManager).contractAddresses(uint(ContractsManager.ContractType.ERC20Manager))).getTokenAddressBySymbol(_symbol);
        address rewards = ContractsManager(contractsManager).contractAddresses(uint(ContractsManager.ContractType.Rewards));
        if(tokenAddr != 0x0 && rewards !=  0x0) {
            address exchangeAddr = new Exchange();
            address tickerAddr;
            if(_useTicker) {
                //address tickerAddr = new KrakenPriceTicker();
            }
            Exchange(exchangeAddr).init(Asset(tokenAddr),rewards,tickerAddr,10);
            exchanges.push(exchangeAddr);
            owners[exchangeAddr] = msg.sender;
            return exchanges.length;
        }
    }
}
