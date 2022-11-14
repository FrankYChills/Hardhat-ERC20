const networkConfig = {
  31337: {
    name: "localhost",
  },
  5: {
    name: "goerli",
  },
};

const INITIAL_SUPPLY = "1000000000000000000000000";

const developmentChains = ["hardhat", "localhost"];

module.exports = {
  networkConfig,
  INITIAL_SUPPLY,
  developmentChains,
};
