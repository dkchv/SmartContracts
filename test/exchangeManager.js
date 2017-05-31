var FakeCoin = artifacts.require("./FakeCoin.sol");
var FakeCoin2 = artifacts.require("./FakeCoin2.sol");
var exchangeManager = artifacts.require('./ExchangeManager.sol');
var ChronoBankPlatform = artifacts.require("./ChronoBankPlatform.sol");
var ChronoBankPlatformEmitter = artifacts.require("./ChronoBankPlatformEmitter.sol");
var EventsHistory = artifacts.require("./EventsHistory.sol");
var ChronoBankAssetProxy = artifacts.require("./ChronoBankAssetProxy.sol");
var ChronoBankAssetWithFeeProxy = artifacts.require("./ChronoBankAssetWithFeeProxy.sol");
var ChronoBankAsset = artifacts.require("./ChronoBankAsset.sol");
var ChronoBankAssetWithFee = artifacts.require("./ChronoBankAssetWithFee.sol");
var Exchange = artifacts.require("./Exchange.sol");
var ExchangeManager = artifacts.require("./ExchangeManager.sol");
var ERC20Manager = artifacts.require("./ERC20Manager.sol");
var Rewards = artifacts.require("./Rewards.sol");
var ChronoMint = artifacts.require("./ChronoMint.sol");
var ContractsManager = artifacts.require("./ContractsManager.sol");
var ProxyFactory = artifacts.require("./ProxyFactory.sol");
var LOC = artifacts.require("./LOC.sol");
var Shareable = artifacts.require("./PendingManager.sol");
var TimeHolder = artifacts.require("./TimeHolder.sol");
var UserStorage = artifacts.require("./UserStorage.sol");
var UserManager = artifacts.require("./UserManager.sol");
var AssetsManager = artifacts.require("./AssetsManager");
var Vote = artifacts.require("./Vote.sol");
var Reverter = require('./helpers/reverter');
var bytes32 = require('./helpers/bytes32');

contract('Exchange Manager', function(accounts) {
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
  var erc20Manager;
  var rewardContract;
  var assetsManager;
  var timeContract;
  var lhContract;
  var timeProxyContract;
  var lhProxyContract;
  var exchange;
  var platform;
  var exchangeManager;
  var rewards;
  var shareable;
  var userStorage;
  var userManager;
  var vote;
  var timeHolder;
  var loc_contracts = [];
  var labor_hour_token_contracts = [];
  var Status = {maintenance: 0, active: 1, suspended: 2, bankrupt: 3};
  var unix = Math.round(+new Date() / 1000);

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
  const fakeArgs = [0, 0, 0, 0, 0, 0, 0, 0];

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

  before('setup', function (done) {
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
      return Exchange.deployed()
    }).then(function (instance) {
      exchange = instance;
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
      return Vote.deployed()
    }).then(function (instance) {
      vote = instance;
      return instance.init(ContractsManager.address)
    }).then(function () {
      return TimeHolder.deployed()
    }).then(function (instance) {
      timeHolder = instance;
      return instance.init(ContractsManager.address, ChronoBankAssetProxy.address)
    }).then(function () {
      return timeHolder.addListener(rewards.address)
    }).then(function () {
      return timeHolder.addListener(vote.address)
    }).then(function () {
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
      return userManager.setupEventsHistory(EventsHistory.address, {
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
    }).then(function () {
      return Rewards.deployed()
    }).then(function (instance) {
      rewards = instance;
      return rewards.init(TimeHolder.address, 0)
    }).then(function (instance) {
      return rewards.addAsset(ChronoBankAssetWithFeeProxy.address)
    }).then(function () {
      return rewards.setupEventsHistory(EventsHistory.address, {
        from: accounts[0],
        gas: 3000000
      });
    }).then(function () {
      done();
    }).catch(function (e) { console.log(e); });
  });

  context("initial tests", function () {

    it("Platform has correct TIME proxy address.", function () {
      return chronoBankPlatform.proxies.call(SYMBOL).then(function (r) {
        assert.equal(r, timeProxyContract.address);
      });
    });

    it("TIME contract has correct TIME proxy address.", function () {
      return timeContract.proxy.call().then(function (r) {
        assert.equal(r, timeProxyContract.address);
      });
    });

    it("TIME proxy has right version", function () {
      return timeProxyContract.getLatestVersion.call().then(function (r) {
        assert.equal(r, timeContract.address);
      });
    });

    it("ContractManager contain correct ERC20Manager address", function () {
      return contractsManager.getContractAddressByType.call(3).then(function (r) {
        console.log(r);
        assert.equal(r, erc20Manager.address);
      });
    });

    it("allow add TIME Asset", function() {
      return assetsManager.addAsset.call(timeProxyContract.address,SYMBOL, owner).then(function(r) {
        console.log(r);
        return assetsManager.addAsset(timeProxyContract.address,SYMBOL, owner, {
          from: accounts[0],
          gas: 3000000
        }).then(function(tx) {
          return assetsManager.getAssets.call().then(function(r) {
            console.log(r);
            assert.equal(r.length,1);
          });
        });
      });
    });

    it("ERC20Manager contains correct TIME address", function () {
      return erc20Manager.getTokenAddressBySymbol.call(SYMBOL).then(function (r) {
        console.log(r);
        assert.equal(r, timeProxyContract.address);
      });
    });

  });

  context("CRUD interface test", function () {

    it("should allow to create new exchange", function () {
      return exchangeManager.createExchange.call(SYMBOL, false,{
        from: accounts[0],
        gas: 3000000
      }).then(function (r) {
        return exchangeManager.createExchange(SYMBOL, false, {
          from: accounts[0],
          gas: 3000000
        }).then(function () {
          console.log(r);
          assert.equal(r, 1);
        });
      });
    });

    it("should allow to add exchange contract", function () {
      return exchangeManager.addExchange.call(exchange.address, {
        from: accounts[0],
        gas: 3000000
      }).then(function (r) {
        return exchangeManager.addExchange(exchange.address, {
          from: accounts[0],
          gas: 3000000
        }).then(function () {
          console.log(r);
          assert.equal(r, 2);
        });
      });
    });

    it("shouldn't add exchange contract if it is not an exchange contract", function () {
      return exchangeManager.addExchange(coin.address, {
        from: accounts[0],
        gas: 3000000
      }).then(assert.fail, () => true)
    });

  });

  context("Security tests", function () {


  });


});



