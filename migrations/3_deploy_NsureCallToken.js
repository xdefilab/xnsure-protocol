const NsureCallToken = artifacts.require("NsureCallToken");
const WETHToken = artifacts.require("MockToken");
const DAIToken = artifacts.require("MockToken");
const Storage = artifacts.require("Storage");

var XCORE_KOVAN = "0x7042758327753f684568528d5eAb0CD2839c6698";
module.exports = async function (deployer, network) {
    await deployer.deploy(Storage);

    if (network === 'development') {
        await deployer.deploy(WETHToken, "WETHToken", "WETH", 18);
        await deployer.deploy(DAIToken, "DAIToken", "DAI", 18);

        // "NsureCallToken",
        //     "CALL",
        //     address(this),
        //     underlyingAsset,
        //     18,
        //     strikeAsset,
        //     18,
        //     _target,
        //     _deadline

        await deployer.deploy(NsureCallToken, "NsureCallToken", "CALL", XCORE_KOVAN, WETHToken.address, 18, DAIToken.address, 18, "100", "100");
    }
};