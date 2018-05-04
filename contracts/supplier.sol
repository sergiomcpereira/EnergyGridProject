pragma solidity ^0.4.19;

import "./bladeutils.sol";

contract Supplier {

    //Owner Wallet of the Contract
    address private owner;
    //Consumers managed by this Supplier
    mapping(address => uint256) private consumers;
    //Storage level (real time readings)
    uint256 private storageLevel;
    //Last time the storage level was informed by the device
    uint256 private lastStorageLevelTimestamp;
    //The total windmill acumulated power
    uint256 private accumulatedGeneratedPower;
    //Razor assets available to sell. If the value is negative, the community sold more than they needed.
    uint256 private razorAsset = 18000 * 1000;
    //Windmill current status
    uint16 private windmillStatus;
    //Raised when a reading is informed by the windmill
    event GeneratedPowerIncremented(bool success, uint16 returnCode, uint256 accumulatedPower);
    //Raised when a consumer is added
    event ConsumerAdded(bool success, uint16 returnCode, address consumerAddress);
    //Raised when the consumer ballance is changed
    event ConsumerBallanceChanged(bool success, uint16 returnCode, address consumerAddress, uint256 ballance);
    //Rased when the storage level is changed
    event StorageLevelChanged(bool success, uint16 returnCode, uint256 level, uint256 timestamp);
    //Raised when the Windmill Status is Changed
    event WindmillStatusInformed(bool success, uint16 returnCode, uint16 status);
    //Raised when customer does not have enough razor balance to exchange for energy.
    event NotEnoughRazors(address consumerAddress);

    /**
    Constructs the contract and sets the contract owner address 
    to the main wallet that will operate it.
     */
    function Supplier() public {
        owner = msg.sender;
    }
    /**
    Modifier to validate if the sender is the owner and can
    change the ballance of the consumer contract.
     */
    modifier _canChangeBallance(address consumerAddress) {
        if(msg.sender == owner) {
            _;
        } else {
            emit ConsumerBallanceChanged(false, 403, consumerAddress, consumers[consumerAddress]);
        }
    }

    modifier _hasBalance(address consumerAddress, uint256 valueToDeduct) {
        if (consumers[consumerAddress] >= valueToDeduct) {
            _;
        } else {
            emit NotEnoughRazors(consumerAddress);
        }
    }
    /**
    Modifier to validate if the sender is the owner and can
    add the consumer contract to the mapping.
     */
    modifier _canAddConsumer(address consumerAddress) {
        if(msg.sender == owner) {
            _;
        } else {
            emit ConsumerAdded(false, 403, consumerAddress);
        }
    }
    /**
    Modifier to validate if the sender is the owner and can
    set the storage level.
     */
    modifier _canSetStorageLevel(uint256 level, uint256 timestamp) {
        if(msg.sender == owner) {
            _;
        } else {
            emit StorageLevelChanged(false, 403, level, timestamp);
        }
    }
        /**
    Modifier to validate if the sender is the owner and can
    set the windmill status.
     */
    modifier _canSetWindmillStatus(uint16 status) {
        if(msg.sender == owner) {
            _;
        } else {
            emit WindmillStatusInformed(false, 403, status);
        }
    }

    /**
    Modifier to validate if the sender is the owner and can 
    set the reading of the windmill.
     */
    modifier _canIncrementGeneratedPower() {
        if(msg.sender == owner){
            _;
        }
        emit GeneratedPowerIncremented(false, 403, 0);
    }
    /**
    Adds a consumer to this supplier contract.
     */
    function addConsumer(address consumerAddress) public _canAddConsumer(consumerAddress) {
        consumers[consumerAddress] = 0;
        emit ConsumerAdded(true, 200, consumerAddress);
    }
    /**
    Tops up razors to the consumer ballance and removes from the 
    current razors asset.
     */
    function topUpConsumer(address consumerAddress, uint256 value) public _canChangeBallance(consumerAddress) {
        consumers[consumerAddress] += value;
        razorAsset -= value;
        emit ConsumerBallanceChanged(true, 200, consumerAddress, consumers[consumerAddress]);
    }
    /**
    Gets the consumer razor balance based on its address
     */
    function getConsumerBalance(address consumerAddress) public view returns (uint256) {
        return consumers[consumerAddress];
    }
    /**
    Debits razors from the consumer ballance
     */
    function debitFromConsumer(address consumerAddress, uint256 value) public _canChangeBallance(consumerAddress) _hasBalance(consumerAddress, value) {
        consumers[consumerAddress] -= value;
        emit ConsumerBallanceChanged(true, 200, consumerAddress, consumers[consumerAddress]);
    }
    /**
    Sets the current storage level in kwh. It's supposed to set the pre-calculated
    ammount of energy being provided by the storage.
     */
    function setStorageLevel(uint256 level, uint256 timestamp) public {
        storageLevel = level;
        lastStorageLevelTimestamp = timestamp;
        emit StorageLevelChanged(true, 200, level, timestamp);
    }
    /**
    Reads the last storage level in kwh.
     */
    function getStorageLevel() public view returns(uint256) {
        return (storageLevel);
    }
    /**
    Reads the last storage level timestamp.
     */
    function getLastStorageLevelTimestamp() public view returns(uint256) {
        return (lastStorageLevelTimestamp);
    }
    /**
    Increments the total accumulated power.
     */
    function incrementGeneratedPower(uint256 accumulatedPower) public _canIncrementGeneratedPower() {
        accumulatedGeneratedPower += accumulatedPower;
    }
    /**
    Gets the total acumulated power generated by the windmill.
     */
    function getAccumulatedGeneratedPower() public view returns (uint256) {
        return (accumulatedGeneratedPower);
    }
    /**
    Gets the total acumulated razors generated by the windmill.
     */
    function getAccumulatedGeneratedRazors() public view returns (uint256) {
        return (BladeUtils.toRazors(accumulatedGeneratedPower));
    }
    /**
    Gets the total razor generated by the windmill.
     */
    function getCurrentRazorBallance() public view returns (uint256) {
        return (razorAsset);
    }
    /**
    Sets the Windmill status.
     */
    function setWindmillStatus(uint16 status) public _canSetWindmillStatus(status) {
        windmillStatus = status;
        emit WindmillStatusInformed(true, 200, status);
    }
    /**
    Gets the windmilll last status.
     */
    function getWindmillStatus() public view returns(uint16) {
        return (windmillStatus);
    }
}