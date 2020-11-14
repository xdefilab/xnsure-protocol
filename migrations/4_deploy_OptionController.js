const OptionController = artifacts.require("OptionController");
const UniswapAddress = "0x052a81080A155b1430B9d096DCA4f8a93f822b86";
const DaiAddress = "0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa";
const ETHAddress = "0x0000000000000000000000000000000000000000";


module.exports = async function (deployer, network) {
    await deployer.deploy(OptionController, UniswapAddress, ETHAddress, DaiAddress);
};