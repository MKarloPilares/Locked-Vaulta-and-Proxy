// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract Vault is 
    Initializable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable {

    error StillLocked(uint256 deadline);
    error InsufficientBalance(uint256 balance, uint256 withdrawalAmount);

    event Deposit(uint256 amount);
    event Unlock(uint256 deadline);
    event Withdraw (uint256 amount);

    uint256 public deadline;

    function initialize(address initialOwner) external initializer(){
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
    }

    function deposit() external payable onlyOwner {
        emit Deposit(msg.value);
    }

    function startUnlockTimer() external onlyOwner {
        deadline = block.timestamp + 7 days;

        emit Unlock(deadline);
    }

    function withdraw(uint256 amount) external onlyOwner nonReentrant{
        if (block.timestamp < deadline) {
            revert StillLocked(deadline);
        }

        if (amount > address(this).balance) {
            revert InsufficientBalance(address(this).balance, amount);
        }

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "ETH not sent!");

        emit Withdraw(amount);
    }

    function changeOwner(address newOwner) external onlyOwner{
        require(newOwner != address(0), "Invalid owner");
        transferOwnership(newOwner);
    }

}