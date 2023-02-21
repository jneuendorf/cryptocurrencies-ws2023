import { expect, use } from 'chai';
import { Contract } from 'ethers';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';

import FuNFT from '../build/FuNFT.json';

use(solidity);

describe('FuNFT', () => {
    const [
        wallet,
        walletTo,
        walletTo2,
    ] = new MockProvider().getWallets();
    let token: Contract;

    beforeEach(async () => {
        token = await deployContract(wallet, FuNFT, []);
    });

    it('Assigns initial values', async () => {
        expect(await token.name()).to.equal('FuNFT');
        expect(await token.symbol()).to.equal('FUN');
        expect(await token.balanceOf(wallet.address)).to.equal(0);
    });

    it('Can be minted', async () => {
        const level = 1;
        const isUpgrade = false;
        await token.mint(level, isUpgrade);
    });

    it('Correctly outputs total supply and owned tokens after minting', async () => {
        const level = 1;
        const isUpgrade = false;
        await token.mint(level, isUpgrade);
        await token.mintTo(level, isUpgrade, walletTo.address);
        expect(await token.totalSupply()).to.equal(2);
        expect(await token.ownedTokens(walletTo.address)).to.have.length(1);
    });

    describe('Minting', () => {
        it('Can be minted with level == 1', async () => {
            const level = 1;
            const isUpgrade = false;
            await token.mint(level, isUpgrade);
            // TODO: the returned TokenInfo cannot be accessed unfortunenately
            expect(await token.getLevel(0)).to.equal(level);
            expect(await token.isUpgrade(0)).to.equal(isUpgrade);
        });

        it('Can be minted with level > 1', async () => {
            const level = 3;
            const isUpgrade = false;
            await token.mint(level, isUpgrade);
            expect(await token.getLevel(0)).to.equal(level);
            expect(await token.isUpgrade(0)).to.equal(isUpgrade);
        });

        it('Can be minted with level > 1 && isUpgrade', async () => {
            const level = 3;
            const isUpgrade = true;
            await token.mint(level, isUpgrade);
            expect(await token.getLevel(0)).to.equal(level);
            expect(await token.isUpgrade(0)).to.equal(isUpgrade);
        });

        it('Can be minted multiple times', async () => {
            const level = 3;
            const isUpgrade = true;
            await token.mint(level, isUpgrade);
            await token.mint(level, isUpgrade);
            expect(await token.totalSupply()).to.equal(2);
        });

        it('Can be minted multiple times to different recipients', async () => {
            await token.mintTo(2, false, walletTo.address);
            await token.mintTo(1, true, walletTo2.address);
            await token.mintTo(2, true, walletTo2.address);

            expect(await token.totalSupply()).to.equal(3);

            expect(await token.balanceOf(wallet.address)).to.equal(0);
            expect(await token.balanceOf(walletTo.address)).to.equal(1);
            expect(await token.balanceOf(walletTo2.address)).to.equal(2);

            expect(await token.ownedTokens(wallet.address)).to.have.length(0);
            expect(await token.ownedTokens(walletTo.address)).to.have.length(1);
            expect(await token.ownedTokens(walletTo2.address)).to.have.length(2);
        });
    });

    it.skip('Requires approval before letting others transfer tokens', () => {
        // TODO: ?
    });

    // TODO:
    // - isUpgrade = True
    // - multiple Levels
});
