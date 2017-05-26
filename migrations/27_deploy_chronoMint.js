var ExchangeManager = artifacts.require("./ExchangeManager.sol");
module.exports = function(deployer, network) {
    deployer.deploy(ExchangeManager)
}
