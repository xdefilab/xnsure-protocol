const { expectRevert, time } = require('@openzeppelin/test-helpers');
const MockERC20 = artifacts.require('MockToken');
const NsurePutToken = artifacts.require('NsurePutToken');

contract('NsurePutToken', ([alice, bob, carol, minter]) => {
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
        //expirationBlockNumber: 50
        this.option = await NsurePutToken.new("PUTToken", "PUT", this.weth.address, 18, this.dai.address, 18, '1000000000000000000', 50, { from: minter })

        const decimals = await this.option.decimals();
        assert.equal(decimals.valueOf(), '18');

        //before expiration
        let expired = await this.option.hasExpired();
        assert.equal(expired, false);

        //after expiration
        await time.advanceBlockTo('52');
        expired = await this.option.hasExpired();
        assert.equal(expired, true);
    });

    it('should mint options by locking strike tokens', async () => {
        //expirationBlockNumber: 70
        this.option = await NsurePutToken.new("PUTToken", "PUT", this.weth.address, 18, this.dai.address, 18, '1000000000000000000', 70, { from: minter })

        //not have strike tokens
        await expectRevert(
            this.option.mint('1', { from: alice }), 'ERC20: transfer amount exceeds balance.'
        );

        //not approved to spend
        await expectRevert(
            this.option.mint('1', { from: bob }), 'ERC20: transfer amount exceeds allowance.'
        );

        await this.dai.approve(this.option.address, '300000000000000000000', { from: bob });

        //should mint 1 PUT TOKEN
        await this.option.mint('1', { from: bob });

        //check balance
        assert.equal((await this.weth.balanceOf(this.option.address)).toString(), '0');

        //bob should have 1 PUT TOKEN
        assert.equal((await this.option.balanceOf(bob)).toString(), '1000000000000000000');
        assert.equal((await this.dai.balanceOf(bob)).toString(), '299000000000000000000');

        //dai balance
        assert.equal((await this.option.strikeBalance()).toString(), '1000000000000000000');
    });

    // it('should burn options by PUT TOKEN minter', async () => {
    //     //expirationBlockNumber: 90
    //     this.option = await NsurePutToken.new("PUTToken", "PUT", this.weth.address, 18, this.dai.address, 18, '1000000000000000000', 90, { from: minter })

    //     await this.dai.approve(this.option.address, '300000000000000000000', { from: bob });
    //     await this.dai.approve(this.option.address, '300000000000000000000', { from: carol });

    //     //should mint 1 PUT TOKEN
    //     await this.option.mint('1', { from: bob });

    //     await this.option.burn('1', { from: bob });
    //     assert.equal((await this.dai.balanceOf(bob)).toString(), '300000000000000000000');

    //     //only minter could burn
    //     await this.option.mint('1', { from: carol });
    //     await this.option.transfer(bob, '1000000000000000000', { from: carol });
    //     await expectRevert(this.option.burn('1', { from: bob }),
    //         'ERROR: minter amount not enough');
    // });

    it('should exercise for strike asset by selling underlying asset', async () => {
        await time.advanceBlockTo('100');

        //expirationBlockNumber: 120
        this.option = await NsurePutToken.new("PUTToken", "PUT", this.weth.address, 18, this.dai.address, 18, '1000000000000000000', 90, { from: minter })

        await this.dai.approve(this.option.address, '300000000000000000000', { from: bob });
        await this.weth.approve(this.option.address, '300000000000000000000', { from: alice });

        //should mint 1 PUT TOKEN
        await this.option.mint('1', { from: bob });
        await this.option.transfer(carol, '1000000000000000000', { from: bob });

        await this.option.exercise('1', { from: carol });
    });
});