const OptionFunction = artifacts.require("OptionFunction");
const WETHToken = artifacts.require("MockToken");
const DAIToken = artifacts.require("MockToken");
const Storage = artifacts.require("Storage");

module.exports = async function (deployer, network) {
    await deployer.deploy(Storage);

    if (network === 'development') {
        await deployer.deploy(WETHToken, "WETHToken", "WETH", 18);
        await deployer.deploy(DAIToken, "DAIToken", "DAI", 18);

        await deployer.deploy(OptionFunction);
    }
};