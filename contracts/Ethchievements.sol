// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title   Ethchievements
 * @author  Noah Citron
 * @dev     ERC721 contract that permissions minting to require a valid signature from the contract owner.
 *          The tokenURI has also been modified to resolve to baseUrl/integration/task which the Ethchievements
 *          backend will use as a path to store the appropriate NFT image
 */
contract Ethchievements is ERC721URIStorage, Ownable {

    string public base;
    uint256 public currentId;
    mapping(bytes32 => bool) alreadyMinted;

    /**
     * Sets the state variables
     *
     * @param _base the base url of the NFT
     */
    constructor(string memory _base) ERC721("Ethchievements", "EMNT") {
        base = _base;
    }

    /**
     * Mints a new Ethchievement NFT. In order to mint, must provide a valid singature of the keccak hash of 
     * the minter, integration, and task. This message should be formatted as if it were produced by the eth_signMessage
     * RPC call. Replay attacks are prevented by disallowing multiple mints with the same minter, integration, task
     * combination.
     *
     * @param _to           the recipient of the NFT
     * @param _integration  the integration name for the Ethchievement
     * @param _task         the task name for the Ethchievement
     * @param _sig          the eth signed message by the owner of keccak(_to + _integration + _task)
     */
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
