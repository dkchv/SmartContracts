pragma solidity ^0.4.8;

import "./Configurable.sol";
import "./SharedLibrary.sol";

contract LOCManager is Configurable {

function LOCManager(address _es) {
    if(_es == 0x0) throw;
    eternalStorage = _es;
}

}
