const SneakerAuctionContract = artifacts.require("SneakerAuctionContract");

module.exports = function(deployer) {
  const biddingTime = 200000;
  const minimumBid = web3.utils.toWei('0.000000000001', 'ether');

  deployer.deploy(SneakerAuctionContract, biddingTime, minimumBid);
}