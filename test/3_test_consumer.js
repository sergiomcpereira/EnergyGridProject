var Consumer = artifacts.require("./consumer.sol");

contract('Consumer', function (accounts) {
  it("should get the ballance equals 0", function () {
    return Consumer.deployed().then(function (instance) {
      return instance.getRazorBallance.call();
    }).then(function (balance) {
      assert.equal(balance.valueOf(), "0", "the ballance wasn't 0");
    });
  });
});
