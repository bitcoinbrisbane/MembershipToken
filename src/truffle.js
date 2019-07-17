module.exports = {

    //plugins: ["truffle-security"],
  
    networks: {
      development: {
        host: "localhost",
        port: 8545,
        network_id: "*",
        gas: 4600000
      }
    },
    // Configure your compilers
    compilers: {
      solc: {
        version: "0.5.8"
      }
    }
};