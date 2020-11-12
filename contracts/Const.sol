pragma solidity 0.5.17;

contract Constants {
    uint256 internal constant XONE = 10**18;

    //system status
    uint8 public constant STATUS_NORMAL = 0;
    uint8 public constant STATUS_EMERGENCY = 1;

    //order direction
    uint8 public constant ORDER_OPTION_CALL = 11;
    uint8 public constant ORDER_OPTION_PUT = 12;
}
