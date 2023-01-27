// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FuToken {

    // create a struct that then can be accessed by the tokenId
    struct Token {
        uint256 id;
        uint8 level;
        bool isUpgrade;
    }

    address owner;
    uint256 totalSupply;
    mapping(address => uint256) balance;
    mapping(uint256 => address) tokenToOwner;
    mapping(uint256 => address) tokenApprovals;

    // mapping to operator approvals
    mapping(address => mapping(address => bool)) operatorApprovals;

    // access the token structs through this mapping
    mapping(uint256 => Token) tokenToInfo;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrApproved(uint256 _tokenId) {
        require(
        tokenToOwner[_tokenId] == msg.sender || 
        tokenApprovals[_tokenId] == msg.sender ||
        isApprovedForAll(tokenToOwner[_tokenId], msg.sender), 
        "You need to be approved or owner"
        );
        _;
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return balance[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns(address) {
        return tokenToOwner[_tokenId];
    }
    
    
    function mint(uint8 _level, bool _isUpgrade) external onlyOwner {
        uint256 newTokenId = totalSupply;
        tokenToOwner[newTokenId] = msg.sender;
        // add TokenInfo to the token
        tokenToInfo[newTokenId] = Token(newTokenId, _level, _isUpgrade);
        balance[msg.sender]++;
        totalSupply += 1;
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOrApproved(_tokenId) {
        tokenApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns(address) {
        return tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        require(msg.sender != _operator);
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns(bool) {
        return operatorApprovals[_owner][_operator];
    }

    function transfer(address _to, uint256 _tokenId) public {
        transferFrom(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public onlyOwnerOrApproved(_tokenId) {
        balance[_from]--;
        balance[_to]++;
        tokenToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    
    function getTokenInfo(uint _tokenId) public view returns(Token memory) {
        return tokenToInfo[_tokenId];
    }

    function getOwnedTokens(address _owner) public view returns(Token[] memory) {
        uint256 tokenFound = 0;
        Token[] memory tokens = new Token[](balance[_owner]);

        for(uint i = 0; tokenFound < balance[_owner]; i++) {
            if (tokenToOwner[i] == _owner) {
                tokens[tokenFound] = tokenToInfo[i];
                tokenFound++;
            }
        }
        return tokens;
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    // We are not implementing this to the necessary extend
    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory data) public {
        transferFrom(_from, _to, _tokenId);
    }
}