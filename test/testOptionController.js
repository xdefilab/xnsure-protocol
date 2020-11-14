const { expectRevert, time } = require('@openzeppelin/test-helpers');
const MockERC20 = artifacts.require('MockToken');

const OptionController = artifacts.require('OptionController');

contract('OptionController', (accounts) => {
    
    before(async () => {
        this.controller = await OptionController.deployed();
        this.dai = await MockERC20.new('DAIToken', 'DAI', '900000000000000000000');

        await this.controller.setOptionRate(5);
        await this.controller.setUniswapOption("0x6AB5e06fA369Ad29deba6ff4E405e969763F9745");
    })

    it("test set params", async() => {
        let deadlines = [20000, 30000];
        let targets = [500, 600];
        
        await this.controller.setDeadline(deadlines);
        await this.controller.setTarget(targets);

        let readDeadlines = await this.controller.getDeadlines();
        let readTargets = await this.controller.getTargets();
        let readOptionRate = await this.controller.getOptionRate();
        let readUniswap = await this.controller.uniswapOption();

        console.log("deadlines: " + readDeadlines);
        console.log("targets: " + readTargets);
        console.log("optionRate: " + readOptionRate);
        console.log("uniswap: " + readUniswap);
    })

    it("test create option")

    it("test add liquidity")

    it('test swap (sell and buy option)')

    it('test owner exercise')

    it('test redeem')

});