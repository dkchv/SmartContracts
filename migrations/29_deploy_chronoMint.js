var ChronoMintEmitter = artifacts.require("./ChronoMintEmitter.sol");
module.exports = function(deployer, network) {
    deployer.deploy(ChronoMintEmitter)
}
