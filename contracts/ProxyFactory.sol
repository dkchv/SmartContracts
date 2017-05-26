pragma solidity ^0.4.11;

import {ChronoBankAssetProxy as Proxy} from "./ChronoBankAssetProxy.sol";

contract ProxyFactory {

    function createProxy() returns (address) {
        address proxy = new Proxy();
        return proxy;
    }

    function()
    {
        throw;
    }
}
