// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {DAO} from "src/DAO.sol";

contract DAOTest is Test {
    DAO public immutable dao;
    ERC20 public immutable socks;

    event Deposit(address indexed depositor, uint256 amount);
    event Withdraw(address indexed withdrawer, uint256 amount);

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
        @param  percent  uint8  Percentage of balance
     */
    function testDeposit(uint8 percent) external {
        vm.assume(percent != 0);
        vm.assume(percent <= 100);

        uint256 balance = socks.balanceOf(address(this));
        uint256 amount = (balance * percent) / 100;

        socks.approve(address(dao), amount);

        vm.expectEmit(true, false, false, true, address(dao));

        emit Deposit(address(this), amount);

        dao.deposit(amount);

        (uint256 memberSocks, ) = dao.getMember(address(this));

        assertEq(amount, memberSocks);
    }

    /*//////////////////////////////////////////////////////////////
                            withdraw TESTS
    //////////////////////////////////////////////////////////////*/

    /**
        @notice Test revert: amount is zero
     */
    function testCannotWithdrawAmountZeroAmount() external {
        uint256 invalidAmount = 0;

        vm.expectRevert(DAO.ZeroAmount.selector);

        dao.withdraw(invalidAmount);
    }

    /*//////////////////////////////////////////////////////////////
                            withdraw TESTS
    //////////////////////////////////////////////////////////////*/

    /**
        @notice Test revert: amount exceeds amount deposited
     */
    function testCannotWithdrawAmountExceedsDeposits() external {
        uint256 invalidAmount = 1;
        (uint256 memberSocks, ) = dao.getMember(address(this));

        assertGt(invalidAmount, memberSocks);

        vm.expectRevert(stdError.arithmeticError);

        dao.withdraw(invalidAmount);
    }

    /**
        @notice Test success: withdraw SOCKS
        @param  percent  uint8  Percentage of balance
     */
    function testWithdraw(uint8 percent) external {
        vm.assume(percent != 0);
        vm.assume(percent <= 100);

        uint256 balance = socks.balanceOf(address(this));
        uint256 amount = (balance * percent) / 100;

        // Deposit SOCKS to ensure available withdrawal amount is non-zero
        socks.approve(address(dao), amount);
        dao.deposit(amount);

        (uint256 memberSocksBeforeWithdrawal, ) = dao.getMember(address(this));
        uint256 balanceBeforeWithdrawal = socks.balanceOf(address(this));

        assertEq(amount, memberSocksBeforeWithdrawal);
        assertEq(balance - amount, balanceBeforeWithdrawal);

        vm.expectEmit(true, false, false, true, address(dao));

        emit Withdraw(address(this), amount);

        dao.withdraw(amount);

        (uint256 memberSocksAfterWithdrawal, ) = dao.getMember(address(this));
        uint256 balanceAfterWithdrawal = socks.balanceOf(address(this));

        assertEq(
            memberSocksBeforeWithdrawal - amount,
            memberSocksAfterWithdrawal
        );
        assertEq(balanceBeforeWithdrawal + amount, balanceAfterWithdrawal);
    }
}
