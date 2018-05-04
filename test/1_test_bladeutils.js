var BladeUtils = artifacts.require("./bladeutils.sol");

contract('BladeUtils', function (accounts) {
    it("should convert mwh into razors", function () {
        return BladeUtils.deployed().then(function (instance) {
            return instance.toRazors.call("1000");
        }).then(function (razors) {
            assert.equal(razors.valueOf(), 2000, "the razors value wasn't 2000");
        });
    });

    it("should convert razors into mwh", function () {
        return BladeUtils.deployed().then(function (instance) {
            return instance.toWh.call("1000");
        }).then(function (wh) {
            assert.equal(wh.valueOf(), 500000, "the razors value wasn't 500000");
        });
    });
});
