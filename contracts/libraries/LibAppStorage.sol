// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibAppStorage {
    struct AppStorage {
        mapping(uint256 tokenId => address) owners;
        mapping(address owner => uint256) balances;
        mapping(uint256 tokenId => address) tokenApprovals;
        mapping(uint256 tokenId => uint256) listings;
        mapping(uint256 tokenId => string) tokenURI;
    }

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        _transfer(_from, _to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        LibAppStorage.AppStorage storage s = getStorage();
        require(
            _from != address(0),
            "ERC721: transfer of token that is not own"
        );
        require(_to != address(0), "ERC721: transfer to the zero address");
        require(
            s.owners[_tokenId] == msg.sender ||
                s.tokenApprovals[_tokenId] == msg.sender,
            "ERC721: transfer caller is not owner nor approved"
        );
        require(
            s.owners[_tokenId] == _from,
            "ERC721: transfer of token that is not own"
        );
        s.tokenApprovals[_tokenId] = address(0);
        s.owners[_tokenId] = _to;
        s.balances[_from]--;
        s.balances[_to]++;
        emit Transfer(_from, _to, _tokenId);
    }

    function getStorage() internal pure returns (AppStorage storage l) {
        assembly {
            l.slot := 0
        }
    }
}
