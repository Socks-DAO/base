// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract DAO is ReentrancyGuard {
    using SafeTransferLib for ERC20;

    struct Member {
        uint256 socks;
        uint256 socksNFT;
    }

    ERC20 public constant SOCKS =
        ERC20(0x23B608675a2B2fB1890d3ABBd85c5775c51691d5);

    mapping(address => Member) public members;

    event Deposit(address indexed depositor, uint256 amount);

    error ZeroAmount();

    /**
        @notice Get member
        @param  member  address  Member address
        @return         uint256  SOCKS deposited
        @return         uint256  SOCKS NFT deposited
     */
    function getMember(address member)
        external
        view
        returns (uint256, uint256)
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

        SOCKS.safeTransferFrom(msg.sender, address(this), amount);

        members[msg.sender].socks += amount;

        emit Deposit(msg.sender, amount);
    }
}
