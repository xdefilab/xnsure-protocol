const { expectRevert, time } = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');
const { assertion } = require('@openzeppelin/test-helpers/src/expectRevert');
const MockERC20 = artifacts.require('MockToken');

const OptionController = artifacts.require('OptionController');

contract('OptionController', (accounts) => {
    
    beforeEach(async () => {
        this.controller = await OptionController.deployed();
        this.dai = await MockERC20.new('DAIToken', 'DAI', '900000000000000000000');

        await this.controller.setUniswapOption("0x30Daa7e69d806125b50402DB6D7717b43e4591dd");
        await this.controller.setUnderlyingAsset(this.dai.address);

        let deadlines = [1605801600];
        let targets = [256,300,320,400,500,625];
        
        await this.controller.setDeadline(deadlines);
        await this.controller.setTarget(targets);
    })

    // it("test set params", async() => {
        
    //     await this.controller.setOptionAmountPerStrike(6);
        
    //     let readOptionRate = await this.controller.getOptionAmountPerStrike();

    //     console.log("optionRate: " + readOptionRate);

    // })

    it("test create option", async () => {
        await this.controller.createOption(1605801600, 500, {value: web3.utils.toWei('1')});
        
        let optionBalance = await this.controller.getOptionBalance(1605801600, 500, accounts[0]);

        console.log('option balance: ' + optionBalance);

        // assert(false, "")
    })

    // it("test add liquidity")

    // it('test swap (sell and buy option)')

    // it('test owner exercise')

    // it('test redeem')

});