const HDWalletProvider = require('@truffle/hdwallet-provider');
require('babel-register');
require('babel-polyfill');
require('dotenv').config();

const mnemonic = process.env.MNEMONIC;
const endpointUrl = `wss://kovan.infura.io/ws/v3/${process.env.WEB3_INFURA_PROJECT_ID}`
const etherscanToken = process.env.ETHERSCAN_TOKEN;
const maticEndPoint = `https://polygon-mumbai.infura.io/v3/${process.env.WEB3_INFURA_PROJECT_ID}`

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
    },
    matic: {
      provider: () => new HDWalletProvider({
        mnemonic: {
          phrase: mnemonic
        },
        providerOrUrl: maticEndPoint
      }),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      gas: 6000000,
      gasPrice: 10000000000
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