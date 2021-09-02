const SNTCHToken = artifacts.require("SNTCHToken");

const name = 'SNTCH Token'
const symbol = 'SNTCH'
const totalSupply = 100 * 10**6 * 10**18 //100m tokens
const decimals = 18

module.exports = async function(deployer) {
  await deployer.deploy(SNTCHToken, name, symbol, decimals, totalSupply);
  const sntch = await SNTCHToken.deployed()
  console.log("the token was deployed at", sntch.address)
};