// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC1155, Ownable, Pausable, ERC1155Burnable, ERC1155Supply {
    /**
     * @dev constants
     */
    uint256 public constant PUBLIC_MINT = 0.05 ether;
    uint256 public constant SPECIAL_LIST_MINT = 0.03 ether;
    uint256 public constant LIMIT_PER_WALLET = 3;
    uint256 public constant MAX_SUPPLY = 20;

    bool public s_publicMintIsOpen = false;
    bool public s_specialMintIsOpen = false;

    mapping(address => bool) allowList;
    mapping(address => uint256) purchasesPerWallet;

    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setMintWindow(bool _publicMint, bool _specialList) external onlyOwner {
        _publicMint = s_publicMintIsOpen;
        _specialList = s_publicMintIsOpen;
    }

    function setMintWindow(address[] calldata _addr) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {
            allowList[_addr[i]] = true;
        }
    }

    function publicMint(uint256 id, uint256 amount) public payable onlyOwner {
        require(s_publicMintIsOpen, "Sorry public mint window is closed");
        require(msg.value == PUBLIC_MINT * amount, "Enough ethers are not sent");
        mint(id, amount);
    }

    function specialListMint(uint256 id, uint256 amount) public payable {
        require(allowList[msg.sender], "You are not chosen to be special");
        require(s_specialMintIsOpen, "Sorry special mint window is closed");
        require(msg.value == SPECIAL_LIST_MINT * amount, "Enough ethers are not sent");
        mint(id, amount);
    }

    function mint(uint256 id, uint256 amount) internal {
        require(purchasesPerWallet[msg.sender] <= LIMIT_PER_WALLET, "You have reached your limit");
        require(totalSupply(id) + amount <= MAX_SUPPLY, "Max tokens have been minted");
        _mint(msg.sender, id, amount, "");
        purchasesPerWallet[msg.sender] += amount;
    }

    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    function uri(uint256 _id) public view virtual override returns (string memory) {
        require(exists(_id));
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _update(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._update(operator, from, to, ids, amounts, data);
    }
}
