pragma solidity ^0.4.19;

library BladeUtils{

    function toRazors(uint256 wh) public pure returns (uint256) {
        return wh * 2;
    }

    function toWh(uint256 razors) public pure returns (uint256) {
        return uint256(razors * 1000 / 2);
    }
}
