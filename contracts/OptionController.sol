pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NsureCallToken.sol";

import "./Storage.sol";

contract OptionController is Storage {
    address public core;

    struct Option {
        uint256 deadline; //expiration block number
        uint256 target; //targe price
        uint256 optionAmountPerStrike; //1个行使资产可以创建多少个期权
        uint256 orderDirection; //should be ORDER_OPTION_CALL or ORDER_OPTION_PUT
    }

    uint256[] public deadlines; // 可选的清算截止block number
    uint256[] public targets; // 可选的清算目标金额

    address public underlyingAsset;
    address public strikeAsset;

    address public uniswap;

    mapping(bytes32 => Option) public options; // 根据日期和价格确定期权

    event Pause(address indexed user);
    event Unpause(address indexed user);
    event Emergency(address indexed user);

    modifier onlyCore() {
        require(msg.sender == core, "Not Authorized, Only Core");
        _;
    }

    constructor(address _uniswap) public {
        core = msg.sender;
        uniswap = _uniswap;
    }

    /*******************  期权参数配置 *****************/
    function setDeadline() public onlyCore {}

    function setTarget() public onlyCore {}

    function setOptionRate(uint256 rate) public onlyCore {
        optionAmountPerStrike = rate;
    }

    function setUniswap() public onlyCore {}

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
    //判断deadline 和 target是否合法
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

    function pause() external onlyCore {
        require(!systemPaused, "ERROR: already paused");
        systemPaused = true;
        emit Pause(msg.sender);
    }

    function unpause() external onlyCore {
        require(systemPaused, "ERROR: not paused");
        systemPaused = false;
        emit Unpause(msg.sender);
    }

    function setEmergency() external onlyCore {
        systemPaused = true;
        systemStatus = STATUS_EMERGENCY;
        emit Emergency(msg.sender);
    }
}
