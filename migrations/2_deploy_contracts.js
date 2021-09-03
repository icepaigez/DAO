const SNTCHToken = artifacts.require("SNTCHToken");

const name = 'SNTCH Token'
const symbol = 'SNTCH'
const totalSupply = '100000000000000000000000000'  //100m tokens

module.exports = async function(deployer) {
  await deployer.deploy(SNTCHToken, name, symbol, totalSupply);
  const sntch = await SNTCHToken.deployed()
};