// test_sneaker_auction_contract.js
const SneakerAuctionContract = artifacts.require("SneakerAuctionContract");
const Web3c = require("web3c");
const truffleConfig = require("../truffle-config.js");

contract("SneakerAuctionContract", (accounts) => {
  // Creates an instance of web3c to use in the tests with a provider that
  // makes and signs requests. The provider is configured with a private key
  // (derived from a mnemonic) and gateway url.
  const web3c = new Web3c(truffleConfig.networks.oasis.provider());

  // Creates an instance of our sneaker auction contract, communicating with the contract
  // at the deployed address. Note: this address will be different in tests since it
  // will be redeployed via migration before every run of truffle test.
  const auctionInstance = new web3c.confidential.Contract(SneakerAuctionContract.abi, SneakerAuctionContract.address, {
    // the default "from" address of all transactions originating from this contract
    from: accounts[0]
  });

  // Tests
  it('Validate that minimum bid is 1 ether', async () => {
    let minimumBid = await auctionInstance.methods.minimumBid().call();
    assert.equal(minimumBid, web3.utils.toWei('1', 'ether'));
  });

  // it('Validate outbidding previous highest bidder', async () => {
  //   // Bid
  //   await auctionInstance.methods.bid().send({ from: accounts[1], value: web3.utils.toWei('1', 'ether') });
  //   let highestBid = await auctionInstance.methods.highestBid().call();
  //   assert.equal(highestBid, web3.utils.toWei('1', 'ether'));

  //   // // Bid higher
  //   // await auctionInstance.methods.bid().send({ from: accounts[2], value: web3.utils.toWei('3', 'ether') });
  //   // let newHighestBid = await auctionInstance.methods.highestBid().call();
  //   // assert.equal(newHighestBid, web3.utils.toWei('3', 'ether'));

  //   // // Lower bidder withdraws
  //   // let withdrawSuccessfulLower = await auctionInstance.methods.withdraw().send({ from: accounts[1] });
  //   // assert.equal(withdrawSuccessfulLower, true);

  //   // // Higher bidder can't withdraw
  //   // let withdrawSuccessfulHigher = await auctionInstance.methods.withdraw().call({ from: accounts[2] });
  //   // assert.equal(withdrawSuccessfulHigher, false);
  // });
});