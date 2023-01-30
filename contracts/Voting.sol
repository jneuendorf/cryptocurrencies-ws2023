// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// TODO: change token to the ERC20Token we use
import "../src/Coin.sol";

contract Voting {
    using Counters for Counters.Counter;

    // to vote transfer ERC20 token(s) to this address
    address owner;    

    Counters.Counter private _pollIdCounter;

    enum Status { PENDING, IN_PROGRESS, CLOSED }
    mapping(uint256 => Poll) polls;
    // TODO: change token to the ERC20Token we use
    Coin public token;

    struct Poll {
        string description;
        bool allowMultipleOptions;
        Status status;
        uint256 votingOptionsCount;
        mapping(uint256 => string) votingOptions;
        // votes saved in this structure: mapping(voterAddress => mapping(optionIndex => weight))
        mapping(address => mapping(uint256 => uint256)) votes;
        // index is votingOptionIndex
        Result[] results;
    }

    struct Result {
        string option;
        uint256 voteCount;
        address[] voters;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function startPoll(string memory _description, bool _allowMultipleOptions, string[] memory _options) public onlyOwner returns (uint256) {
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
        poll.results = new Result[](poll.votingOptionsCount);
        return pollId;
    }

    function startPoll(string memory _description, bool _allowMultipleOptions) external onlyOwner returns (uint256) {
        string[] memory options;
        options[0] = "Yes";
        options[1] = "No";
        return startPoll(_description, _allowMultipleOptions, options);
    }

    function endPoll(uint256 _pollID) external onlyOwner {
        Poll storage poll = polls[_pollID];
        poll.status = Status.CLOSED;
        returnCoinsAfterPoll(_pollID);
    }

    function castVote(uint256 _pollID, uint256 _optionIndex, uint256 weight) public {
        require(getStatus(_pollID) == Status.IN_PROGRESS, "Poll is not in progress!");
        require(weight > 0, "Cannot vote with 0 tokens!");
        address voter = msg.sender;
        // requires approval from the voter beforehand to transfer coins from his/her account to this contract owner address
        // to do that call the approve-method in the ERC20-Token before casting the vote
        token.transferFrom(voter, owner, weight);
        Poll storage poll = polls[_pollID];
        // add vote
        poll.votes[voter][_optionIndex] += weight;
        // update results
        if (poll.results[_optionIndex].voteCount == 0) {
            poll.results[_optionIndex].option = poll.votingOptions[_optionIndex];
            poll.results[_optionIndex].voteCount += weight;
            
            bool voterVotedBefore = false;
            for (uint i = 0; i < poll.results[_optionIndex].voters.length; i++) {
                if (poll.results[_optionIndex].voters[i] == voter) {
                    voterVotedBefore = true;
                }
            }
            if (!voterVotedBefore) {
                poll.results[_optionIndex].voters.push(voter);
            }
        }
    }

    function getStatus(uint256 _pollID) view public returns (Status) {
        return polls[_pollID].status;
    }

    function getResults(uint256 _pollID) view public returns (Result[] memory) {
        require(getStatus(_pollID) == Status.CLOSED, "Poll is not yet closed!");
        return polls[_pollID].results;
    }

    function returnCoinsAfterPoll(uint256 _pollID) internal onlyOwner {
        // return tokens to voters
    }
}