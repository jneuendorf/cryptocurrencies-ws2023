// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


interface VoteTokenInterface {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


contract Voting {
    using Counters for Counters.Counter;

    Counters.Counter private _pollIdCounter;
    // to vote transfer ERC20 token(s) to this address
    address owner;

    enum Status { PENDING, IN_PROGRESS, CLOSED }
    mapping(uint256 => Poll) polls;
    VoteTokenInterface private _voteToken;

    struct Poll {
        string description;
        bool allowMultipleOptions;
        Status status;
        uint256 votingOptionsCount;
        mapping(uint256 => string) votingOptions;
        // votes saved in this structure: mapping(voterAddress => mapping(optionIndex => weight))
        mapping(address => mapping(uint256 => uint256)) votes;
        // save all voted addresses
        address[] voters;
        // maps all addresses to the total amount of votes
        mapping(address => uint256) addressToTotalVotes;
    }

    struct FormattedResult {
        string votingOption;
        uint256 amountVotes;
    }

    constructor(address voteTokenContractAddress) {
        owner = msg.sender;
        _voteToken = VoteTokenInterface(voteTokenContractAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function startPoll(
        string memory _description,
        bool _allowMultipleOptions,
        string[] memory _options
    ) public onlyOwner returns (uint256) {
        uint256 pollId = _pollIdCounter.current();
        _pollIdCounter.increment();
        Poll storage poll = polls[pollId];
        poll.description = _description;
        poll.allowMultipleOptions = _allowMultipleOptions;
        poll.status = Status.IN_PROGRESS;
        for (uint i = 0; i < _options.length; i++) {
            poll.votingOptions[i] = _options[i];
        }
        poll.votingOptionsCount = _options.length;
        poll.voters = new address[](0);
        return pollId;
    }

    function startPollYesNo(string memory _description) external onlyOwner returns (uint256) {
        bool allowMultipleOptions = false;
        string[] memory options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
        return startPoll(_description, allowMultipleOptions, options);
    }

    function endPoll(uint256 _pollID) external onlyOwner {
        require(
            getStatus(_pollID) == Status.IN_PROGRESS
            || _pollID < _pollIdCounter.current(),
            "Poll is not in progress or pollID does not exist"
        );
        Poll storage poll = polls[_pollID];
        poll.status = Status.CLOSED;
        returnCoinsAfterPoll(_pollID);
    }

    /**
     * Requires approval from the voter beforehand to transfer coins from his/her account to this contract owner address.
     * To do that call the approve-method in the ERC20-Token before casting the vote.
     */
    function castVote(uint256 _pollID, uint256 _optionIndex, uint256 weight) public {
        address voter = msg.sender;
        Poll storage poll = polls[_pollID];

        require(getStatus(_pollID) == Status.IN_PROGRESS,  "Poll is not in progress");
        require(_pollID < _pollIdCounter.current(), "Poll does not exist");
        // check if msg.sender has the required balance to vote their desired weight
        require(_voteToken.balanceOf(voter) >= weight, "Not enough vote tokens");
        require(weight > 0, "Cannot vote with 0 tokens!");
        // check if the poll allows multiple options and then if the voter has already voted
        require(
            poll.allowMultipleOptions
            || poll.addressToTotalVotes[voter] == 0,
            "You can only vote once when allowMultipleOptions is set to false"
        );
        require(poll.votingOptionsCount > _optionIndex, "The optionIndex is higher than the amount of options");

        _voteToken.transferFrom(voter, owner, weight);
        // add vote
        poll.votes[voter][_optionIndex] += weight;
        // if address has not voted before, push to list of voters
        if (poll.addressToTotalVotes[voter] == 0) {
            poll.voters.push(voter);
        }
        // update total vote acount
        poll.addressToTotalVotes[voter] += weight;
    }

    function getStatus(uint256 _pollID) view public returns (Status) {
        return polls[_pollID].status;
    }

    function getResults(uint256 _pollID) view public returns(uint256[] memory){
        Poll storage poll = polls[_pollID];
        uint256[] memory result = new uint256[](poll.votingOptionsCount);

        // iterate through the voting options
        for(uint256 votingOptionIndex; votingOptionIndex < poll.votingOptionsCount; votingOptionIndex++) {
            uint256 amountVotes;
            // iterate through the votes everyone has sent
            for(uint voter = 0; voter < poll.voters.length; voter++) {
                address voterAddress = poll.voters[voter];
                // add votes for that voting option to the votes counter
                amountVotes += poll.votes[voterAddress][votingOptionIndex];
            }
            // put the result into the voting result-array
            result[votingOptionIndex] = amountVotes;
        }
        return result;
    }

    function formattedResults(uint256 _pollID) view public returns(FormattedResult[] memory) {
        Poll storage poll = polls[_pollID];
        uint256[] memory results = getResults(_pollID);
        FormattedResult[] memory formattedResult = new FormattedResult[](poll.votingOptionsCount);

        for(uint256 i = 0; i < poll.votingOptionsCount; i++) {
            formattedResult[i] = FormattedResult(poll.votingOptions[i], results[i]);
        }
        return formattedResult;
    }

    function returnCoinsAfterPoll(uint256 _pollID) internal onlyOwner {
        Poll storage poll = polls[_pollID];
        require(
            poll.status == Status.CLOSED,
            "Poll must be closed for coins to be returned"
        );
        for (uint256 i = 0; i < poll.voters.length; i++) {
            address recipient = poll.voters[i];
            // transfer back funds
            _voteToken.transferFrom(owner, recipient, poll.addressToTotalVotes[recipient]);
            // reset total votes for that address
            poll.addressToTotalVotes[recipient] = 0;
        }
    }
}
