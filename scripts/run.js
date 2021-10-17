const { utils } = require("ethers");

const main = async () => {

    const baseTokenURI = "ipfs://QmdLcq1UtFqmpkHYCTvvDxtv7TdWz7xPsDuw2QuLq6e4im"
    const [owner, randoPerson] = await hre.ethers.getSigners();
    const nftContractFactory = await hre.ethers.getContractFactory('RinkebySquirrels');
    const nftContract = await nftContractFactory.deploy(baseTokenURI);
    await nftContract.deployed();

    console.log("Contract deployed to: ", nftContract.address);
    console.log("Contract deployed by: ", owner.address);
    console.log("Random Person's address: ", randoPerson.address);

    let contractBalance;
    contractBalance = await hre.ethers.provider.getBalance(nftContract.address);
    console.log("Contract balance: ", hre.ethers.utils.formatEther(contractBalance));

    let ownerBalance;
    ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("Owner balance: ", hre.ethers.utils.formatEther(ownerBalance));

    let supply = await nftContract.totalSupply();
    console.log("The supply is", supply.toString());

    let txn = await nftContract.reserveSquirrels();
    await txn.wait()

    supply = await nftContract.totalSupply();
    console.log("The supply is", supply.toString());

    txn = await nftContract.setSaleState(true);
    await txn.wait();

    txn = await nftContract.connect(randoPerson).mintSquirrel(5, { value: utils.parseEther('0.05') });
    await txn.wait()

    supply = await nftContract.totalSupply();
    console.log("The supply is", supply.toString());

    contractBalance = await hre.ethers.provider.getBalance(nftContract.address);
    console.log("Contract balance: ", hre.ethers.utils.formatEther(contractBalance));

    ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("Owner balance: ", hre.ethers.utils.formatEther(ownerBalance));

    txn = await nftContract.withdraw();
    await txn.wait();

    ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("Owner balance: ", hre.ethers.utils.formatEther(ownerBalance));
};

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