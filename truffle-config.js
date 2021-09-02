const HDWalletProvider = require('@truffle/hdwallet-provider');
require('babel-register');
require('babel-polyfill');
require('dotenv').config();

const mnemonic = process.env.MNEMONIC;
const endpointUrl = `wss://kovan.infura.io/ws/v3/${process.env.WEB3_INFURA_PROJECT_ID}`
const etherscanToken = process.env.ETHERSCAN_TOKEN;


module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider({
          mnemonic: {
            phrase: mnemonic
          },
          providerOrUrl: endpointUrl
        })
      },
      gas: 5000000,
      gasPrice: 25000000000,
      network_id: 42
    }
  },
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      version:"^0.8.0",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: etherscanToken
  }
}
//truffle run verify Contract --network kovan : to verify the smart contracts on etherscan