const SNTCHToken = artifacts.require("SNTCHToken");
const SntchDao = artifacts.require("SntchDao");

const name = 'SNTCH Token'
const symbol = 'SNTCH'
const totalSupply = '100000000000000000000000000'  //100m tokens

module.exports = async function(deployer, network) {
  await deployer.deploy(SNTCHToken, name, symbol, totalSupply);

  let chainlink_aggr;

  if (network === 'matic') {
    chainlink_aggr = '0x0715A7794a1dc8e42615F059dD6e406A6594651A'
    await deployer.deploy(SntchDao, chainlink_aggr);
  } else if (network === 'kovan') {
    chainlink_aggr = '0x9326BFA02ADD2366b30bacB125260Af641031331'
    await deployer.deploy(SntchDao, chainlink_aggr);
  }
  
  
  const sntch = await SNTCHToken.deployed();
  const dao = await SntchDao.deployed();
  let ethUsdPrice = await dao.getLatestEthPrice();
  ethUsdPrice = (Number(web3.utils.fromWei(String(ethUsdPrice))) * 10**18) / 10**8

  console.log('the current ETH price in USD is >>', ethUsdPrice)

};