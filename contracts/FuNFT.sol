// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FuNFT is ERC721 {
    address private _owner;
    uint256 private _totalSupply;

    // _balances
    // ~> mapping(address => uint256) balance;

    // _owners
    // ~> mapping(uint256 => address) tokenToOwner;

    // _tokenApprovals
    // ~> mapping(uint256 => address) tokenApprovals;

    // _operatorApprovals
    // ~> mapping to operator approvals
    //    mapping(address => mapping(address => bool)) operatorApprovals;

    struct TokenInfo {
        uint256 id;
        // implies number of voting tokens
        uint8 level;
        // implies number of votes: isUpgrade == false => votes == level, otherwise n + 1
        bool isUpgrade;
    }
    // access the token structs through this mapping
    mapping(uint256 => TokenInfo) private _infoByToken;    


    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    // TODO: I think, we don't need this
    // modifier onlyOwnerOrApproved(uint256 tokenId) {
    //     address owner = ownerOf(tokenId);
    //     // require(
    //     //     (
    //     //         owner == msg.sender
    //     //         || getApproved(tokenId) == msg.sender
    //     //         || isApprovedForAll(owner, msg.sender)
    //     //     ),
    //     //     "You need to be approved or owner"
    //     // );
    //     require(
    //         _isApprovedOrOwner(owner, tokenId),
    //         "You need to be approved or owner"
    //     );
    //     _;
    // }

    /**
     * Let's the contract owner mint 1 new NFT token.
     */
    function mint(uint8 level, bool isUpgrade) external onlyOwner {
        uint256 nextTokenId = _totalSupply;
        _mint(_owner, nextTokenId);
        // register metadata
        _infoByToken[nextTokenId] = TokenInfo(nextTokenId, level, isUpgrade);
        _totalSupply += 1;
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function tokenInfo(uint tokenId) public view returns(TokenInfo memory) {
        return _infoByToken[tokenId];
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
