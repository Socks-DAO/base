// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract DAO is ReentrancyGuard {
    using SafeTransferLib for ERC20;

    struct Member {
        uint256 socks;
        uint256[] socksNFT;
    }

    ERC20 public constant SOCKS =
        ERC20(0x23B608675a2B2fB1890d3ABBd85c5775c51691d5);
    ERC721 public constant SOCKS_NFT =
        ERC721(0x65770b5283117639760beA3F867b69b3697a91dd);

    mapping(address => Member) public members;

    event Deposit(address indexed depositor, uint256 amount);
    event DepositNFT(address indexed depositor, uint256 tokenId);
    event Withdraw(address indexed withdrawer, uint256 amount);
    event WithdrawNFT(address indexed withdrawer, uint256 tokenId);

    error ZeroAmount();

    /**
        @notice Get member
        @param  member  address    Member address
        @return         uint256    SOCKS deposited
        @return         uint256[]  SOCKS NFT IDs deposited
     */
    function getMember(address member)
        external
        view
        returns (uint256, uint256[] memory)
    {
        Member memory m = members[member];

        return (m.socks, m.socksNFT);
    }

    /**
        @notice Deposit SOCKS
        @param  amount  uint256  SOCKS amount
     */
    function deposit(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        // Reverts if user balance is insufficient
        SOCKS.safeTransferFrom(msg.sender, address(this), amount);

        members[msg.sender].socks += amount;

        emit Deposit(msg.sender, amount);
    }

    /**
        @notice Withdraw SOCKS
        @param  amount  uint256  SOCKS amount
     */
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        // Reverts if underflows (i.e. withdrawal exceeds deposits)
        members[msg.sender].socks -= amount;

        SOCKS.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    /**
        @notice Deposit SOCKS NFT
        @param  tokenId  uint256  SOCKS NFT ID
     */
    function depositNFT(uint256 tokenId) external nonReentrant {
        SOCKS_NFT.safeTransferFrom(msg.sender, address(this), tokenId);

        members[msg.sender].socksNFT.push(tokenId);

        emit DepositNFT(msg.sender, tokenId);
    }

    /**
        @notice Withdraw SOCKS NFT
        @param  index  uint256  Index of the member's socksNFT token ID
     */
    function withdrawNFT(uint256 index) external nonReentrant {
        uint256[] storage socksNFT = members[msg.sender].socksNFT;
        uint256 lastIndex = socksNFT.length - 1;
        uint256 tokenId = socksNFT[index];

        if (index != lastIndex) {
            // Set the element at removalIndex to the last element
            socksNFT[index] = socksNFT[lastIndex];
        }

        socksNFT.pop();
        SOCKS_NFT.transferFrom(address(this), msg.sender, tokenId);

        emit WithdrawNFT(msg.sender, tokenId);
    }

    /**
        @notice Handle the receipt of SOCKS NFTs
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes32) {
        return
            bytes32(
                0x00000000000000000000000000000000000000000000000000000000150b7a02
            );
    }
}
