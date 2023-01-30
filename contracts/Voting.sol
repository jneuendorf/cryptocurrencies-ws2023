// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Voting {
    using Counters for Counters.Counter;

    // to vote transfer ERC20 token(s) to this address
    address owner;    

    Counters.Counter private _pollIdCounter;

    enum Status { PENDING, IN_PROGRESS, CLOSED }
    mapping(uint256 => Poll) polls;

    struct Poll
    {
        string description;
        bool allowMultipleOptions;
        Status status;
        mapping(uint256 => string) votingOptions;
        // mapping(voterAddress => mapping(optionIndex => weight))
        mapping(address => mapping(uint256 => uint256)) votes;
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
        return pollId;
    }

    function startPoll(string memory _description, bool _allowMultipleOptions) external onlyOwner returns (uint256) {
        string[] memory options;
        options[0] = "Yes";
        options[1] = "No";
        return startPoll(_description, _allowMultipleOptions, options);
    }    

    function endPoll(uint256 _pollID) external onlyOwner {

    }
}