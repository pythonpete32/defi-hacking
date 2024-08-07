// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./VulnerableBank.sol";
import "./AttackerContract.sol";

contract VulnerableBankTest is Test {
    VulnerableBank public vulnerableBank;
    AttackerContract public attackerContract;
    address public attacker;

    function setUp() public {
        // Deploy the vulnerable bank contract
        vulnerableBank = new VulnerableBank();

        // Deploy the attacker contract
        attackerContract = new AttackerContract(address(vulnerableBank));

        // Set up an attacker address
        attacker = makeAddr("attacker");

        // Fund the bank with 10 ether
        vm.deal(address(vulnerableBank), 10 ether);

        // Fund the attacker with 1 ether
        vm.deal(attacker, 1 ether);
    }

    function testReentrancyAttack() public {
        // Check initial balances
        assertEq(address(vulnerableBank).balance, 10 ether, "Bank should have 10 ether initially");
        assertEq(attacker.balance, 1 ether, "Attacker should have 1 ether initially");

        // Perform the attack
        vm.prank(attacker);
        attackerContract.attack{value: 1 ether}();

        // Check final balances
        assertEq(address(vulnerableBank).balance, 0, "Bank should have 0 ether after attack");
        assertEq(attackerContract.getBalance(), 11 ether, "Attacker contract should have 11 ether after attack");

        // Withdraw funds from attacker contract to attacker address
        vm.prank(attacker);
        attackerContract.withdrawAll();

        // Final balance check
        assertEq(attacker.balance, 11 ether, "Attacker should end up with 11 ether");
    }
}
