pragma solidity 0.5.17;

import "./Const.sol";

contract Storage is Constants {
    //uniswap
    address public uniswapFactoryAddress;

    uint8 public systemStatus = STATUS_NORMAL;
    bool public systemPaused = false;

    //SAFU address
    address public safuAddress;
    //SAFU balance
    int256 public safuBalance;
}
