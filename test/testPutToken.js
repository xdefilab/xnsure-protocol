const { expectRevert } = require('@openzeppelin/test-helpers');
const MockERC20 = artifacts.require('MockToken');
const NsurePutToken = artifacts.require('NsurePutToken');

contract('NsurePutToken', ([alice, bob, carol, minter]) => {
    beforeEach(async () => {
        //1000
        this.weth = await MockERC20.new('WETHToken', 'WETH', '1000000000000000000000', { from: minter });
        await this.weth.transfer(alice, '300000000000000000000', { from: minter });
        await this.weth.transfer(bob, '300000000000000000000', { from: minter });
        await this.weth.transfer(carol, '300000000000000000000', { from: minter });

        //1000
        this.usdc = await MockERC20.new('USDCToken', 'USDC', '900000000000000000000', { from: minter });
        await this.usdc.transfer(alice, '300000000000000000000', { from: minter });
        await this.usdc.transfer(bob, '300000000000000000000', { from: minter });
        await this.usdc.transfer(carol, '300000000000000000000', { from: minter });
    });

    it('should get correct variables', async () => {
        //expirationBlockNumber: 100
        this.option = await NsurePutToken.new("PUTToken", "PUT", this.weth.address, 18, this.usdc.address, 18, 1, 100, { from: minter })

        const decimals = await this.option.decimals();
        assert.equal(decimals.valueOf(), '18');
    });

    it('before PUT TOKEN expiration', async () => {
        const expired = await option.hasExpired();

    });
});