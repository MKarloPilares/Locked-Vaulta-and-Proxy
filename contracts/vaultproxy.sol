// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract LockedVault is Ownable {
    
    constructor() Ownable(msg.sender) {}
    
    event DelegateCallResponse(bool success, bytes data);

    uint256 deadline;

    function CallDeposit(address _contract) external payable onlyOwner {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("deposit()")
        );

        emit DelegateCallResponse(success, data);
    }

    function CallUnlock(address _contract) external onlyOwner {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("startUnlockTimer()")
        );

        emit DelegateCallResponse(success, data);
    }

    function CallWithdraw(address _contract, uint256 amount) external onlyOwner {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("withdraw(uint256)", amount)
        );

        emit DelegateCallResponse(success, data);
    }

    function CallChangeOwner(address _contract, address newOwner) external onlyOwner {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("changeOwner(address)", newOwner)
        );

        emit DelegateCallResponse(success, data);
    }

}