pragma solidity ^0.4.11;

import "./Managed.sol";
import "./ERC20ManagerInterface.sol";
import "./ContractsManagerInterface.sol";
import "./ChronoBankAssetWithFee.sol";
import "./ChronoBankPlatformInterface.sol";
import "./ChronoBankAssetProxyInterface.sol";
import "./OwnedInterface.sol";

contract ProxyFactory {
    function createProxy() returns (address);
}

contract AssetsManager is Managed {

    address platform;
    address contractsManager;
    address proxyFactory;

    bytes32[] assetSymbols;
    mapping(address => address[]) owners;

    function init(address _platform, address _contractsManager, address _proxyFactory) returns(bool) {
        if (platform != 0x0) {
            return false;
        }
        platform = _platform;
        contractsManager = _contractsManager;
        proxyFactory = _proxyFactory;
        return true;
    }

    function claimPlatformOwnership() returns (bool) {
        if (OwnedInterface(platform).claimContractOwnership()) {
            return true;
        }
        platform = address(0);
        return false;
    }

    function addAsset(address asset) {

    }

    function createAsset(bytes32 symbol, string name, string description, uint value, uint8 decimals, bool isMint, bool withFee) returns (address) {
        string memory smbl = bytes32ToString(symbol);
        address token = ERC20ManagerInterface(contractsManager).getTokenAddressBySymbol(smbl);
        if(token == address(0)) {
            token = ProxyFactory(proxyFactory).createProxy();
            address asset;
            ChronoBankPlatformInterface(platform).issueAsset(symbol, value, name, description, decimals, isMint);
            if(withFee) {
                asset = new ChronoBankAssetWithFee();
            }
            else {
                asset = new ChronoBankAsset();
            }
            ChronoBankPlatformInterface(platform).setProxy(token, symbol);
            ChronoBankAssetProxy(token).init(platform, smbl, name);
            ChronoBankAssetProxy(token).proposeUpgrade(asset);
            ChronoBankAsset(asset).init(ChronoBankAssetProxyInterface(token));
            assetSymbols.push(symbol);
            ERC20ManagerInterface(contractsManager).addToken(token, name, smbl, '', decimals, bytes32(0), bytes32(0));
            owners[token].push(msg.sender);
            return token;
        }
        return token;
    }

    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function()
    {
        throw;
    }
}
