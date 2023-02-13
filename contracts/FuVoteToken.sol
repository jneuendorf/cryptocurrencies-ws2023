// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


interface nftInterface {
    function isUpgrade(uint tokenId) external view returns(bool);
    function getLevel(uint tokenId) external view returns(uint8);
    function ownerOf(uint tokenId) external view returns(address);
    function totalSupply() external view returns(uint256);
}


contract FuVoteToken is ERC20("FuVoteToken", "FVT") {
    address private _contractOwner;
    address private _nftContractAddress;
    nftInterface private nftContract;

    // Checks if an NFT has already claimed
    mapping(uint256 => bool) private _minted;

    constructor(address nftContractAddress_) {
        _contractOwner = msg.sender;
        nftContract = nftInterface(nftContractAddress_);
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
        require(_nftToken < nftContract.totalSupply(), "NFT id does not exist");

        uint8 mintAmount;
        if (nftContract.isUpgrade(_nftToken)) {
            mintAmount = 1;
        }
        else {
            mintAmount = nftContract.getLevel(_nftToken);
        }
        _mint(msg.sender, mintAmount);
        _minted[_nftToken] = true;
    }

    function hasMinted(uint256 token) public view returns(bool) {
        return _minted[token];
    }
}
