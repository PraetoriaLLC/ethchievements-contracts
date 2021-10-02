pragma solidity ^0.8.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Ethchievements is ERC721URIStorage {

    string public base;
    uint256 public currentId;

    constructor(string memory _base) ERC721("Ethchievements", "EMNT") {
        base = _base;
    }

    function mint(address _to, string memory _integration, string memory _task) external {

        _mint(_to, currentId);
        string memory newTokenURI = string(abi.encodePacked(base, "/", _integration, "/", _task));
        _setTokenURI(currentId, newTokenURI);

        currentId++;
    }
}