const NsurePutToken = artifacts.require("NsurePutToken");
const WETHToken = artifacts.require("MockToken");
const DAIToken = artifacts.require("MockToken");
const Storage = artifacts.require("Storage");

module.exports = async function (deployer, network) {
    await deployer.deploy(Storage);

    if (network === 'development') {
        await deployer.deploy(WETHToken, "WETHToken", "WETH", 18);
        await deployer.deploy(DAIToken, "DAIToken", "DAI", 18);

        console.log("WETH Token:", WETHToken.address);
        console.log("DAI Token:", DAIToken.address);

        await deployer.deploy(NsurePutToken, 'NsurePutToken', 'PUT', WETHToken.address, 18, DAIToken.address, 18, '1000000000000000000', 100);
    }
};