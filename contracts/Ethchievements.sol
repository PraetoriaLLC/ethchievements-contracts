pragma solidity ^0.8.0;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Ethchievements is ERC721URIStorage, Ownable {

    string public base;
    uint256 public currentId;
    mapping(bytes32 => bool) alreadyMinted;

    constructor(string memory _base) ERC721("Ethchievements", "EMNT") {
        base = _base;
    }

    function mint(address _to, string memory _integration, string memory _task, bytes memory _sig) external {

        _verify(_to, _integration, _task, _sig);

        _mint(_to, currentId);
        string memory newTokenURI = string(abi.encodePacked(base, "/", _integration, "/", _task));
        _setTokenURI(currentId, newTokenURI);

        currentId++;
    }

    function _verify(address _to, string memory _integration, string memory _task, bytes memory _sig) internal {

        bytes32 messageHash = keccak256(abi.encodePacked(_to, _integration, _task));
        require(!alreadyMinted[messageHash], "already minted");
        alreadyMinted[messageHash] = true;

        address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(messageHash), _sig);
        require(signer == owner(), "invalid signature");
    }
}
