//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract RinkebySquirrels is Ownable, ERC721Enumerable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint public constant MAX_SUPPLY = 5555;
    uint public constant PRICE = 0.01 ether;
    uint public constant MAX_PER_MINT = 10;

    string public baseTokenURI;
    // IPFS Provenance for Rinkeby Squirrels
    string public RSQProvenance = '581a230809e1beb64d3109c5f23b0cff3bbd3245657c49436ca8987694da5755'; 

    bool public saleIsActive = false;

    constructor(string memory baseURI) ERC721("Rinkeby Squirrels", "RSQ") {
        setBaseURI(baseURI);
    }

    // Reserve a few squirrels
    function reserveSquirrels() public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(10) < MAX_SUPPLY, "Not enough squirrels left to reserve");

        for (uint i = 0; i < 10; i++) {
            _mintSingleSquirrel();
        }
    }

    // Override empty _baseURI function 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // Allow owner to set baseTokenURI
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // Set Sale state
    function setSaleState(bool _activeState) public onlyOwner {
        saleIsActive = _activeState;
    }

    // Set Provenance
    function setProvenance(string memory _provenance) public onlyOwner {
        RSQProvenance = _provenance;
    }

    // Mint Squirrels
    function mintSquirrel(uint _count) public payable {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough squirrels left!");
        require(_count >0 && _count <= MAX_PER_MINT, "Cannot mint specified number of squirrels.");
        require(saleIsActive, "Sale is not currently active!");
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase squirrels.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleSquirrel();
        }
    }

    // Mint a single squirrel
    function _mintSingleSquirrel() private {
        // Sanity check for absolute worst case scenario
        require(totalSupply() == _tokenIds.current(), "Indexing has broken down!");
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    // Withdraw ether
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // Get tokens of an owner
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {

        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }
}