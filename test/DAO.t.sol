// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {DAO} from "src/DAO.sol";

contract DAOTest is Test {
    DAO public immutable dao;
    ERC20 public immutable socks;

    event Deposit(address indexed depositor, uint256 amount);

    constructor() {
        dao = new DAO();
        socks = dao.SOCKS();

        // Fund this contract with $SOCKS from an account with an existing balance
        address socksSource = address(socks);
        uint256 socksBalance = socks.balanceOf(socksSource);

        vm.prank(socksSource);

        socks.transfer(address(this), socksBalance);
    }

    /*//////////////////////////////////////////////////////////////
                            deposit TESTS
    //////////////////////////////////////////////////////////////*/

    /**
        @notice Test revert: amount is zero
     */
    function testCannotDepositAmountZeroAmount() external {
        uint256 invalidAmount = 0;

        vm.expectRevert(DAO.ZeroAmount.selector);

        dao.deposit(invalidAmount);
    }

    /**
        @notice Test success: deposit SOCKS
     */
    function testDeposit() external {
        uint256 amount = socks.balanceOf(address(this));

        socks.approve(address(dao), amount);

        vm.expectEmit(true, false, false, true, address(dao));

        emit Deposit(address(this), amount);

        dao.deposit(amount);

        (uint256 memberSocks, ) = dao.getMember(address(this));

        assertEq(amount, memberSocks);
    }
}
