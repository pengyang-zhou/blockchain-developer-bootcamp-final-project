var EthDonation = artifacts.require("./EthDonation.sol");

module.exports = function(deployer) {
  deployer.deploy(EthDonation);
};
