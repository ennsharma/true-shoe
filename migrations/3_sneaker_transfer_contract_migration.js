const SneakerTransferContract = artifacts.require("SneakerTransferContract");

module.exports = function(deployer) {
  // TODO: Initialize addresses
  const vendor;
  const customer;
  const auctionContract;
  const timeout = 2628000;

  deployer.deploy(SneakerTransferContract, vendor, customer, auctionContract, timeout);
}