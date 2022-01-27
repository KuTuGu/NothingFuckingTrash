const { ethers, upgrades } = require("hardhat");

(async () => {
  const nft = await ethers.getContractFactory("NothingFuckingTrash");
  const contract = await upgrades.deployProxy(nft, ["1.0.0"]);
  await contract.deployed();

  console.log('Deploy contract address at: ', contract?.address)
  console.log('Deploy txHash: ', contract?.deployTransaction?.hash)
})()