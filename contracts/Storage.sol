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

    //1个行使资产可以创建多少个期权
    uint256 public optionAmountPerStrike = 5;
}
