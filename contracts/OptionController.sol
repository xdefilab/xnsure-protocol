pragma solidity 0.5.17;

import './libraries/IERC20.sol';
import './OptionFunction.sol';

contract OptionController {

    struct option {
        uint deadline;
        uint target;
        uint optionRate;
        address optionAddress;
    }
    
    uint[] public deadlines;  // 可选的清算截止日期
    uint[] public targets;    // 可选的清算目标金额
    uint public optionRate;   // 汇率（1个以太坊可以创建多少份期权）
    address public underlyingAsset;
    address public strikeAsset;

    address public uniswap;

    mapping(bytes32 => option) public options;  // 根据日期和价格确定期权

    /*******************  期权参数配置 *****************/
    
    // onlyOwner
    function setDeadline() public {}

    // onlyOwner
    function setTarget() public {}

    // onlyOwner
    function setOptionRate() public {}

    function setUniswap() public {}

    function getDeadlines() public view returns (uint[] memory) {
        return deadlines;
    }

    function getTargets() public view returns (uint[] memory) {
        return targets;
    }

    function getOptionRate() public view returns (uint) {
        return optionRate;
    }

    /*******************  创建期权 *****************/
    
    // TODO：判断deadline 和 target是否合法
    modifier validParamers(uint _deadline, uint _target) {
        _;
    }
    
    // 创建期权(deadline需要大于now)
    function createOption(uint _deadline, uint _target) public payable validParamers(_deadline, _target) {
        
        require(msg.value > 0, "Error");
        
        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        address optionAddress = options[salt].optionAddress;
        if (optionAddress == address(0)) {
            bytes memory bytecode = type(OptionFunction).creationCode;
            assembly {
                optionAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }

            OptionFunction(optionAddress).initialize(address(this),
                underlyingAsset, strikeAsset, _target, _deadline, optionRate);

            options[salt] = option(_deadline, _target, optionRate, optionAddress);
        }

        OptionFunction(optionAddress).mint.value(msg.value)(msg.sender, msg.value);
    }

    // 使用期权赎回现货（只有在结算以后才可以赎回）
    function redeemOption(uint _deadline, uint _target, uint _optionAmount) public {
        
    }

    // 管理员推送价格并行权清算
    function exercise(uint _deadline, uint _target, uint amount) public {
        // 判断是否在行权期间
    }

    /*********************** 查询代币信息封装 **************************/ 
    
    // 根据期权参数，查询期权地址
    function getOptionAddress(uint _deadline, uint _target) public view returns (address optionAddress) {
        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        optionAddress =  options[salt].optionAddress;
    }

    // 根据地址查询代币 deadline target等信息

    /*********************** uniswap 封装 **************************/ 
    function addLiquidity() public {}

    function revomeLiquidity() public {}

    function swap() public {}

    function getAmountsIn() public {}

    function getAmountsOn() public {}

    
    


}