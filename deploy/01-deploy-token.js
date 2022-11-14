const { network } = require("hardhat");
const { verify } = require("../utils/verify");
const {
  developmentChains,
  INITIAL_SUPPLY,
} = require("../helper-hardhat-config");

module.exports = async (hre) => {
  const { getNamedAccounts, deployments } = hre;
  const { log, deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // deploy the contract
  const ourTokenC = await deploy("TokenContract", {
    contract: "OurToken",
    from: deployer,
    args: [INITIAL_SUPPLY],
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  // Verify contract if on testnet
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log("Verifying the contract on etherscan ...");
    await verify(ourTokenC.address, [INITIAL_SUPPLY]);
    log(">>> Verified on Etherscan <<<");
    log("-----------------------------------------------------");
  }
};

module.exports.tags = ["all", "token"];
