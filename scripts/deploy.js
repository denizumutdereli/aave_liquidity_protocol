const hre = require("hardhat");

async function main() {
  const Market = await hre.ethers.getContractFactory("Market");
  /** @ref {Link}
   * https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses
   */
  const market = await Market.deploy("0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A");

  await market.waitForDeployment();

  const address = await market.getAddress();
  console.log(`Market Liquidity contrat deployed successfully to address ${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});