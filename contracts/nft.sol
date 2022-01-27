// SPDX-License-Identifier: Mozilla
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/// @custom:security-contact zhongliwang48@gmail.com
contract NothingFuckingTrash is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
  using CountersUpgradeable
  for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIdCounter;

  uint256 public constant maxSupply = 10000;
  uint256 public constant mintPrice = 0.01 ether;
  string public baseURI;
  string public version;
  mapping(address => bool) public mintAddress;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() initializer {}

  function initialize(string calldata v) initializer public {
    __ERC721_init("NothingFuckingTrash", "NFT");
    __ERC721Enumerable_init();
    __Pausable_init();
    __Ownable_init();
    __UUPSUpgradeable_init();

    baseURI = "";
    version = v;
  }

  function _baseURI() internal view override returns(string memory) {
    return baseURI;
  }

  function setBaseURI(string calldata uri) external onlyOwner {
    baseURI = uri;
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  function refundIfOver(uint256 price) private {
    require(msg.value >= price, "Need enough ETH.");
    if (msg.value > price) {
      payable(msg.sender).transfer(msg.value - price);
    }
  }

  function safeMint(address to) external onlyOwner {
    uint256 tokenId = _tokenIdCounter.current();
    require(tokenId < maxSupply, "Exceed max supply.");
    _tokenIdCounter.increment();
    _safeMint(to, tokenId);
  }

  function mint() external payable {
    require(
      !mintAddress[msg.sender],
      "The wallet has already minted."
    );
    uint256 tokenId = _tokenIdCounter.current();
    require(tokenId < maxSupply, "Exceed max supply.");
    refundIfOver(mintPrice);

    mintAddress[msg.sender] = true;
    _tokenIdCounter.increment();
    _safeMint(msg.sender, tokenId);
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
  internal
  whenNotPaused
  override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _authorizeUpgrade(address newImplementation)
  internal
  onlyOwner
  override {}

  // The following functions are overrides required by Solidity.

  function supportsInterface(bytes4 interfaceId)
  public
  view
  override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
  returns(bool) {
    return super.supportsInterface(interfaceId);
  }
}