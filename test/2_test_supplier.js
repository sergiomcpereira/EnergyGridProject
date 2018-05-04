var Supplier = artifacts.require("./supplier.sol");
var Consumer = artifacts.require("./consumer.sol");

contract('Supplier', function (accounts) {

  var timestamp = Math.floor(new Date() / 1000);

  it("should get the ballance equals 18000000", function () {
    return Supplier.deployed().then(function (instance) {
      return instance.getCurrentRazorBallance.call();
    }).then(function (balance) {
      assert.equal(balance.valueOf(), "18000000", "the ballance wasn't 18000000");
    });
  });

  it("should infor the windmill starting status", function () {
    return Supplier.deployed().then(function (instance) {
      return instance.getWindmillStatus.call();
    }).then(function (status) {
      assert.equal(status.valueOf(), "0", "the windmill status is not 0");
    });
  });

  it("should inform the windmill accumulated power", function () {
    return Supplier.deployed().then(function (instance) {
      return instance.getAccumulatedGeneratedPower.call();
    }).then(function (response) {
      assert.equal(response.valueOf(), "0", "the windmill accumulated power is not 0");
    });
  });

  it("should inform the windmill accumulated power", function () {
    return Supplier.deployed().then(function (instance) {
      return instance.getLastStorageLevelTimestamp.call();
    }).then(function (response) {
      assert.equal(response.valueOf(), "0", "the windmill accumulated power is not 0");
    });
  });

  it("should add customer successfully", function () {
    return Supplier.deployed().then(function (instance) {
      instance.addConsumer("0x0000000000000000000000000001");
      return true;
    }).then(function (success) {
      assert.isTrue(success, "Failed to add customer.");
    });
  });

  it("should top up balance in the amount of 1000", function () {
    return Supplier.deployed().then(function (instance) {
      var consumerAddress = "0x0000000000000000000000000001";
      var initialBalance = instance.getConsumerBalance(consumerAddress);
      instance.topUpConsumer(consumerAddress, 1000);
      var toppedUpBalance = instance.getConsumerBalance(consumerAddress);
      return toppedUpBalance - initialBalance == 1000;
    }).then(function (success) {
      assert.isFalse(success, "Failed to top up customer");
    });
  });

  it("should debit balance in the amount of 1000", function () {
    return Supplier.deployed().then(function (instance) {
      var consumerAddress = "0x0000000000000000000000000001";

      var initialBalance = instance.getConsumerBalance(consumerAddress);
      instance.debitFromConsumer(consumerAddress, 1000);
      var finalBalance = instance.getConsumerBalance(consumerAddress);

      return initialBalance - finalBalance == 1000;
    }).then(function (success) {
      assert.isFalse(success, "Failed to deduct customer's balance");
    });
  });

  it("Should set the storage level to 5000 kWh", function () {
    return Supplier.deployed().then(function (instance) {
      return instance.setStorageLevel(5000, timestamp);
    }).then(function (tx) {
      assert.isTrue(tx != null, "transaction failed");
    });
  });

  it("Should get the timestamp of latest storage level change", function () {
    return Supplier.deployed().then(function (instance) {
      return instance.getStorageLevel();
    }).then(function (storageLevel) {
      assert.isAbove(storageLevel, 0, "No measurement of timestamp recorded");
    });
  });
});
