const { utils } = require("ethers");

const main = async () => {

    const baseTokenURI = "ipfs://QmdLcq1UtFqmpkHYCTvvDxtv7TdWz7xPsDuw2QuLq6e4im/"
    const [owner] = await hre.ethers.getSigners();
    const nftContractFactory = await hre.ethers.getContractFactory('RinkebySquirrels');
    const nftContract = await nftContractFactory.deploy(baseTokenURI);
    await nftContract.deployed();

    console.log("Contract deployed to: ", nftContract.address);
    console.log("Contract deployed by: ", owner.address);

    let supply = await nftContract.totalSupply();
    console.log("The supply is", supply.toString());

    let txn = await nftContract.reserveSquirrels();
    await txn.wait()

    supply = await nftContract.totalSupply();
    console.log("The supply is", supply.toString());

    txn = await nftContract.setSaleState(true);
    await txn.wait();
};

// Test Contract address: 0x94d8299c7FFfe2D7432Ff4767940a2f7CA74D063
// Final Contract address: 0x29F6D2381f82E6d52ad54f403DAff421Fdb3BdA2

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    }
    catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();