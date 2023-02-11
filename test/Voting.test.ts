import { expect, use } from 'chai';
import { Contract } from 'ethers';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';

import FuNFT from '../build/FuNFT.json';
import Voting from '../build/Voting.json';

use(solidity);

enum Status {
    PENDING,
    IN_PROGRESS,
    CLOSED,
};

describe('Voting', () => {
    const [
        wallet,
        walletTo,
        walletTo2,
    ] = new MockProvider().getWallets();
    let voting: Contract;

    beforeEach(async () => {
        const nftContract = await deployContract(wallet, FuNFT, []);
        voting = await deployContract(wallet, Voting, [nftContract.address]);
    });

    it('Can start standard yes/no polls', async () => {
        await voting.startPollYesNo("standard poll");
        const pollId = 0;
        expect(await voting.getStatus(pollId)).to.equal(Status.IN_PROGRESS);
        const results: [string, object][] = await voting.formattedResults(pollId);
        expect(results.map(r => r[0])).to.deep.equal(["Yes", "No"]);
    });

});
