import { expect, use } from 'chai';
import { Contract } from 'ethers';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';

import FuNFT from '../build/FuNFT.json';

use(solidity);

describe('FuNFT', () => {
    const [wallet, walletTo] = new MockProvider().getWallets();
    let token: Contract;

    beforeEach(async () => {
        token = await deployContract(wallet, FuNFT, []);
    });

    it('Assigns initial values', async () => {
        expect(await token.name()).to.equal('FuNFT');
        expect(await token.symbol()).to.equal('FUN');
        expect(await token.balanceOf(wallet.address)).to.equal(0);
    });

    it.only('Can be minted', async () => {
        const level = 1;
        const isUpgrade = false;
        await token.mint(level, isUpgrade);
    });

    it.only('Correctly outputs total supply and owned tokens after minting', async () => {
        const level = 1;
        const isUpgrade = false;
        await token.mint(level, isUpgrade);
        await token.mintTo(level, isUpgrade, walletTo.address);
        expect(await token.totalSupply()).to.equal(2);
        expect(await token.ownedTokens(walletTo.address)).to.have.length(1);
    });

    it.only('Correctly outputs token info', async () => {
        const level = 1;
        const isUpgrade = false;
        await token.mint(level, isUpgrade);
        // TODO: the returned TokenInfo cannot be accessed unfortunenately
        expect(await token.getLevel(0)).to.equal(level);
        expect(await token.isUpgrade(0)).to.equal(isUpgrade);
    });

    // TODO:
    // - isUpgrade = True
    // - multiple Levels
});
