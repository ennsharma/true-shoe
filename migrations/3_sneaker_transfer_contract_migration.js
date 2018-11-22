const SneakerTransferContract = artifacts.require("SneakerTransferContract");

module.exports = function(deployer) {
  const vendor = "0xc107Ed8C670Bd7266D22f735C8e3A1befc8F24c6";
  const customer = "0xc107Ed8C670Bd7266D22f735C8e3A1befc8F24c6";
  const auctionContract = "0x1ae12CE8e68C82460E63Bc197084F9FB781D44f6";
  const timeout = 15;

  deployer.deploy(SneakerTransferContract, vendor, customer, auctionContract, timeout);
}