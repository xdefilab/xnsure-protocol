pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NsureCallToken.sol";

import "./Storage.sol";

contract OptionController is Storage {
    struct Option {
        uint256 deadline;
        uint256 target;
        uint256 optionAmountPerStrike;
        address optionAddress;
        //should be ORDER_OPTION_CALL or ORDER_OPTION_PUT
        uint256 orderDirection;
    }

    uint256[] public deadlines; // 可选的清算截止日期
    uint256[] public targets; // 可选的清算目标金额
    address public underlyingAsset;
    address public strikeAsset;

    address public uniswap;

    mapping(bytes32 => Option) public options; // 根据日期和价格确定期权

    /*******************  期权参数配置 *****************/

    // onlyOwner
    function setDeadline() public {}

    // onlyOwner
    function setTarget() public {}

    // onlyOwner
    function setOptionRate(uint256 rate) public {
        optionAmountPerStrike = rate;
    }

    function setUniswap() public {}

    function getDeadlines() public view returns (uint256[] memory) {
        return deadlines;
    }

    function getTargets() public view returns (uint256[] memory) {
        return targets;
    }

    function getOptionRate() public view returns (uint256) {
        return optionAmountPerStrike;
    }

    /*******************  创建期权 *****************/

    // TODO：判断deadline 和 target是否合法
    modifier validParamers(uint256 _deadline, uint256 _target) {
        require(
            _deadline > block.number,
            "ERROR: deadline before block.number"
        );
        _;
    }

    // 创建期权(deadline需要大于now)
    // TODO: 判断是 ORDER_OPTION_CALL 还是 ORDER_OPTION_PUT
    function createOption(uint256 _deadline, uint256 _target)
        public
        payable
        validParamers(_deadline, _target)
    {
        require(msg.value > 0, "Error: strike asset amount is zero");

        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        address optionAddress = options[salt].optionAddress;
        if (optionAddress == address(0)) {
            //TODO: uint256 to string

            NsureCallToken callToken = new NsureCallToken(
                "NsureCallToken",
                "CALL",
                address(this),
                underlyingAsset,
                18,
                strikeAsset,
                18,
                _target,
                _deadline
            );

            optionAddress = address(callToken);

            options[salt] = Option(
                _deadline,
                _target,
                optionAmountPerStrike,
                optionAddress,
                ORDER_OPTION_CALL
            );
        }

        NsureCallToken(optionAddress).mint.value(msg.value)(
            msg.sender,
            msg.value
        );
    }

    // 使用期权赎回现货（只有在结算以后才可以赎回）
    function redeemOption(
        uint256 _deadline,
        uint256 _target,
        uint256 _optionAmount
    ) public {}

    // 管理员推送价格并行权清算
    function exercise(
        uint256 _deadline,
        uint256 _target,
        uint256 amount
    ) public {
        // 判断是否在行权期间
    }

    /*********************** 查询代币信息封装 **************************/

    // 根据期权参数，查询期权地址
    function getOptionAddress(uint256 _deadline, uint256 _target)
        public
        view
        returns (address optionAddress)
    {
        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        optionAddress = options[salt].optionAddress;
    }

    // 根据地址查询代币 deadline target等信息

    /*********************** uniswap 封装 **************************/

    function addLiquidity() public {}

    function revomeLiquidity() public {}

    function swap() public {}

    function getAmountsIn() public {}

    function getAmountsOn() public {}
}
