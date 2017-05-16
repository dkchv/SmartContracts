var Strings = artifacts.require("./Strings.sol");
var SafeMath = artifacts.require("./SafeMath.sol");
var EternalStorage = artifacts.require("./EternalStorage.sol");
var SharedLibrary = artifacts.require("./SharedLibrary.sol");
var LOCLibrary = artifacts.require("./LOCLibrary.sol");
var LOCManager = artifacts.require("./LOCManager.sol");

module.exports = function(deployer, network) {
    deployer.deploy(Strings)
     .then(() => deployer.link(Strings, [EternalStorage]))
     .then(() => deployer.deploy(SafeMath))
     .then(() => deployer.link(SafeMath, [EternalStorage]))     
     .then(() => deployer.deploy(EternalStorage))     
     .then(() => deployer.link(EternalStorage, [LOCLibrary, SharedLibrary]))  
     .then(() => deployer.deploy(SharedLibrary))
     .then(() => deployer.deploy(LOCLibrary))    
     .then(() => deployer.link(LOCLibrary, [LOCManager]))  
     .then(() => deployer.deploy(LOCManager, EternalStorage.address))    
};