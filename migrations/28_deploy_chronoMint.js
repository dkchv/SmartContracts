var ERC20Manager = artifacts.require("./ERC20Manager.sol");
module.exports = function(deployer, network) {
    deployer.deploy(ERC20Manager)
}
