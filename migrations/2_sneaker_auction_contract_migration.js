const SneakerAuctionContract = artifacts.require("SneakerAuctionContract");

module.exports = function(deployer) {
  const biddingTime = 200000;
  const minimumBid = web3.utils.toWei('1', 'ether');

  deployer.deploy(SneakerAuctionContract, biddingTime, minimumBid);
}