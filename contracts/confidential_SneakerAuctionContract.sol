pragma solidity ^0.4.23;

contract SneakerAuctionContract {
    // The address of the account that created this auction.
    address public auctionCreator;

    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;
    uint public minimumBid;
    bool public auctionEnded;
    uint public auctionEnd;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Events that will be fired on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    /// Create a simple auction with `_biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `_beneficiary`.
    constructor(
        uint _biddingTime,
        uint _minimumBid
    ) public {
        auctionCreator = msg.sender;
        auctionEnd = now + _biddingTime;

        minimumBid = _minimumBid;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() public payable {

        // To be able to bid, the auction must 
        // still be ongoing
        require(
            now <= auctionEnd,
            "Auction already ended."
        );

        // Enforce minimum bid constraint.
        require(
            msg.value >= minimumBid,
            "Bid amount is below the minimumBid."
        );

        // If the bid is not higher, send the
        // money back.
        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        if (highestBid != 0) {
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `send` returns.
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function endAuction() public returns (bool) {
        // Anyone can end the auction, but only once the auction timeout expires.
        require(now >= auctionEnd, "Auction not yet ended.");
        require(!auctionEnded, "auctionEnd has already been called.");

        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);

        auctionCreator.transfer(highestBid);

        // TODO: Initiate call to SneakerTransferContract, directly from the SneakerAuctionContract
        //       Currently not possible to call other contracts via contract-kit
        return true;
    }
}