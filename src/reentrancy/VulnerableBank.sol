// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableBank
 * @dev This contract demonstrates a reentrancy vulnerability.
 * It allows users to deposit and withdraw Ether, but the withdrawal function
 * is vulnerable to reentrancy attacks.
 */
contract VulnerableBank {
    // Mapping to store user balances
    mapping(address => uint256) public balances;

    /**
     * @dev Allows users to deposit Ether into the contract.
     * The deposited amount is added to the user's balance.
     */
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    /**
     * @dev Allows users to withdraw their entire balance.
     * This function is vulnerable to reentrancy attacks.
     */
    function withdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");

        // Vulnerability: State is updated after the external call
        // This allows for potential reentrancy
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        // Balance is updated after the transfer
        balances[msg.sender] = 0;
    }

    /**
     * @dev Returns the balance of the contract.
     * This is used to check the contract's Ether balance.
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
