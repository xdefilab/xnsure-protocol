const { expectRevert, time } = require('@openzeppelin/test-helpers');
const MockERC20 = artifacts.require('MockToken');
const NsureCallToken = artifacts.require('NsureCallToken');

contract('NsureCallToken', ([alice, bob, carol, minter]) => {
    beforeEach(async () => {
        //1000
        this.weth = await MockERC20.new('WETHToken', 'WETH', '1000000000000000000000', { from: minter });
        await this.weth.transfer(alice, '300000000000000000000', { from: minter });

        //1000
        this.dai = await MockERC20.new('DAIToken', 'DAI', '900000000000000000000', { from: minter });
        await this.dai.transfer(bob, '300000000000000000000', { from: minter });
        await this.dai.transfer(carol, '300000000000000000000', { from: minter });
    });

    it('should get correct variables', async () => {
        this.option = await NsureCallToken.new("NsureCallToken", "CALL", minter, this.weth.address, 18, this.dai.address, 18, '1000000000000000000', 50);

        const decimals = await this.option.decimals();
        assert.equal(decimals.valueOf(), '18');

        //before expiration
        let expired = await this.option.hasExpired();
        assert.equal(expired, 0);

        //after expiration
        await time.advanceBlockTo('52');
        expired = await this.option.hasExpired();
        assert.equal(expired, 1);
    });


});