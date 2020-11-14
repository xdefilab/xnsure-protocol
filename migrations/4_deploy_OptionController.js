const OptionController = artifacts.require("OptionController");
const UniswapAddress = "0x0000000000000000000000000000000000000000";


module.exports = async function (deployer, network) {
    await deployer.deploy(OptionController, UniswapAddress);
};