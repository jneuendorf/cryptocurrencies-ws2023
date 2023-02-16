import { expect, use } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';

import FuNFT from '../build/FuNFT.json';
import FuVoteToken from '../build/FuVoteToken.json';
import Voting from '../build/Voting.json';

use(solidity);

enum Status { PENDING, IN_PROGRESS, CLOSED };

describe.only('Voting', () => {
    // TODO: Use fixtures: https://ethereum-waffle.readthedocs.io/en/latest/fixtures.html
    const [
        contractOwner,
        alice,
        bob,
    ] = new MockProvider().getWallets();
    let voting: Contract;
    let voteToken: Contract;
    let nft: Contract;

    beforeEach(async () => {
        nft = await deployContract(contractOwner, FuNFT, []);
        voteToken = await deployContract(contractOwner, FuVoteToken, [nft.address]);
        voting = await deployContract(contractOwner, Voting, [voteToken.address]);
    });

    it('Can start standard yes/no poll', async () => {
        await voting.startPollYesNo('standard poll');
        const pollId = 0;
        expect(await voting.getStatus(pollId)).to.equal(Status.IN_PROGRESS);
        const results: [string, object][] = await voting.formattedResults(pollId);
        expect(results.map(r => r[0])).to.deep.equal(['Yes', 'No']);
    });

    it.only('Can vote', async () => {
        // ALICE - NFT
        await nft.mintTo(1, false, alice.address);
        const aliceTokenId = 0;
        expect(await nft.ownerOf(aliceTokenId)).to.equal(alice.address);

        // ALICE - VOTE TOKEN
        const voteTokenAlice = voteToken.connect(alice);
        await voteTokenAlice.mint(aliceTokenId);
        expect(await voteToken.hasMinted(aliceTokenId)).to.equal(true);
        await expect(voteTokenAlice.mint(aliceTokenId)).to.be.revertedWith('Token has already been used');
        expect(await voteToken.balanceOf(alice.address)).to.equal(1);

        // BOB - NFT
        await nft.mintTo(2, false, bob.address);
        await nft.mintTo(3, true, bob.address);
        const bobTokens = [1, 2];
        expect(await nft.ownerOf(bobTokens[0])).to.equal(bob.address);
        expect(await nft.ownerOf(bobTokens[1])).to.equal(bob.address);

        // BOB - VOTE TOKEN
        const voteTokenBob = voteToken.connect(bob);
        await voteTokenBob.mint(bobTokens[0]);
        await voteTokenBob.mint(bobTokens[1]);
        expect(await voteToken.balanceOf(bob.address)).to.equal(3);

        // START POLL
        const pollId = 0;
        const pollDescription = 'coffee party';
        const allowMultipleOptions = true;
        const pollOptions = ['cake', 'muffins', 'cookies'];
        await voting.startPoll(pollDescription, allowMultipleOptions, pollOptions);

        // CAST VOTES - ALICE (1x CAKE)
        const votingAlice = voting.connect(alice);
        // unapproved vote should fail
        await expect(
            voting.castVote(pollId, pollOptions.indexOf('cake'), 1)
        ).to.be.revertedWith('Not enough vote tokens');
        await voteTokenAlice.increaseAllowance(voting.address, 2);
        await votingAlice.castVote(pollId, pollOptions.indexOf('cake'), 1);
        // even though the allowance is high enough, Alice has only 1 vote token
        await expect(
            votingAlice.castVote(pollId, pollOptions.indexOf('muffins'), 1)
        ).to.be.revertedWith('Not enough vote tokens');

        // CAST VOTES - BOB (1x CAKE, 1x MUFFINS, 1x COOKIES)
        const votingBob = voting.connect(alice);
        await voteTokenBob.increaseAllowance(voting.address, 3);
        await votingBob.castVote(pollId, pollOptions.indexOf('cake'), 1);
        await votingBob.castVote(pollId, pollOptions.indexOf('muffins'), 1);
        await votingBob.castVote(pollId, pollOptions.indexOf('cookies'), 1);

        // VOTERS SHOULD HAVE NO VOTE TOKENS ANYMORE
        // ...

        // END POLL
        await voting.endPoll(pollId);

        // VOTERS SHOULD HAVE THEIR VOTE TOKENS BACK
        // ...

        // VERIFY RESULTS
        expect(await voting.getResults(pollId)).to.deep.equal([
            BigNumber.from(2),
            BigNumber.from(1),
            BigNumber.from(1),
        ]);
    });
});
