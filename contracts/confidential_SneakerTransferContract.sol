pragma solidity ^0.4.23;

contract SneakerTransferContract {
    // The address of the vendor account.
    address public vendor;

    // The address of the customer account.
    address public customer;

    // The address of the corresponding auction contract.
    address public auctionContract;

    // Current state of the transfer.
    uint public sneakerPrice;
    bool public sneakerPriceAdded;

    uint public deliveryWindow;
    bool public delivered;
    bool public refunded;

    // Events that will be fired on changes.
    event SneakerDelivered(address vendor, address customer);
    event RefundCompleted(address vendor, address customer);
    event DeliveryTimeLimitExpired(address vendor, address customer);

    /// Create a simple transfer with `_timeout`
    /// seconds until the `_customer` is refunded
    /// for untimely delivery by the `_vendor`
    constructor(
        address _vendor,
        address _customer,
        address _auctionContract,
        uint _timeout
    ) public {
        vendor = _vendor;
        customer = _customer;
        auctionContract = _auctionContract;

        deliveryWindow = now + _timeout;

        sneakerPriceAdded = false;
        delivered = false;
        refunded = false;
    }

    function addSneakerPrice() public payable {
        require(msg.sender == customer);
        sneakerPrice = msg.value;
        sneakerPriceAdded = true;
    }

    /// Refund a customer whose delivery window was not honored.
    function refund() public {
        require(!refunded, "The refund amount has already been refunded.");
        require(sneakerPriceAdded, "Assets not yet provided.");
        require(!delivered, "The sneakers were delivered on time.");
        require(now > deliveryWindow, "The delivery window has not yet expired.");

        refunded = true;
        emit RefundCompleted(vendor, customer);
        emit DeliveryTimeLimitExpired(vendor, customer);

        customer.transfer(sneakerPrice);
    }

    /// Verifies vendor's timely delivery via USPS oracle.
    function verifyDelivery() public {
        require(sneakerPriceAdded, "Assets not yet provided.");
        require(!delivered, "The sale amount has already been claimed.");
        require(now <= deliveryWindow, "The timeout has already expired.");

        delivered = true; // TODO: Replace with API call to DeliveryService
        emit SneakerDelivered(vendor, customer);

        vendor.transfer(sneakerPrice);
    }
}