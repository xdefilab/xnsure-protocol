pragma solidity 0.5.17;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Const.sol";

contract Storage is Constants {
    using SafeMath for uint256;

    //uniswap
    address public uniswapFactoryAddress;

    //杠杆参数: 如决定1个以太坊能创建几份期权
    uint8 public marginRate = 1;

    uint8 public systemStatus = STATUS_NORMAL;
    bool public systemPaused = false;

    //SAFU address
    address public safuAddress;
    //SAFU balance
    int256 public safuBalance;
}
