pragma solidity 0.5.17;

import './OptionToken.sol';

contract OptionController {

    struct option {
        uint deadline;
        uint target;
        uint optionRate;
        address optionAddress;
    }

    mapping(bytes32 => option) public options;  // 根据日期和价格确定期权
    
    uint[] public deadlines;  // 可选的清算截止日期
    uint[] public targets;    // 可选的清算目标金额
    uint public optionRate;   // 汇率（1个以太坊可以创建多少份期权）

    /*******************  期权参数配置 *****************/
    
    // onlyOwner
    function setDeadline() public {}

    // onlyOwner
    function setTarget() public {}

    // onlyOwner
    function setOptionRate() public {}

    function getDeadlines() public view returns (uint[]) {
        return deadlines;
    }

    function getTargets() public view returns (uint[]) {
        return targets;
    }

    function getOptionRate() public view returns (uint) {
        return optionRate;
    }

    /*******************  创建期权 *****************/
    // 创建期权(deadline需要大于now)
    function createOption(uint _deadline, uint _target) public payable {
        // 先判断这两个参数是否合法（在参数列表里面）
        
        // 判断这个期权是否存在，如果不存在就创建，如果存在就直接mint
        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        if (options[salt].optionAddress != address(0)) {
            // 期权存在，直接mint
        } else {
            address optionAddress;
            bytes memory bytecode = type(OptionToken).creationCode;
            assembly {
                optionAddress := create2(0, add(bytecode, 32), mload(bytecode), salt);
            }
            // 初始化代币信息
            options[option] = option(_deadline, _target, optionRate, optionAddress);
        }

        
    }

    // 赎回期权（只有在结算以后才可以赎回）
    function burnOption(uint _deadline, uint _target, uint _optionAmount) public {

    }

    // 买家行权（只有在结算以后才可以赎回）
    function exercise(uint _deadline, uint _target, uint amount) public {}


    // 清算
    function clear(uint _deadline, uint _target) public {}

    // 根据期权参数，查询期权地址
    function optionAddress(uint _deadline, uint _target) public view returns (address optionAddress) {
        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        optionAddress =  options[salt].optionAddress;
    }
    


}