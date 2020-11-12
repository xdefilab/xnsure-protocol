const NsurePutToken = artifacts.require("NsurePutToken");
const WETHToken = artifacts.require("MockToken");
const USDCToken = artifacts.require("MockToken");
const Storage = artifacts.require("Storage");

module.exports = async function (deployer, network) {
    await deployer.deploy(Storage);

    if (network === 'development') {
        await deployer.deploy(WETHToken, "WETHToken", "WETH", 18);
        await deployer.deploy(USDCToken, "USDCToken", "USDC", 18);

        console.log("WETH Token:", WETHToken.address);
        console.log("USDC Token:", USDCToken.address);

        await deployer.deploy(NsurePutToken, 'NsurePutToken', 'PUT', WETHToken.address, 18, USDCToken.address, 18, 1, 100);
    }
};