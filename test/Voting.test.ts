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
    const [
        wallet,
        walletTo,
        walletTo2,
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
        await nft.mintTo(1, false, walletTo.address);
        await voteToken.mint(0);
        expect(await voteToken.hasMinted(0)).to.equal(true);

        // await nft.mintTo(2, false, walletTo2.address);
        // await voteToken.mint(1);

        await voteToken.approve(voting.address, 3);

        // await nft.approve(voting.address, 1);
        // await nft.approve(voting.address, 2);

        await voting.startPollYesNo('poll');
        const pollId = 0;
        await voting.castVote(pollId, 0, 1);
    });

});
