import { expect, use } from 'chai';
import { Contract } from 'ethers';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';

import FuNFT from '../build/FuNFT.json';
import FuVoteToken from '../build/FuVoteToken.json';
import Voting from '../build/Voting.json';

use(solidity);

enum Status {
    PENDING,
    IN_PROGRESS,
    CLOSED,
};

describe.only('Voting', () => {
    // TODO: Use fixtures: https://ethereum-waffle.readthedocs.io/en/latest/fixtures.html
    const [
        wallet,
        wallet2,
        wallet3,
    ] = new MockProvider().getWallets();
    let voting: Contract;
    let voteToken: Contract;
    let nft: Contract;

    beforeEach(async () => {
        nft = await deployContract(wallet, FuNFT, []);
        voteToken = await deployContract(wallet, FuVoteToken, [nft.address]);
        voting = await deployContract(wallet, Voting, [voteToken.address]);
    });

    it('Can start standard yes/no poll', async () => {
        await voting.startPollYesNo('standard poll');
        const pollId = 0;
        expect(await voting.getStatus(pollId)).to.equal(Status.IN_PROGRESS);
        const results: [string, object][] = await voting.formattedResults(pollId);
        expect(results.map(r => r[0])).to.deep.equal(['Yes', 'No']);
    });

    it('Can start poll', async () => {
        await voting.startPoll('poll', false, ['one', 'two', 'three']);
        const pollId = 0;
        expect(await voting.getStatus(pollId)).to.equal(Status.IN_PROGRESS);
        const results: [string, object][] = await voting.formattedResults(pollId);
        expect(results.map(r => r[0])).to.deep.equal(['one', 'two', 'three']);
    });

    it.only('Can vote', async () => {
        // WALLET 2 - NFT
        await nft.mintTo(1, false, wallet2.address);
        const wallet2TokenId = 0;
        expect(await nft.ownerOf(wallet2TokenId)).to.equal(wallet2.address);

        // WALLET 2 - VOTE TOKEN
        const voteTokenWallet2 = voteToken.connect(wallet2);
        await voteTokenWallet2.mint(wallet2TokenId);
        expect(await voteToken.hasMinted(wallet2TokenId)).to.equal(true);
        await expect(voteTokenWallet2.mint(wallet2TokenId)).to.be.revertedWith('Token has already been used');
        expect(await voteToken.balanceOf(wallet2.address)).to.equal(1);

        // WALLET 3 - NFT
        await nft.mintTo(2, false, wallet3.address);
        await nft.mintTo(3, true, wallet3.address);
        const wallet3Tokens = [1, 2];
        expect(await nft.ownerOf(wallet3Tokens[0])).to.equal(wallet3.address);
        expect(await nft.ownerOf(wallet3Tokens[1])).to.equal(wallet3.address);

        // WALLET 3 - VOTE TOKEN
        const voteTokenWallet3 = voteToken.connect(wallet3);
        await voteTokenWallet3.mint(wallet3Tokens[0]);
        await voteTokenWallet3.mint(wallet3Tokens[1]);
        expect(await voteToken.balanceOf(wallet3.address)).to.equal(3);

        // APPROVAL
        // await voteToken.approve(voting.address, 3);
        // await nft.approve(voting.address, 1);
        // await nft.approve(voting.address, 2);

        // START POLL
        // await voting.startPollYesNo('poll');
        // const pollId = 0;

        // CAST VOTES
        // await voting.castVote(pollId, 0, 1);

        // END POLL

    });

});
