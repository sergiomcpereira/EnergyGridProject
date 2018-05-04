var BladeUtils = artifacts.require("./bladeutils.sol");
var Supplier = artifacts.require("./supplier.sol");
var Consumer = artifacts.require("./consumer.sol");

module.exports = function (deployer) {
  deployer.deploy(BladeUtils).then(function () {
    console.log("BladeUtils", BladeUtils.address);
    return BladeUtils.address;
  }).then(function () {
    deployer.link(BladeUtils, Supplier);
    return deployer.deploy(Supplier).then(function () {
      console.log("Supplier", Supplier.address);
      return Supplier.address;
    });
  }).then(function () {
    deployer.link(BladeUtils, Consumer);
    return deployer.deploy(Consumer, Supplier.address).then(function () {
      console.log("Consumer", Consumer.address);
      return Consumer.address;
    });
  });

};
