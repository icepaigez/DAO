const SntchDao = artifacts.require("SntchDao");

function tokens(qty) {
	return web3.utils.toWei(qty, "ether");
}

contract('SntchDao', accounts => {
	let dao;
	before(async () => {
		dao = await SntchDao.deployed();
	})

	describe('DAO Name', async() => {
		it('should have a name', async() => {
			let daoName = await dao.name();
			assert.equal(daoName, 'SNTCH DAO');
		})
	})
})