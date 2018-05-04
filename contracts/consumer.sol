pragma solidity ^0.4.19;

import "./bladeutils.sol";
import "./supplier.sol";

contract Consumer {

    //reference of the supplier contract
    Supplier private supplierContract;
    //true is consuming from the windmill
    //false is consuming from the grid
    bool private source;

    event PowerSourceChanged(bool success, uint16 message, bool fromGrid);
    event TopUpDone(bool success, uint16 message);
    /**
    Ensures that the consumer has enough ballance
    */
    modifier _hasBallance(uint256 wattHour)  {
        if(getRazorBallance() - wattHour >= 0) {
            source = true;
            emit PowerSourceChanged(true, 200, source);
            _;
        } else {
            source = false;
            emit PowerSourceChanged(true, 200, source);
        }
    }
    /**
    Creates an instance of the consumer contract.
    The Supplier contract addres must be informed.
    */
    function Consumer(address supContract) public {
        supplierContract = Supplier(supContract);
    }

    /**
    Displays the supplier for this contract */
    function getSupplierAddress() public view returns (address) {
        return (supplierContract);
    }

    /***
    Informs the consumer power. If  the storage level is empty
    the user must consume from the grid, otherwise 
    the system will debit razors from the user account.
    */
    function consume(uint256 wattHour) public {
        if(supplierContract.getStorageLevel() - wattHour <= 0) {
            source = false;
            emit PowerSourceChanged(true, 200, source);
        }
        else{
            uint256 valueToDebit = BladeUtils.toRazors(wattHour);
            supplierContract.debitFromConsumer(this, valueToDebit);
        }
    }
    /**
    Returns the razor ballance
    */
    function getRazorBallance() public view returns(uint256) {       
        return supplierContract.getConsumerBalance(this);
    }
}