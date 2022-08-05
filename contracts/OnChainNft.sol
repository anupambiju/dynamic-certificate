// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract OnChainNft is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public NameValue = "Name of Student";
  string public ScoreValue = "Score of student";

  struct Word {
    string name;
    string description;
    string value;
    string value2;
  }

  mapping (uint256 => Word) public words;

  constructor() ERC721("On Chain Nft", "OCN") {}

  function mint() public payable {
    uint256 supply = totalSupply();
    require(supply + 1 <= 10);

    Word memory newWord= Word(
      string(abi.encodePacked('AcadScore #', uint256(supply + 1).toString())),
      "CGPA of Student",
      NameValue,
      ScoreValue
    );

    if (msg.sender != owner()) {
      require(msg.value >= 0.0001 ether);
    }
    words[supply+1]= newWord;
    _safeMint(msg.sender, supply + 1);
  }

  function setStudentName(uint256 _tokenId, string memory _newMessage) public {
    require(msg.sender == ownerOf(_tokenId),"You are not an owner");
    bytes memory strBytes = bytes(_newMessage);
    require(strBytes.length <= 50, "Message is too long.");
    Word storage currentPage = words[_tokenId];
    currentPage.value = _newMessage;
  

  }
  
  function setStudentScore(uint256 _tokenId, string memory _newMessage2) public {
    require(msg.sender == ownerOf(_tokenId),"You are not an owner");
    bytes memory strBytes2 = bytes(_newMessage2);
    require(strBytes2.length <= 50, "Message is too long.");
    Word storage currentPage = words[_tokenId];
    currentPage.value2 = _newMessage2;
  

  }  

  function buildImage(uint256 _tokenId) public view returns(string memory){
      Word memory currentWord = words[_tokenId];
      return Base64.encode(bytes(abi.encodePacked(
      '<svg class="svgBody" width="300" height="300" viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg">'
      '<rect width="300" height="300" rx="10" style="fill:#fdffbc" />'
      '<rect y="205" width="300" height="75" rx="10" style="fill:#ffc1b6" />'
      '<rect y="60" width="300" height="115" style="fill:#ffeebb"/>'
      '<rect y="175" width="300" height="40" style="fill:#ffdcb8" />'
      '<text x="15" y="25" class="medium">ACADEMIC CERTIFICATE</text>'
      '<text x="17" y="50" class="small" opacity="0.5">certificate id 12456532</text>'
      '<circle cx="255" cy="30" r="20" stroke="white" fill="transparent" stroke-width="5" opacity="0.7"/>'
      '<path d="M 230 55 l 30 -40" stroke="#ffc1b6" stroke-width="5"/>'
      '<path d="M 280 55 l -30 -40" stroke="#ffc1b6" stroke-width="5"/>'
      '<path d="M 230 55 q 25 -30 50 0" stroke="#ffc1b6" stroke-width="5" fill="none" />'
      '<line x1="235" y1="145" x2="235" y2="300" stroke="white" stroke-width="10" stroke-dasharray="10 13 10"/>'
      '<line x1="245" y1="115" x2="245" y2="300" stroke="#ffdcb8" stroke-width="10" stroke-dasharray="12 8 14"/>'
      '<line x1="255" y1="113" x2="255" y2="300" stroke="#fdffbc" stroke-width="10" stroke-dasharray="0 0 4"/>'
      '<line x1="265" y1="152" x2="265" y2="300" stroke="#ffc1b6" stroke-width="10" stroke-dasharray="4 4 9"/>'
      '<line x1="275" y1="97" x2="275" y2="300" stroke="black" stroke-width="10" stroke-dasharray="10 9 1"/>'
      '<text x="215" y="80" class="small">AcadScore</text>'
      '<text x="15" y="80" class="medium">',currentWord.value,'</text>'
      '<text x="15" y="100" class="medium">has scored CGPA</text><text x="15" y="120" class="medium">of</text>'
      '<rect x="15" y="125" width="205" height="40" style="fill:white;opacity:0.5"/>'
      '<text x="15" y="140" class="medium">',currentWord.value2,'</text>'
      '<text x="15" y="190" class="small">VERIFIED BY:</text><text x="15" y="205" style="font-size:8px">Prof. XYZ</text>'
      '<text x="15" y="230" class="tiny">Under Section xyz of xzy college of engineering</text>'
      '<style>.svgBody {font-family: "Courier New" } .tiny {font-size:6px; } .small {font-size: 12px;}.medium {font-size: 18px;}</style></svg>'    
      )));
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    Word memory currentWord = words[_tokenId];

    return string (abi.encodePacked(
        'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
            '{"name":"',
            currentWord.name,
            '","description":"',
            currentWord.description,
            '","image":"',
            'data:image/svg+xml;base64,',
            buildImage(_tokenId),
            '"}'

        )))));
  }
  
  function withdraw() public payable onlyOwner {    
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}