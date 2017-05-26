var AssetsManager = artifacts.require("./AssetsManager.sol");
module.exports = function(deployer, network) {
    deployer.deploy(AssetsManager)
}
