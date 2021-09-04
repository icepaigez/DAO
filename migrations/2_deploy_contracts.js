const SNTCHToken = artifacts.require("SNTCHToken");
const SntchDao = artifacts.require("SntchDao");

const name = 'SNTCH Token'
const symbol = 'SNTCH'
const totalSupply = '100000000000000000000000000'  //100m tokens

module.exports = async function(deployer, network) {
  await deployer.deploy(SNTCHToken, name, symbol, totalSupply);
  const sntch = await SNTCHToken.deployed();

  let chainlink_aggr;
  let dao;

  if (network === 'matic') {
    chainlink_aggr = '0x0715A7794a1dc8e42615F059dD6e406A6594651A'
    await deployer.deploy(SntchDao, chainlink_aggr, sntch.address);
    dao = await SntchDao.deployed();
  } else if (network === 'kovan') {
    chainlink_aggr = '0x9326BFA02ADD2366b30bacB125260Af641031331'
    await deployer.deploy(SntchDao, chainlink_aggr, sntch.address);
    dao = await SntchDao.deployed();
  }

  let deployedBy = deployer["networks"][network]["from"]
  
  let tokenBal = await sntch.balanceOf(deployedBy)
  tokenBal = web3.utils.toBN(tokenBal)
  if (dao !== undefined) {
    //transfer the tokens to the DAO
    await sntch.transfer(dao.address, tokenBal)
  }
};