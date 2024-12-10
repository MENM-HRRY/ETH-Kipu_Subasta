// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract AuctionNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    constructor(address initialOwner) ERC721("AuctionNFT", "ANFT") Ownable(initialOwner) {
        tokenCounter = 0;
    }

    function mintNFT(address recipient) public onlyOwner returns (uint256) {
        require(recipient != address(0), "Cannot mint to zero address");

        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);
        tokenCounter++;

        return newTokenId;
    }

    // Función para obtener un array con los IDs de los NFTs creados
    function getAllTokenIds() public view returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](tokenCounter);
        for (uint256 i = 0; i < tokenCounter; i++) {
            tokenIds[i] = i;
        }
        return tokenIds;
    }
}