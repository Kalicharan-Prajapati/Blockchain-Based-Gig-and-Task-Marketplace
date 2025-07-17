const hre = require("hardhat");

async function main() {
  const DecentraJobs = await hre.ethers.getContractFactory("DecentraJobs");
  const jobs = await DecentraJobs.deploy();
  await jobs.deployed();

  console.log("DecentraJobs deployed to:", jobs.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
