import Contest from '@digix/contest';
const contest = new Contest({ debug: true, timeout: 2000 });
var FakeCoin = artifacts.require("./FakeCoin.sol");
var FakeCoin2 = artifacts.require("./FakeCoin2.sol");
var ChronoBankPlatform = artifacts.require("./ChronoBankPlatform.sol");
var ChronoBankPlatformEmitter = artifacts.require("./ChronoBankPlatformEmitter.sol");
var EventsHistory = artifacts.require("./EventsHistory.sol");
var ChronoBankAssetProxy = artifacts.require("./ChronoBankAssetProxy.sol");
var ChronoBankAssetWithFeeProxy = artifacts.require("./ChronoBankAssetWithFeeProxy.sol");
var ChronoBankAsset = artifacts.require("./ChronoBankAsset.sol");
var ChronoBankAssetWithFee = artifacts.require("./ChronoBankAssetWithFee.sol");
var Exchange = artifacts.require("./Exchange.sol");
var Rewards = artifacts.require("./Rewards.sol");
var ChronoMint = artifacts.require("./ChronoMint.sol");
var ContractsManager = artifacts.require("./ContractsManager.sol");
var UserManager = artifacts.require("./UserManager.sol");
var UserStorage = artifacts.require("./UserStorage.sol");
var Shareable = artifacts.require("./PendingManager.sol");
var LOC = artifacts.require("./LOC.sol");
var TimeHolder = artifacts.require("./TimeHolder.sol");
var RateTracker = artifacts.require("./KrakenPriceTicker.sol");
var Reverter = require('./helpers/reverter');
var bytes32 = require('./helpers/bytes32');
var bytes32fromBase58 = require('./helpers/bytes32fromBase58');
var Require = require("truffle-require");
var Config = require("truffle-config");

contract('ChronoMint', function(accounts) {
  var owner = accounts[0];
  var owner1 = accounts[1];
  var owner2 = accounts[2];
  var owner3 = accounts[3];
  var owner4 = accounts[4];
  var owner5 = accounts[5];
  var nonOwner = accounts[6];
  var locController1 = accounts[7];
  var locController2 = accounts[7];
  var conf_sign;
  var conf_sign2;
  var coin;
  var coin2;
  var chronoMint;
  var chronoBankPlatform;
  var chronoBankPlatformEmitter;
  var contractsManager;
  var eventsHistory;
  var shareable;
  var platform;
  var timeContract;
  var lhContract;
  var timeProxyContract;
  var lhProxyContract;
  var exchange;
  var rewards;
  var userManager;
  var userStorage;
  var timeHolder;
  var rateTracker;
  var loc_contracts = [];
  var labor_hour_token_contracts = [];
  var Status = {maintenance:0,active:1, suspended:2, bankrupt:3};
  var unix = Math.round(+new Date()/1000);

  const SYMBOL = 'TIME';
  const SYMBOL2 = 'LHT';
  const NAME = 'Time Token';
  const DESCRIPTION = 'ChronoBank Time Shares';
  const NAME2 = 'Labour-hour Token';
  const DESCRIPTION2 = 'ChronoBank Lht Assets';
  const BASE_UNIT = 2;
  const IS_REISSUABLE = true;
  const IS_NOT_REISSUABLE = false;
  const BALANCE_ETH = 1000;
  const fakeArgs = [0,0,0,0,0,0,0,0];

  before('setup', function(done) {
    FakeCoin.deployed().then(function(instance) {
      coin = instance;
      return FakeCoin2.deployed()
    }).then(function(instance) {
      coin2 = instance;
      return UserStorage.deployed()
    }).then(function (instance) {
      return instance.addOwner(UserManager.address)
    }).then(function () {
      return ChronoMint.deployed()
    }).then(function (instance) {
      return instance.init(UserStorage.address, Shareable.address, ContractsManager.address)
    }).then(function () {
      return ContractsManager.deployed()
    }).then(function (instance) {
      return instance.init(UserStorage.address, Shareable.address)
    }).then(function () {
      return Shareable.deployed()
    }).then(function (instance) {
      return instance.init(UserStorage.address)
    }).then(function () {
      return UserManager.deployed()
    }).then(function (instance) {
      return instance.init(UserStorage.address, Shareable.address)
    }).then(function () {
      return RateTracker.deployed()
    }).then(function (instance) {
      rateTracker = instance
      var events = rateTracker.newOraclizeQuery({fromBlock: "latest"});
      events.watch(function(error, result) {
      // This will catch all Transfer events, regardless of how they originated.
        if (error == null) {
          console.log(result.args);
        }
      })
    }).then(function () {
      return web3.eth.sendTransaction({to: rateTracker.address, value: web3.toWei(1, "ether"), from: accounts[0]});
    }).then(function () {
      return rateTracker.update()
    }).then(function () {
      return ChronoBankPlatform.deployed()
    }).then(function (instance) {
      platform = instance;
      return ChronoBankAsset.deployed()
    }).then(function (instance) {
      timeContract = instance;
      return ChronoBankAssetWithFee.deployed()
    }).then(function (instance) {
      lhContract = instance;
      return ChronoBankAssetProxy.deployed()
    }).then(function (instance) {
      timeProxyContract = instance;
      return ChronoBankAssetWithFeeProxy.deployed()
    }).then(function(instance) {
      lhProxyContract = instance;
      return ChronoBankPlatform.deployed()
    }).then(function (instance) {
      chronoBankPlatform = instance;
      return ChronoMint.deployed()
    }).then(function (instance) {
      chronoMint = instance;
      return Shareable.deployed()
    }).then(function (instance) {
      shareable = instance;
      return ContractsManager.deployed()
    }).then(function (instance) {
      contractsManager = instance;
      return UserManager.deployed()
    }).then(function (instance) {
      userManager = instance;
      return UserStorage.deployed()
    }).then(function (instance) {
      userStorage = instance;
      return ChronoBankPlatformEmitter.deployed()
    }).then(function (instance) {
      chronoBankPlatformEmitter = instance;
      return EventsHistory.deployed()
    }).then(function (instance) {
      eventsHistory = instance;
      return chronoBankPlatform.setupEventsHistory(EventsHistory.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoBankPlatformEmitter.contract.emitTransfer.getData.apply(this, fakeArgs).slice(0, 10), ChronoBankPlatformEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoBankPlatformEmitter.contract.emitIssue.getData.apply(this, fakeArgs).slice(0, 10), ChronoBankPlatformEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoBankPlatformEmitter.contract.emitRevoke.getData.apply(this, fakeArgs).slice(0, 10), ChronoBankPlatformEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoBankPlatformEmitter.contract.emitOwnershipChange.getData.apply(this, fakeArgs).slice(0, 10), ChronoBankPlatformEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoBankPlatformEmitter.contract.emitApprove.getData.apply(this, fakeArgs).slice(0, 10), ChronoBankPlatformEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoBankPlatformEmitter.contract.emitRecovery.getData.apply(this, fakeArgs).slice(0, 10), ChronoBankPlatformEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoBankPlatformEmitter.contract.emitError.getData.apply(this, fakeArgs).slice(0, 10), ChronoBankPlatformEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addVersion(chronoBankPlatform.address, "Origin", "Initial version.");
    }).then(function () {
      return chronoBankPlatform.issueAsset(SYMBOL, 200000000000, NAME, DESCRIPTION, BASE_UNIT, IS_NOT_REISSUABLE, {
        from: accounts[0],
        gas: 3000000
      })
    }).then(function (r) {
      return chronoBankPlatform.setProxy(ChronoBankAssetProxy.address, SYMBOL, {from: accounts[0]})
    }).then(function (r) {
      return ChronoBankAssetProxy.deployed()
    }).then(function (instance) {
      return instance.init(ChronoBankPlatform.address, SYMBOL, NAME, {from: accounts[0]})
    }).then(function (r) {
      return ChronoBankAssetProxy.deployed()
    }).then(function (instance) {
      return instance.proposeUpgrade(ChronoBankAsset.address, {from: accounts[0]})
    }).then(function (r) {
      return ChronoBankAsset.deployed()
    }).then(function (instance) {
      return instance.init(ChronoBankAssetProxy.address, {from: accounts[0]})
    }).then(function (r) {
      return ChronoBankAssetProxy.deployed()
    }).then(function (instance) {
      return instance.transfer(ContractsManager.address, 200000000000, {from: accounts[0]})
    }).then(function (r) {
      return chronoBankPlatform.changeOwnership(SYMBOL, contractsManager.address, {from: accounts[0]})
    }).then(function (r) {
      return chronoBankPlatform.issueAsset(SYMBOL2, 0, NAME2, DESCRIPTION2, BASE_UNIT, IS_REISSUABLE, {
        from: accounts[0],
        gas: 3000000
      })
    }).then(function () {
      return chronoBankPlatform.setProxy(ChronoBankAssetWithFeeProxy.address, SYMBOL2, {from: accounts[0]})
    }).then(function () {
      return ChronoBankAssetWithFeeProxy.deployed()
    }).then(function (instance) {
      return instance.init(ChronoBankPlatform.address, SYMBOL2, NAME2, {from: accounts[0]})
    }).then(function () {
      return ChronoBankAssetWithFeeProxy.deployed()
    }).then(function (instance) {
      return instance.proposeUpgrade(ChronoBankAssetWithFee.address, {from: accounts[0]})
    }).then(function () {
      return ChronoBankAssetWithFee.deployed()
    }).then(function (instance) {
      return instance.init(ChronoBankAssetWithFeeProxy.address, {from: accounts[0]})
    }).then(function (instance) {
      return ChronoBankAssetWithFee.deployed()
    }).then(function (instance) {
      return instance.setupFee(Rewards.address, 100, {from: accounts[0]})
    }).then(function () {
      return ChronoBankPlatform.deployed()
    }).then(function (instance) {
      return instance.changeOwnership(SYMBOL2, ContractsManager.address, {from: accounts[0]})
    }).then(function () {
      return Rewards.deployed()
    }).then(function (instance) {
      rewards = instance;
      return rewards.init(TimeHolder.address, 0)
    }).then(function (instance) {
      return rewards.addAsset(ChronoBankAssetWithFeeProxy.address)
    }).then(function () {
      return Exchange.deployed()
    }).then(function (instance) {
      exchange = instance;
      return exchange.init(ChronoBankAssetWithFeeProxy.address)
    }).then(function () {
      return exchange.changeContractOwnership(contractsManager.address, {from: accounts[0]})
    }).then(function () {
      return contractsManager.claimContractOwnership(exchange.address, false, {from: accounts[0]})
    }).then(function () {
      return rewards.changeContractOwnership(contractsManager.address, {from: accounts[0]})
    }).then(function () {
      return contractsManager.claimContractOwnership(rewards.address, false, {from: accounts[0]})
    }).then(function () {
      return TimeHolder.deployed()
    }).then(function (instance) {
      timeHolder = instance;
      return instance.init(UserStorage.address, ChronoBankAssetProxy.address)
    }).then(function () {
      return timeHolder.addListener(rewards.address)
    }).then(function() {
      return contractsManager.setAddress(ChronoBankAssetProxy.address, {from: accounts[0]})
    }).then(function () {
      return contractsManager.setAddress(ChronoBankAssetWithFeeProxy.address, {from: accounts[0]})
    }).then(function(instance) {
      web3.eth.sendTransaction({to: Exchange.address, value: BALANCE_ETH, from: accounts[0]});
      done();
    }).catch(function (e) { console.log(e); });
    //reverter.snapshot(done);
  });

  context("with one CBE key", function(){

    it("Platform has correct TIME proxy address.", function() {
      return platform.proxies.call(SYMBOL).then(function(r) {
        assert.equal(r,timeProxyContract.address);
      });
    });

    it("Platform has correct LHT proxy address.", function() {
      return platform.proxies.call(SYMBOL2).then(function(r) {
        assert.equal(r,lhProxyContract.address);
      });
    });


    it("TIME contract has correct TIME proxy address.", function() {
      return timeContract.proxy.call().then(function(r) {
        assert.equal(r,timeProxyContract.address);
      });
    });

    it("LHT contract has correct LHT proxy address.", function() {
      return lhContract.proxy.call().then(function(r) {
        assert.equal(r,lhProxyContract.address);
      });
    });

    it("TIME proxy has right version", function() {
      return timeProxyContract.getLatestVersion.call().then(function(r) {
        assert.equal(r,timeContract.address);
      });
    });

    it("LHT proxy has right version", function() {
      return lhProxyContract.getLatestVersion.call().then(function(r) {
        assert.equal(r,lhContract.address);
      });
    });

    it("can show all Asset contracts", function() {
      return contractsManager.getContracts.call().then(function(r) {
        assert.equal(r.length,2);
      });
    });

    it("can show all Service contracts", function() {
      return contractsManager.getOtherContracts.call().then(function(r) {
        assert.equal(r.length,2);
      });
    });

    it("shows owner as a CBE key.", function() {
      return chronoMint.isAuthorized.call(owner).then(function(r) {
        assert.isOk(r);
      });
    });

    it("doesn't show owner1 as a CBE key.", function() {
      return chronoMint.isAuthorized.call(owner1).then(function(r) {
        assert.isNotOk(r);
      });
    });

    it("can provide TimeProxyContract address.", function() {
      return contractsManager.getAddress.call(1).then(function(r) {
        assert.equal(r,timeProxyContract.address);
      });
    });

    it("can provide LHProxyContract address.", function() {
      return contractsManager.getAddress.call(2).then(function(r) {
        assert.equal(r,lhProxyContract.address);
      });
    });

    it("can provide ExchangeContract address.", function() {
      return contractsManager.getOtherAddress.call(1).then(function(r) {
        assert.equal(r,exchange.address);
      });
    });

    it("can provide RewardsContract address.", function() {
      return contractsManager.getOtherAddress.call(2).then(function(r) {
        assert.equal(r,rewards.address);
      });
    });

    it("allows a CBE key to set the contract address", function() {
      return contractsManager.setAddress(coin.address).then(function(r) {
        return contractsManager.getAddress.call(3).then(function(r){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.equal(r, coin.address);
            assert.equal(r2,3);
          });
        });
      });
    });

    it("allows a CBE key to set the contract address", function() {
      return contractsManager.setAddress(coin2.address).then(function(r) {
        return contractsManager.getAddress.call(4).then(function(r){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.equal(r, coin2.address);
            assert.equal(r2,4);
          });
        });
      });
    });

    it("allows a CBE key to remove the contract address", function() {
      return contractsManager.removeAddress(coin.address).then(function(r) {
        return contractsManager.getAddress.call(3).then(function(r){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.notEqual(r, coin.address);
            assert.equal(r2,3);
          });
        });
      });
    });

    it("allows a CBE key to set the contract address", function() {
      return contractsManager.setAddress(coin.address).then(function(r) {
        return contractsManager.getAddress.call(4).then(function(r){
	 return contractsManager.getAddress.call(3).then(function(r3){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.equal(r, coin2.address);
	    assert.equal(r3, coin.address);
            assert.equal(r2,4);
          });
        });
      });
     });
    });

    it("allows a CBE key to remove the contract address", function() {
      return contractsManager.removeAddress(coin2.address).then(function(r) {
        return contractsManager.getAddress.call(4).then(function(r){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.notEqual(r, coin2.address);
            assert.equal(r2,3);
          });
        });
      });
    });

    it("allows a CBE key to change the contract address", function() {
      return contractsManager.changeAddress(coin2.address, coin.address).then(function(r) {
        return contractsManager.getAddress.call(3).then(function(r){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.equal(r, coin.address);
            assert.equal(r2,3);
          });
        });
      });
    });

    it("pending operation counter should be 0", function() {
      return shareable.pendingsCount.call({from: owner}).then(function(r) {
        assert.equal(r, 0);
      });
    });

    it("dont't allow a non CBE key to set the contract address", function() {
      return contractsManager.setAddress(coin.address, {from: nonOwner}).then(function(r) {
        return contractsManager.getAddress.call(4).then(function(){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.notEqual(r, coin.address);
            assert.notEqual(r2,4);
          });
        });
      });
    });

    it("allows a CBE key to remove the contract address", function() {
      return contractsManager.removeAddress(coin.address).then(function(r) {
        return contractsManager.getAddress.call(3).then(function(r){
          return contractsManager.getContractsCounter.call().then(function(r2) {
            assert.notEqual(r, coin.address);
            assert.equal(r2,2);
          });
        });
      });
    });

    it("pending operation counter should be 0", function() {
      return shareable.pendingsCount.call({from: owner}).then(function(r) {
        assert.equal(r, 0);
      });
    });

    it("allows a CBE to propose an LOC.", function() {
      return chronoMint.proposeLOC(
        bytes32("Bob's Hard Workers"),
        bytes32("www.ru"),
        1000,
        bytes32fromBase58("QmTeW79w7QQ6Npa3b1d5tANreCDxF2iDaAPsDvW6KtLmfB"),
        unix
      ).then(function(r){
        loc_contracts[0] = LOC.at(r.logs[0].args._LOC);
        return loc_contracts[0].status.call().then(function(r){
          assert.equal(r, Status.maintenance);
        });
      });
    });

    it("Proposed LOC should increment LOCs counter", function() {
      return chronoMint.getLOCCount.call().then(function(r){
        assert.equal(r, 1);
      });
    });

    it("allows CBE member to remove LOC", function() {
      return chronoMint.removeLOC(loc_contracts[0].address,{
        from: accounts[0],
        gas: 3000000
      }).then(function() {
        return chronoMint.getLOCCount.call().then(function(r){
          return chronoMint.deletedIdsLength.call().then(function(r2){
            assert.equal(r, 0);
            assert.equal(r2, 0);
          });
        });
      });
    });

    it("Removed LOC should decrement LOCs counter", function() {
      return chronoMint.getLOCCount.call().then(function(r){
        return chronoMint.deletedIdsLength.call().then(function(r2){
          assert.equal(r, 0);
          assert.equal(r2, 0);
        });
      });
    });

    it("allow CBE member to set his IPFS orbit-db hash", function() {
      return userManager.setMemberHash(
        owner,
        bytes32fromBase58('QmTeW79w7QQ6Npa3b1d5tANreCDxF2iDaAPsDvW6KtLmfB')
      ).then(function(){
        return userManager.getMemberHash.call(owner).then(function(r){
          assert.equal(r, bytes32fromBase58('QmTeW79w7QQ6Npa3b1d5tANreCDxF2iDaAPsDvW6KtLmfB'));
        });
      });
    });

    it("pending operation counter should be 0", function() {
      return shareable.pendingsCount.call({from: owner}).then(function(r) {
        assert.equal(r, 0);
      });
    });

    it("allows one CBE key to add another CBE key.", function() {
      return userManager.addCBE(owner1,0x0).then(function() {
        return userManager.isAuthorized.call(owner1).then(function(r){
          assert.isOk(r);
        });
      });
    });

    it("should allow setRequired signatures 2.", function() {
      return userManager.setRequired(2).then(function() {
        return userManager.required.call({from: owner}).then(function(r) {
          assert.equal(r, 2);
        });
      });
    });

  });

  context("with two CBE keys", function(){

    it("shows owner as a CBE key.", function() {
      return chronoMint.isAuthorized.call(owner).then(function(r) {
        assert.isOk(r);
      });
    });

    it("shows owner1 as a CBE key.", function() {
      return chronoMint.isAuthorized.call(owner1).then(function(r) {
        assert.isOk(r);
      });
    });

    it("doesn't show owner2 as a CBE key.", function() {
      return chronoMint.isAuthorized.call(owner2).then(function(r) {
        assert.isNotOk(r);
      });
    });

    it("pending operation counter should be 0", function() {
      return shareable.pendingsCount.call({from: owner}).then(function(r) {
        assert.equal(r, 0);
      });
    });

    it("allows to propose pending operation", function() {
      return userManager.addCBE(owner2, 0x0, {from:owner}).then(function(r) {
        conf_sign = r.logs[0].args.hash;
        shareable.pendingsCount.call({from: owner}).then(function(r) {
          assert.equal(r,1);
        });
      });
    });

    it("allows to revoke last confirmation and remove pending operation", function() {
      return shareable.revoke(conf_sign, {from:owner}).then(function() {
        shareable.pendingsCount.call({from: owner}).then(function(r) {
          assert.equal(r,0);
        });
      });
    });

    it("allows one CBE key to add another CBE key", function() {
      return userManager.addCBE(owner2, 0x0, {from:owner}).then(function(r) {
        return shareable.confirm(r.logs[0].args.hash, {from:owner1}).then(function() {
          return chronoMint.isAuthorized.call(owner2).then(function(r){
            assert.isOk(r);
          });
        });
      });
    });

    it("pending operation counter should be 0", function() {
      return shareable.pendingsCount.call({from: owner}).then(function(r) {
        assert.equal(r, 0);
      });
    });

    it("should allow setRequired signatures 3.", function() {
      return userManager.setRequired(3).then(function(r) {
        return shareable.confirm(r.logs[0].args.hash,{from:owner1}).then(function() {
          return userManager.required.call({from: owner}).then(function(r) {
            assert.equal(r, 3);
          });
        });
      });
    });

  });

  context("with three CBE keys", function(){

    it("allows 2 votes for the new key to grant authorization.", function() {
      return userManager.addCBE(owner3, 0x0, {from: owner2}).then(function(r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign,{from:owner}).then(function() {
          return shareable.confirm(conf_sign,{from:owner1}).then(function() {
            return chronoMint.isAuthorized.call(owner3).then(function(r){
              assert.isOk(r);
            });
          });
        });
      });
    });

    it("pending operation counter should be 0", function() {
      return shareable.pendingsCount.call({from: owner}).then(function(r) {
        assert.equal(r, 0);
      });
    });

    it("should allow set required signers to be 4", function() {
      return userManager.setRequired(4).then(function(r) {
        return shareable.confirm(r.logs[0].args.hash,{from:owner1}).then(function() {
          return shareable.confirm(r.logs[0].args.hash,{from:owner2}).then(function() {
            return userManager.required.call({from: owner}).then(function(r) {
              assert.equal(r, 4);
            });
          });
        });
      });
    });

  });

  context("with four CBE keys", function(){

    it("allows 3 votes for the new key to grant authorization.", function() {
      return userManager.addCBE(owner4, 0x0, {from: owner3}).then(function(r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign,{from:owner}).then(function() {
          return shareable.confirm(conf_sign,{from:owner1}).then(function() {
            return shareable.confirm(conf_sign,{from:owner2}).then(function() {
              //  return shareable.confirm(conf_sign,{from:owner3}).then(function() {
              return chronoMint.isAuthorized.call(owner3).then(function(r){
                assert.isOk(r);
              });
              //    });
            });
          });
        });
      });
    });

    it("pending operation counter should be 0", function() {
      return shareable.pendingsCount.call({from: owner}).then(function(r) {
        assert.equal(r, 0);
      });
    });

    it("should allow set required signers to be 5", function() {
      return userManager.setRequired(5).then(function(r) {
        return shareable.confirm(r.logs[0].args.hash,{from:owner1}).then(function() {
          return shareable.confirm(r.logs[0].args.hash,{from:owner2}).then(function() {
            return shareable.confirm(r.logs[0].args.hash,{from:owner3}).then(function() {
              return userManager.required.call({from: owner}).then(function(r2) {
                assert.equal(r2, 5);
              });
            });
          });
        });
      });
    });

  });

  context("with five CBE keys", function() {
    it("collects 4 vote to addCBE and granting auth.", function () {
      return userManager.addCBE(owner5, 0x0, {from: owner4}).then(function (r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign, {from: owner}).then(function () {
          return shareable.confirm(conf_sign, {from: owner1}).then(function () {
            return shareable.confirm(conf_sign, {from: owner2}).then(function () {
              return shareable.confirm(conf_sign, {from: owner3}).then(function () {
                return chronoMint.isAuthorized.call(owner5).then(function (r) {
                  assert.isOk(r);
                });
              });
            });
          });
        });
      });
    });

    it("can show all members", function () {
      return userStorage.getCBEMembers.call().then(function (r) {
        assert.equal(r[0][0], owner);
        assert.equal(r[0][1], owner1);
        assert.equal(r[0][2], owner2);
      });
    });

    it("required signers should be 6", function () {
      return userManager.setRequired(6).then(function (r) {
        return shareable.confirm(r.logs[0].args.hash, {from: owner1}).then(function () {
          return shareable.confirm(r.logs[0].args.hash, {from: owner2}).then(function () {
            return shareable.confirm(r.logs[0].args.hash, {from: owner3}).then(function () {
              return shareable.confirm(r.logs[0].args.hash, {from: owner4}).then(function () {
                return userManager.required.call({from: owner}).then(function (r) {
                  assert.equal(r, 6);
                });
              });
            });
          });
        });
      });
    });


    it("pending operation counter should be 0", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 0);
      });
    });

    it("collects 1 call and 1 vote for setAddress as 2 votes for a new address", function () {
      return contractsManager.setAddress(coin.address).then(function (r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign, {from: owner1}).then(function () {
          return contractsManager.getAddress.call(3).then(function (r) {
            assert.notEqual(r, coin.address);
          });
        });
      });
    });

    it("pending operation counter should be 1", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 1);
      });
    });

    it("confirmation yet needed should be 4", function () {
      return shareable.pendingYetNeeded.call(conf_sign).then(function (r) {
        assert.equal(r, 4);
      });
    });

    it("check owner hasConfirmed new addrees", function () {
      return shareable.hasConfirmed.call(conf_sign, owner).then(function (r) {
        assert.isOk(r);
      });
    });

    it("revoke owner1 and check not hasConfirmed new addrees", function () {
      return shareable.revoke(conf_sign, {from: owner}).then(function () {
        return shareable.hasConfirmed.call(conf_sign, owner).then(function (r) {
          assert.isNotOk(r);
        });
      });
    });

    it("check confirmation yet needed should be 5", function () {
      return shareable.pendingYetNeeded.call(conf_sign).then(function (r) {
        assert.equal(r, 5);
      });
    });

    it("allows owner and 5 more votes to set new address.", function () {
      return shareable.confirm(conf_sign, {from: owner}).then(function () {
        return shareable.confirm(conf_sign, {from: owner2}).then(function () {
          return shareable.confirm(conf_sign, {from: owner3}).then(function () {
            return shareable.confirm(conf_sign, {from: owner4}).then(function () {
              return shareable.confirm(conf_sign, {from: owner5}).then(function () {
                return contractsManager.getAddress.call(3).then(function (r) {
                  assert.equal(r, coin.address);
                });
              });
            });
          });
        });
      });
    });

    it("pending operation counter should be 0", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 0);
      });
    });

    it("allows a CBE to propose an LOC.", function () {
      return chronoMint.proposeLOC(
        bytes32("Bob's Hard Workers"),
        bytes32("www.ru"),
        1000000,
        bytes32fromBase58("QmTeW79w7QQ6Npa3b1d5tANreCDxF2iDaAPsDvW6KtLmfB"),
        unix
      ).then(function (r) {
        loc_contracts[0] = LOC.at(r.logs[0].args._LOC);
        return loc_contracts[0].status.call().then(function (r) {
          assert.equal(r, Status.maintenance);
        });
      });
    });

    it("Proposed LOC should increment LOCs counter", function () {
      return chronoMint.getLOCCount.call().then(function (r) {
        assert.equal(r, 1);
      });
    });

    it("ChronoMint should be able to return LOCs array with proposed LOC address", function () {
      return chronoMint.getLOCs.call().then(function (r) {
        assert.equal(r[1], loc_contracts[0].address);
      });
    });


    it("allows 5 CBE members to activate an LOC.", function () {
      return chronoMint.setLOCStatus(loc_contracts[0].address, Status.active, {from: owner}).then(function (r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign, {from: owner1}).then(function (r) {
          return shareable.confirm(conf_sign, {from: owner2}).then(function (r) {
            return shareable.confirm(conf_sign, {from: owner3}).then(function (r) {
              return shareable.confirm(conf_sign, {from: owner4}).then(function (r) {
                return shareable.confirm(conf_sign, {from: owner5}).then(function (r) {
                  return loc_contracts[0].status.call().then(function (r) {
                    assert.equal(r, Status.active);
                  });
                });
              });
            });
          });
        });
      });
    });

    it("pending operation counter should be 0", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 0);
      });
    });

    it("collects call to setValue and first vote for a new value ", function () {
      return chronoMint.setLOCString(loc_contracts[0].address, 12, bytes32(22)).then(function (r) {
        conf_sign = r.logs[0].args.hash;
        return loc_contracts[0].getString.call(12).then(function (r) {
          assert.notEqual(r, bytes32(22));
          return shareable.confirm(conf_sign, {from: owner1}).then(function () {
            return loc_contracts[0].getString.call(12).then(function (r) {
              assert.notEqual(r, bytes32(22));
            });
          });
        });
      });
    });

    it("check confirmation yet needed should be 4", function () {
      return shareable.pendingYetNeeded.call(conf_sign).then(function (r) {
        assert.equal(r, 4);
      });
    });

    it("should increment pending operation counter ", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 1);
      });
    });

    it("allows a CBE to propose revocation of an authorized key.", function () {
      return userManager.revokeCBE(owner5, {from: owner}).then(function (r) {
        conf_sign2 = r.logs[0].args.hash;
        return userManager.isAuthorized.call(owner5).then(function (r) {
          assert.isOk(r);
        });
      });
    });

    it("check confirmation yet needed should be 5", function () {
      return shareable.pendingYetNeeded.call(conf_sign2).then(function (r) {
        assert.equal(r, 5);
      });
    });

    it("should increment pending operation counter ", function () {
      return shareable.pendingsCount.call().then(function (r) {
        assert.equal(r, 2);
      });
    });

    it("allows 4 more votes to set new value.", function () {
      return shareable.confirm(conf_sign, {from: owner2}).then(function () {
        return shareable.confirm(conf_sign, {from: owner3}).then(function () {
          return shareable.confirm(conf_sign, {from: owner4}).then(function () {
            return shareable.confirm(conf_sign, {from: owner5}).then(function () {
              return loc_contracts[0].getString.call(12).then(function (r) {
                assert.equal(r, bytes32(22));
              });
            });
          });
        });
      });
    });

    it("doesn't allow non CBE to change settings for the contract.", function () {
      return loc_contracts[0].setString(3, 2000).then(function () {
        return loc_contracts[0].getString.call(3).then(function (r) {
          assert.equal(r, bytes32(1000000));
        });
      });
    });

    it("allows CBE controller to change the name of the LOC", function () {
      return chronoMint.setLOCString(loc_contracts[0].address, 0, bytes32("David's Hard Workers")).then(function (r) {
        const conf_sign3 = r.logs[0].args.hash;
        return shareable.confirm(conf_sign3, {from: owner1}).then(function (r) {
          return shareable.confirm(conf_sign3, {from: owner2}).then(function (r) {
            return shareable.confirm(conf_sign3, {from: owner3}).then(function (r) {
              return shareable.confirm(conf_sign3, {from: owner4}).then(function (r) {
                return shareable.confirm(conf_sign3, {from: owner5}).then(function (r) {

                  return loc_contracts[0].getName.call().then(function (r) {
                    assert.equal(r, bytes32("David's Hard Workers"));
                  });
                });
              });
            });
          });
        });
      });
    });

    it("should decrement pending operation counter ", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 1);
      });
    });

    it("allows 5 CBE member vote for the revocation to revoke authorization.", function () {
      return shareable.confirm(conf_sign2, {from: owner1}).then(function () {
        return shareable.confirm(conf_sign2, {from: owner2}).then(function () {
          return shareable.confirm(conf_sign2, {from: owner3}).then(function () {
            return shareable.confirm(conf_sign2, {from: owner4}).then(function () {
              return shareable.confirm(conf_sign2, {from: owner5}).then(function () {
                return chronoMint.isAuthorized.call(owner5).then(function (r) {
                  assert.isNotOk(r);
                });
              });
            });
          });
        });
      });
    });

    it("required signers should be 5", function () {
      return userManager.required.call({from: owner}).then(function (r) {
        assert.equal(r, 5);
      });
    });

    it("should decrement pending operation counter ", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 0);
      });
    });

    it("can provide TimeProxyContract address.", function () {
      return contractsManager.getAddress.call(1).then(function (r) {
        assert.equal(r, timeProxyContract.address);
      });
    });

    it("should show 200 TIME balance", function () {
      return contractsManager.getBalance.call(1).then(function (r) {
        assert.equal(r, 200000000000);
      });
    });

    it("should not be abble to reIssue 5000 more TIME", function () {
      return contractsManager.reissueAsset.call(1, 'TIME', 5000, 0x10, {from: accounts[0]}).then((r) => {
        assert.isNotOk(r);
      })
        ;
    });

    it("should show 200 TIME balance", function () {
      return contractsManager.getBalance.call(1).then(function (r) {
        assert.equal(r, 200000000000);
      });
    });

    it("ChronoMint should be able to send 100 TIME to owner", function () {
      return contractsManager.sendAsset.call(1, owner, 100).then(function (r) {
        return contractsManager.sendAsset(1, owner, 100, {
          from: accounts[0],
          gas: 3000000
        }).then(function () {
          assert.isOk(r);
        });
      });
    });

    it("check Owner has 100 TIME", function () {
      return timeProxyContract.balanceOf.call(owner).then(function (r) {
        assert.equal(r, 100);
      });
    });

    it("ChronoMint should be able to send 1000 TIME to msg.sender", function () {
      return contractsManager.sendTime({from: owner2, gas: 3000000}).then(function () {
        return timeProxyContract.balanceOf.call(owner2).then(function (r) {
          assert.equal(r, 1000000000);
        });
      });
    });

    it("ChronoMint shouldn't be able to send 1000 TIME to msg.sender twice", function () {
      return contractsManager.sendTime({from: owner2, gas: 3000000}).then(function () {
        return timeProxyContract.balanceOf.call(owner2).then(function (r) {
          assert.equal(r, 1000000000);
        });
      });
    });

    it("ChronoMint should be able to send 100 TIME to owner1", function () {
      return contractsManager.sendAsset.call(1, owner1, 100).then(function (r) {
        return contractsManager.sendAsset(1, owner1, 100, {
          from: accounts[0],
          gas: 3000000
        }).then(function () {
          assert.isOk(r);
        });
      });
    });

    it("check Owner1 has 100 TIME", function () {
      return timeProxyContract.balanceOf.call(owner1).then(function (r) {
        assert.equal(r, 100);
      });
    });

    it("can provide account balances for Y account started from X", function () {
      return contractsManager.getAssetBalances.call(1, 1, 2).then(function (r) {
        assert.equal(r[0].length, 2);
      });
    });

    it("owner should be able to approve 50 TIME to Reward", function () {
      return timeProxyContract.approve.call(rewards.address, 50, {from: accounts[0]}).then((r) => {
        return timeProxyContract.approve(rewards.address, 50, {from: accounts[0]}).then(() => {
          assert.isOk(r);
        })
          ;
      })
        ;
    });

    it("can provide LHProxyContract address.", function () {
      return contractsManager.getAddress.call(2).then(function (r) {
        assert.equal(r, lhProxyContract.address);
      });
    });

    it("should show 0 LHT balance", function () {
      return contractsManager.getBalance.call(2).then(function (r) {
        assert.equal(r, 0);
      });
    });

    it("should show LOC issue limit", function () {
      return loc_contracts[0].getIssueLimit.call().then(function (r) {
        assert.equal(r, 1000000);
      });
    });

    it("should show LOC owner is ChronoMint", function () {
      return loc_contracts[0].getContractOwner.call().then(function (r) {
        assert.equal(r, chronoMint.address);
      });
    });

    it("shouldn't be abble to Issue 1100000 LHT for LOC according to issueLimit", function () {
      return contractsManager.reissueAsset(2, 'LHT', 1100000, loc_contracts[0].address, {
        from: owner,
        gas: 3000000
      }).then((r) => {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign, {from: owner4}).then(function () {
          return shareable.confirm(conf_sign, {from: owner1}).then(function () {
            return shareable.confirm(conf_sign, {from: owner2}).then(function () {
              return shareable.confirm(conf_sign, {from: owner3}).then(function () {
                return lhProxyContract.balanceOf.call(contractsManager.address).then(function (r2) {
                  assert.equal(r2, 0);
                });
              });
            });
          });
        });
      })
        ;
    });

    it("should be abble to Issue 1000000 LHT for LOC according to issueLimit", function () {
      return contractsManager.reissueAsset(2, 'LHT', 1000000, loc_contracts[0].address, {
        from: owner,
        gas: 3000000
      }).then(function (r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign, {from: owner4}).then(function () {
          return shareable.confirm(conf_sign, {from: owner1}).then(function () {
            return shareable.confirm(conf_sign, {from: owner2}).then(function () {
              return shareable.confirm(conf_sign, {from: owner3}).then(function () {
                return lhProxyContract.balanceOf.call(contractsManager.address).then(function (r2) {
                  assert.equal(r2, 1000000);
                });
              });
            });
          })
        });
      });
    });

    it("shouldn't be abble to Issue 1000 LHT for LOC according to issued and issueLimit", function () {
      return contractsManager.reissueAsset(2, 'LHT', 1000, loc_contracts[0].address, {
        from: owner,
        gas: 3000000
      }).then(function (r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign, {from: owner4}).then(function () {
          return shareable.confirm(conf_sign, {from: owner1}).then(function () {
            return shareable.confirm(conf_sign, {from: owner2}).then(function () {
              return shareable.confirm(conf_sign, {from: owner3}).then(function () {
                return lhProxyContract.balanceOf.call(contractsManager.address).then(function (r2) {
                  assert.equal(r2, 1000000);
                });
              });
            });
          })
        });
      });
    });

    it("shouldn't increment pending operation counter ", function () {
      return shareable.pendingsCount.call({from: owner}).then(function (r) {
        assert.equal(r, 0);
      });
    });

    it("should show LOC issued 1000000", function () {
      return loc_contracts[0].getIssued.call().then(function (r) {
        assert.equal(r, 1000000);
      });
    });

    it("should be abble to Revoke 500000 LHT for LOC according to issueLimit", function () {
      return contractsManager.revokeAsset(2, 'LHT', 500000, loc_contracts[0].address, {
        from: owner,
        gas: 3000000
      }).then(function (r) {
        conf_sign = r.logs[0].args.hash;
        return shareable.confirm(conf_sign, {from: owner4}).then(function () {
          return shareable.confirm(conf_sign, {from: owner1}).then(function () {
            return shareable.confirm(conf_sign, {from: owner2}).then(function () {
              return shareable.confirm(conf_sign, {from: owner3}).then(function () {
                return lhProxyContract.balanceOf.call(contractsManager.address).then(function (r2) {
                  assert.equal(r2, 500000);
                });
              });
            });
          })
        });
      });
    });

    it("should show LOC issued 500000", function () {
      return loc_contracts[0].getIssued.call().then(function (r) {
        assert.equal(r, 500000);
      });
    });

    it("should be able to send 500000 LHT to exchange", function () {
      return contractsManager.sendAsset(2, exchange.address, 500000, {
        from: owner,
        gas: 3000000
      }).then(function () {
        return lhProxyContract.balanceOf.call(exchange.address).then(function (r) {
          assert.equal(r, 495049);
        });
      });
    });

    it("should show 1% of transferred to exchange 500000 on rewards contract balance", function () {
      return lhProxyContract.balanceOf.call(rewards.address).then(function (r) {
        assert.equal(r, 4951);
      });
    });

    it("should be able to set Buy and Sell Exchange rates", function () {
      return contractsManager.forward(1, exchange.contract.setPrices.getData(10, 20)).then(function (r) {
        return exchange.buyPrice.call().then(function (r) {
          return exchange.sellPrice.call().then(function (r2) {
            assert.equal(r, 10);
            assert.equal(r2, 20);
          });
        });
      });
    });

    it("checks that Exchange has 1000 ETH and 100 LHT", function () {
      return lhProxyContract.balanceOf.call(exchange.address).then(function (r2) {
        assert.equal(web3.eth.getBalance(exchange.address), 1000);
        assert.equal(r2, 495049);
      });
    });

    it("should allow owner to buy 10 LHT for 20 Eth each", function () {
      return exchange.buy(10, 20, {value: 10 * 20}).then(function () {
        return lhProxyContract.balanceOf.call(owner).then(function (r) {
          assert.equal(r, 10);
        });
      });
    });

    it("should allow owner to sell 9 LHT for 10 Eth each", function () {
      return lhProxyContract.approve(exchange.address, 10).then(function () {
        var old_balance = web3.eth.getBalance(owner);
        return exchange.sell(9, 10, {from: owner, gas: 300000}).then(function (r) {
          return lhProxyContract.balanceOf.call(owner).then(function (r) {
            assert.equal(r, 0);
          });
        });
      });
    });

    it("check Owner has 100 TIME", function () {
      return timeProxyContract.balanceOf.call(owner).then(function (r) {
        assert.equal(r, 100);
      });
    });

    it("owner should be able to approve 100 TIME to TimeHolder", function () {
      return timeProxyContract.approve.call(timeHolder.address, 100, {from: owner}).then((r) => {
        return timeProxyContract.approve(timeHolder.address, 100, {from: owner}).then(() => {
          assert.isOk(r);
        })
          ;
      })
        ;
    });

    it("should be able to deposit 100 TIME from owner", function () {
      return timeHolder.deposit(100, {from: owner}).then(() => {
        return timeHolder.depositBalance(owner, {from: owner}).then((r) => {
          assert.equal(r, 100);
        })
          ;
      })
        ;
    });

    it("should show 100 TIME for currnet rewards period", function () {
      return rewards.totalDepositInPeriod.call(0).then((r) => {
        assert.equal(r, 100);
      })
    })

    it("should return periods length = 1", function () {
      return rewards.periodsLength.call().then((r) => {
        assert.equal(r, 1);
      })
    })

    it("should be able posible to close rewards period and destribute rewards", function() {
      return rewards.closePeriod({from: owner}).then(() => {
        return rewards.registerAsset(lhProxyContract.address).then(() => {
          return rewards.depositBalanceInPeriod.call(owner, 0, {from: owner}).then((r1) => {
            return rewards.totalDepositInPeriod.call(0, {from: owner}).then((r2) => {
              //return rewards.calculateReward(lhProxyContract.address, 0).then(() => {
                return rewards.rewardsFor.call(lhProxyContract.address, owner).then((r3) => {
                  return rewards.withdrawReward(lhProxyContract.address, r3).then(() => {
                    return lhProxyContract.balanceOf.call(owner).then((r4) => {
                      assert.equal(r1, 100);
                      assert.equal(r2, 100);
                      assert.equal(r3, 4953); //issue reward + exchage sell + exchange buy
                      assert.equal(r4, 4953);
                    })
                  })
                })
              //})
            })
          })
        })
      })
    })
 
    it("should be able to TIME exchange rate from Bittrex", function() {
      return rateTracker.rate.call().then((r) => {
        assert.notEqual(r,null)
      })
    })
      

  });
});
