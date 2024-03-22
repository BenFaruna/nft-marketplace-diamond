// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibAppStorage.sol";

contract NFTMarketPlaceFacet {
    LibAppStorage.AppStorage internal s;

    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTSold(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 price
    );

    function getNftPrice(
        uint256 _tokenId
    ) public view returns (uint256 price_) {
        price_ = s.listings[_tokenId];
    }

    function listNft(uint256 _tokenId, uint256 _price) public {
        require(s.owners[_tokenId] == msg.sender, "not owner");
        require(_price > 0, "price is 0");
        s.listings[_tokenId] = _price;
        emit NFTListed(_tokenId, _price);
    }

    function buyNft(uint256 _tokenId) public payable {
        require(s.listings[_tokenId] > 0, "not listed");
        require(msg.value >= s.listings[_tokenId], "wrong price");

        uint256 price = s.listings[_tokenId];
        uint256 _refund;

        address owner = s.owners[_tokenId];

        s.tokenApprovals[_tokenId] = msg.sender;
        LibAppStorage._transferFrom(owner, msg.sender, _tokenId);

        emit NFTSold(msg.sender, _tokenId, msg.value);

        if (msg.value > price) {
            _refund = msg.value - price;
            payable(msg.sender).transfer(_refund);
        }
    }
}
