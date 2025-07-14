// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract LockedVault  {
    bytes32 internal constant _IMPLEMENTATION_SLOT = bytes32(
        uint256(keccak256("eip1967.proxy.implementation")) - 1
    );

    event DelegateCallResponse(bool success, bytes data);
    event Upgraded(address newLogic);

    uint256 public deadline;
    address owner;

    
    constructor(address _logic, bytes memory _data) {
        owner = msg.sender;

        _setImplementation(_logic);

        if (_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success, "Init failed");
        }
    }

    //===========================
    // MODIFIER
    //===========================
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }
    
    //===========================
    // Upgradability
    //===========================

    function _setImplementation(address newImpl) internal {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImpl)
            }

            emit Upgraded(newImpl);
        }

    function _implementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly{
            impl := sload(slot)
        }
    }

    function upgrade(address newImpl) external onlyOwner {
        _setImplementation(newImpl);
    }

    //======================
    // OWNERSHIP
    //======================

    function changeOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    //======================
    // PROXY
    //======================

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate(_implementation());
    }

    receive() external payable {
        _delegate(_implementation());
    }

}