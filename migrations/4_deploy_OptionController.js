const OptionController = artifacts.require("OptionController");
const UniswapAddress = "0x3960E9916Efe519fB936D04BaAbE54d5a8280Da4";


module.exports = async function (deployer, network) {
    await deployer.deploy(OptionController, UniswapAddress);
};