// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface nftInterface {
    function isUpgrade(uint tokenId) external view returns(bool);
    function getLevel(uint tokenId) external view returns(uint8);
    function ownerOf(uint tokenId) external view returns(address);
}

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FuVoteToken is ERC20("FuVoteToken", "FVT") {
    address private _contractOwner;
    string private _name = "FuVoteToken";
    string private _symbol = "FVT";

    address private _nftContractAddress;
    nftInterface private nftContract;

    // Checks if an NFT has already claimed
    mapping(uint256 => bool) private _minted;

    constructor(address nftContractAddress_) {
        _contractOwner = msg.sender;
        nftContract = nftInterface(nftContractAddress_);
    }

    function name() public view  override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function transferOwnership(address _to) public {
        require(msg.sender == _contractOwner, "Only the contract owner can do this");
        _contractOwner = _to;
    }

    function changeNftContractAddress(address _address) public {
        require(msg.sender == _contractOwner, "Only the contract owner can do this");
        _nftContractAddress = _address;
        nftContract = nftInterface(_address);
    }

    function mint(uint256 _nftToken) public {
        require(msg.sender == nftContract.ownerOf(_nftToken), "You don't own this token");
        require(!hasMinted(_nftToken), "Token has already been used");
        uint8 mintAmount;
        if (nftContract.isUpgrade(_nftToken)) {
            mintAmount = 1;
        } else {
            mintAmount = nftContract.getLevel(_nftToken);
        }
        _mint(msg.sender, mintAmount);
        _minted[_nftToken] = true;
    }

    function hasMinted(uint256 token) public view returns(bool) {
        return _minted[token];
    }
}

