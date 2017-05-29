pragma solidity ^0.4.8;

import {PendingManagerInterface as Shareable} from "./PendingManagerInterface.sol";
import "./UserStorageInterface.sol";

contract Managed {
    address userStorage;
    address contractsManager;
    address shareable;

    modifier onlyAuthorized() {
        if (isAuthorized(msg.sender) || msg.sender == shareable) {
            _;
        }
    }

    modifier multisig() {
        if (msg.sender != shareable) {
            bytes32 _r = sha3(msg.data);
            Shareable(shareable).addTx(_r, msg.data, this, msg.sender);
        }
        else {
            _;
        }
    }

    function isAuthorized(address key) returns (bool) {
        return UserStorageInterface(userStorage).getCBE(key);
    }

}
