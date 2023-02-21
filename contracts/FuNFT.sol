// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract FuNFT is ERC721("FuNFT", "FUN") {
    address private _owner;
    uint256 private _totalSupply;

    struct TokenInfo {
        uint256 id;
        // implies number of voting tokens
        uint8 level;
        // implies number of votes: isUpgrade == false => votes == level, otherwise 1
        bool isUpgrade;
    }
    // access the token structs through this mapping
    mapping(uint256 => TokenInfo) private _infoByToken;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    /**
     * Let's the contract owner mint 1 new NFT token.
     */
    function mint(uint8 level, bool isUpgrade_) public onlyOwner returns(TokenInfo memory) {
        uint256 nextTokenId = _totalSupply;
        _mint(_owner, nextTokenId);
        // register metadata
        _infoByToken[nextTokenId] = TokenInfo(nextTokenId, level, isUpgrade_);
        _totalSupply += 1;

        return _infoByToken[nextTokenId];
    }

    function mintTo(uint8 level, bool isUpgrade_, address to) external onlyOwner returns(TokenInfo memory) {
        TokenInfo memory info = mint(level, isUpgrade_);
        _safeTransfer(_owner, to, info.id, "");

        return info;
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function tokenInfo(uint tokenId) public view returns(TokenInfo memory) {
        return _infoByToken[tokenId];
    }

    function getLevel(uint tokenId) public view returns(uint8) {
        return _infoByToken[tokenId].level;
    }

    function isUpgrade(uint tokenId) public view returns(bool) {
        return _infoByToken[tokenId].isUpgrade;
    }

    function ownedTokens(address owner_) public view returns(TokenInfo[] memory) {
        uint256 tokensFound = 0;
        uint256 balance = balanceOf(owner_);
        TokenInfo[] memory tokens = new TokenInfo[](balance);

        for(uint tokenId = 0; tokensFound < balance; tokenId++) {
            require(
                tokenId < _totalSupply,
                "Found less tokens than the owner has balance. This should never happen"
            );
            if (ownerOf(tokenId) == owner_) {
                tokens[tokensFound] = _infoByToken[tokenId];
                tokensFound++;
            }
        }
        return tokens;
    }
}
