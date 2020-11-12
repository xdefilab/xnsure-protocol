pragma solidity 0.5.17;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Const.sol";

contract Storage is Constants {
    using SafeMath for uint256;

    //uniswap
    address public uniswapFactoryAddress;
}
