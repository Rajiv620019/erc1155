// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
    uint256 public constant PUBLIC_MINT = 0.02 ether;
    uint256 public constant SPECIAL_LIST_MINT = 0.01 ether;
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
}
