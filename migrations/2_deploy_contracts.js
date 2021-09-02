const SNTCHToken = artifacts.require("SNTCHToken");

const name = 'SNTCH Token'
const symbol = 'SNTCH'
const totalSupply = '100000000000000000000000000'  //100m tokens
const decimals = 18

module.exports = async function(deployer) {
  await deployer.deploy(SNTCHToken, name, symbol, decimals, totalSupply);
  const sntch = await SNTCHToken.deployed()
};