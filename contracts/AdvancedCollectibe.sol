// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {

  uint256 public tokenCounter;
  bytes32 public keyhash;
  uint256 public fee;
  enum Breed {PUG, SHIBA_INU, SET_BERNARD}
  mapping(uint256 => Breed) public tokenIdToBreed;
  mapping(bytes32 => address) public requestIdToSender;
  mapping(bytes32 => uint256) public requestIdToTokenId;

  event requestedCollectible(bytes32 requestId, address requester);
  event breedAssigned(uint256 indexed tokenId, Breed breed);
  event ReturnedCollectible(bytes32 indexed requestId, uint256 randomNumber);

  constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyhash, uint256 _fee) public
  VRFConsumerBase(_vrfCoordinator, _linkToken)
  ERC721("DogieBW", "DOGBW") {
    tokenCounter = 0;
    keyhash = _keyhash;
    fee = _fee;
  }

  function createCollectible() public returns (bytes32) {
    bytes32 requestId = requestRandomness(keyhash, fee);
    requestIdToSender[requestId] = msg.sender;
    emit requestedCollectible(requestId, msg.sender);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
    Breed breed = Breed(randomNumber % 3);
    uint256 newTokenId = tokenCounter;
    tokenIdToBreed[newTokenId] = breed;
    emit breedAssigned(newTokenId, breed);
    address owner = requestIdToSender[requestId];
    _safeMint(owner, newTokenId);
    // _setTokenURI(newTokenId, tokenURI);

    tokenIdToBreed[newTokenId] = breed;
    requestIdToTokenId[requestId] = newTokenId;
    tokenCounter = tokenCounter + 1;
    emit ReturnedCollectible(requestId, randomNumber);
  }

  function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not owner nor approved");
    _setTokenURI(tokenId, _tokenURI);
  }

}