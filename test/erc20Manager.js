var FakeCoin = artifacts.require("./FakeCoin.sol");
var FakeCoin2 = artifacts.require("./FakeCoin2.sol");
var ChronoBankPlatform = artifacts.require("./ChronoBankPlatform.sol");
var ChronoBankPlatformEmitter = artifacts.require("./ChronoBankPlatformEmitter.sol");
var EventsHistory = artifacts.require("./EventsHistory.sol");
var ChronoBankAssetProxy = artifacts.require("./ChronoBankAssetProxy.sol");
var ChronoBankAssetWithFeeProxy = artifacts.require("./ChronoBankAssetWithFeeProxy.sol");
var ChronoBankAsset = artifacts.require("./ChronoBankAsset.sol");
var ChronoBankAssetWithFee = artifacts.require("./ChronoBankAssetWithFee.sol");
var ChronoMintEmitter = artifacts.require("./ChronoMintEmitter.sol");
var Exchange = artifacts.require("./Exchange.sol");
var Rewards = artifacts.require("./Rewards.sol");
var ChronoMint = artifacts.require("./ChronoMint.sol");
var AssetsManager = artifacts.require("./AssetsManager");
var ContractsManager = artifacts.require("./ContractsManager.sol");
var ProxyFactory = artifacts.require("./ProxyFactory.sol");
var ERC20Manager = artifacts.require("./ERC20Manager.sol");
var ExchangeManager = artifacts.require("./ExchangeManager.sol");
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
var eventsHelper = require('./helpers/eventsHelper');

contract('ERC20 Manager', function(accounts) {
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
  var conf_sign3;
  var assetsManager;
  var coin;
  var coin2;
  var chronoMint;
  var chronoMintEmitter;
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
  var erc20Manager;
  var exchangeManager;
  var rewards;
  var userManager;
  var userStorage;
  var timeHolder;
  var rateTracker;
  var txId;
  var watcher;
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

  const contractTypes = {
    LOCManager: 0, // LOCManager
    PendingManager: 1, // PendingManager
    UserManager: 2, // UserManager
    ERC20Manager: 3, // ERC20Manager
    ExchangeManager: 4, // ExchangeManager
    TrackersManager: 5, // TrackersManager
    Voting: 6, // Voting
    Rewards: 7, // Rewards
    AssetsManager: 8, // AssetsManager
    TimeHolder:  9 //TimeHolder
  }

  before('setup', function(done) {
    FakeCoin.deployed().then(function(instance) {
      coin = instance
      return FakeCoin2.deployed()
    }).then(function(instance) {
      coin2 = instance
      return UserStorage.deployed()
    }).then(function (instance) {
      userStorage = instance
      return instance.addOwner(UserManager.address)
    }).then(function () {
      return UserManager.deployed()
    }).then(function (instance) {
      userManager = instance
      return instance.init(UserStorage.address, ContractsManager.address)
    }).then(function () {
      return ContractsManager.deployed()
    }).then(function (instance) {
      contractsManager = instance
      return Shareable.deployed()
    }).then(function (instance) {
      shareable = instance
      return instance.init(ContractsManager.address)
    }).then(function () {
      return ChronoMint.deployed()
    }).then(function (instance) {
      chronoMint = instance
      return instance.init(ContractsManager.address)
    }).then(function () {
      return ChronoBankPlatform.deployed()
    }).then(function (instance) {
      platform = instance
      return ChronoBankAsset.deployed()
    }).then(function (instance) {
      timeContract = instance
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
      return Shareable.deployed()
    }).then(function (instance) {
      shareable = instance;
      return AssetsManager.deployed()
    }).then(function (instance) {
      assetsManager = instance;
      return assetsManager.init(chronoBankPlatform.address, contractsManager.address, ProxyFactory.address)
    }).then(function () {
      return ERC20Manager.deployed()
    }).then(function (instance) {
      erc20Manager = instance;
      return erc20Manager.init(ContractsManager.address)
    }).then(function () {
      return ExchangeManager.deployed()
    }).then(function (instance) {
      exchangeManager = instance;
      return exchangeManager.init(ContractsManager.address)
    }).then(function () {
      return Rewards.deployed()
    }).then(function (instance) {
      rewards = instance;
      return rewards.init(ContractsManager.address, 0)
    }).then(function (instance) {
      return rewards.addAsset(ChronoBankAssetWithFeeProxy.address)
    }).then(function () {
      return rewards.setupEventsHistory(EventsHistory.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return TimeHolder.deployed()
    }).then(function (instance) {
      timeHolder = instance;
      return instance.init(ContractsManager.address, ChronoBankAssetProxy.address)
    }).then(function () {
      return timeHolder.addListener(rewards.address)
    }).then(function () {
      return ChronoBankPlatformEmitter.deployed()
    }).then(function (instance) {
      chronoBankPlatformEmitter = instance;
      return ChronoMintEmitter.deployed()
    }).then(function (instance) {
      chronoMintEmitter = instance;
      return EventsHistory.deployed()
    }).then(function (instance) {
      eventsHistory = instance;
      return chronoBankPlatform.setupEventsHistory(EventsHistory.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return chronoMint.setupEventsHistory(EventsHistory.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return userManager.setupEventsHistory(EventsHistory.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoMintEmitter.contract.newLOC.getData.apply(this, fakeArgs).slice(0, 10), ChronoMintEmitter.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      return eventsHistory.addEmitter(chronoMintEmitter.contract.hashUpdate.getData.apply(this, fakeArgs).slice(0, 10), ChronoMintEmitter.address, {
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
      return eventsHistory.addVersion(chronoMint.address, "Origin", "Initial version.");
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
      return instance.transfer(assetsManager.address, 200000000000, {from: accounts[0]})
    }).then(function (r) {
      return chronoBankPlatform.changeOwnership(SYMBOL, assetsManager.address, {from: accounts[0]})
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
      return instance.changeOwnership(SYMBOL2, assetsManager.address, {from: accounts[0]})
    }).then(function () {
      return chronoBankPlatform.changeContractOwnership(assetsManager.address, {from: accounts[0]})
    }).then(function () {
      return assetsManager.claimPlatformOwnership({from: accounts[0]})
    }).then(function(instance) {
      //web3.eth.sendTransaction({to: Exchange.address, value: BALANCE_ETH, from: accounts[0]});
      done();
    }).catch(function (e) { console.log(e); });
    //reverter.snapshot(done);
  });

  context("initial tests", function(){

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

    it("can issue new Asset", function() {
      return assetsManager.createAsset.call('TEST','TEST','TEST',1000000,2,true,false).then(function(r) {
        console.log(r);
        return assetsManager.createAsset('TEST','TEST','TEST',1000000,2,true,false,{
          from: accounts[0],
          gas: 3000000
        }).then(function(tx) {
          return ChronoBankAssetProxy.at(r).then(function(instance) {
            return instance.totalSupply().then(function(r) {
              console.log(r);
              assert.equal(r,1000000);
            });
          });
        });
      });
    });

    it("allow add TIME Asset", function() {
      return assetsManager.addAsset.call(timeProxyContract.address,'TIME', owner).then(function(r) {
        return assetsManager.addAsset(timeProxyContract.address,'TIME', owner, {
          from: accounts[0],
          gas: 3000000
        }).then(function(tx) {
          return assetsManager.getAssets.call().then(function(r2) {
            assert.equal(r,true);
            assert.equal(r2.length,2);
          });
        });
      });
    });

    it("doesn't allow to add LHT Asset with TIME symbol", function() {
      return assetsManager.addAsset.call(lhProxyContract.address,'TIME', chronoMint.address).then(function(r) {
        return assetsManager.addAsset(lhProxyContract.address,'TIME', chronoMint.address, {
          from: accounts[0],
          gas: 3000000
        }).then(function(tx) {
          return assetsManager.getAssets.call().then(function(r2) {
            assert.equal(r,false);
            assert.equal(r2.length,2);
          });
        });
      });
    });

    it("allow add LHT Asset", function() {
      return assetsManager.addAsset.call(lhProxyContract.address,'LHT', chronoMint.address).then(function(r) {
        return assetsManager.addAsset(lhProxyContract.address,'LHT', chronoMint.address, {
          from: accounts[0],
          gas: 3000000
        }).then(function(tx) {
          return assetsManager.getAssets.call().then(function(r2) {
            assert.equal(r,true);
            assert.equal(r2.length,3);
          });
        });
      });
    });

    it("can show all Asset contracts", function() {
      return erc20Manager.getTokenAddresses.call().then(function(r) {
        console.log(r);
        assert.equal(r.length,3);
      });
    });

    it("can provide TimeProxyContract address.", function() {
      return erc20Manager.getTokenAddressBySymbol.call('TIME').then(function(r) {
        assert.equal(r,timeProxyContract.address);
      });
    });

    it("can provide LHProxyContract address.", function() {
      return erc20Manager.getTokenAddressBySymbol.call('LHT').then(function(r) {
        assert.equal(r,lhProxyContract.address);
      });
    });

  });
});
