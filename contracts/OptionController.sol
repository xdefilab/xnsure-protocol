pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";

import "./NsureCallToken.sol";

import "./Storage.sol";

contract OptionController is Storage {
    using SafeMath for uint256;
    address public core;

    struct Option {
        uint256 deadline; //expiration block number
        uint256 target; //targe price
        uint256 optionAmountPerStrike; //1个行使资产可以创建多少个期权
        address optionAddress;
        address underlyingAssetAddress;
        uint256 orderDirection; //should be ORDER_OPTION_CALL or ORDER_OPTION_PUT
    }

    uint256[] public deadlines; // 可选的清算截止block number
    uint256[] public targets; // 可选的清算目标金额
    uint public optionRate;

    address public underlyingAsset;
    address public strikeAsset;

    address public uniswapOption;
    address public uniswapSpots;
    
    mapping(bytes32 => Option) public options;  // 根据日期和价格确定期权
    mapping(uint => bool) public inDeadline;    // deadline 是否合法
    mapping(uint => bool) public inTargets;     // target 是否合法

    event Pause(address indexed user);
    event Unpause(address indexed user);
    event Emergency(address indexed user);

    modifier onlyCore() {
        require(msg.sender == core, "Not Authorized, Only Core");
        _;
    }

    constructor(address _uniswapOption) public {
        core = msg.sender;
        uniswapOption = _uniswapOption;
    }

    /*******************  期权参数配置 *****************/
    function setOptionRate(uint _optionRate) public onlyCore {
        optionRate = _optionRate;
    }

    function setUniswapOption(address _uniswapOption) public onlyCore {
        uniswapOption = _uniswapOption;
    }

    function setUniswapSpots(address _uniswapSpots) public onlyCore {
        uniswapSpots = _uniswapSpots;
    }

    function setDeadline(uint[] memory _deadlines) public onlyCore {
        uint length = deadlines.length;
        for (uint i = 0; i< length; i++) {
            inDeadline[deadlines[i]] = false;
        }
        
        length = _deadlines.length;
        for (uint i = 0; i< length; i++) {
            inDeadline[_deadlines[i]] = true;
        }

        deadlines = _deadlines;
    }

    function setTarget(uint[] memory _target) public onlyCore {
        uint length = targets.length;
        for (uint i = 0; i< length; i++) {
            inTargets[targets[i]] = false;
        }
        
        length = _target.length;
        for (uint i = 0; i< length; i++) {
            inTargets[_target[i]] = true;
        }

        targets = _target;
    }

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
        require(
            inDeadline[_deadline] && inTargets[_target], 
            "Error: invalid deadline or target!"
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
                underlyingAsset,
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
    ) public {

        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        
        NsureCallToken(optionAddress).redeem(msg.sender, _optionAmount);
    }

    // 管理员推送价格并行权清算
    function exercise(
        uint256 _deadline,
        uint256 _target,
        uint256 _price
    ) public onlyCore {
        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
               
        NsureCallToken(optionAddress).exercise(_price);
    }

    /*********************** 查询代币信息封装 **************************/

    // 根据期权参数，查询期权地址
    function getOptionAddress(uint256 _deadline, uint256 _target)
        public
        view
        returns (address)
    {
        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        return options[salt].optionAddress;
    }

    // 查期权underlyingAsset
    function getOptionUnderlyingAsset(uint256 _deadline, uint256 _target) 
        public
        view
        returns (address) 
    {
        bytes32 salt = keccak256(abi.encodePacked(_deadline, _target));
        return options[salt].underlyingAssetAddress;
    }

    // 查期权余额
    function getOptionBalance(uint256 _deadline, uint256 _target, address _user)
        public
        view
        returns (uint) 
    {
        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");

        return IERC20(optionAddress).balanceOf(_user);

    }

    // 查询期权的LP的地址
    function getOptionLPAddress(uint256 _deadline, uint256 _target)
        public
        view
        returns (address)
    {
        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        address factory = IUniswapV2Router02(uniswapOption).factory();
        return IUniswapV2Factory(factory).getPair(optionAddress, underlyingAssetAddress);
    }

    // 查询期权LP的余额
    function getOptionLPBalance(uint256 _deadline, uint256 _target, address _user) 
        public
        view
        returns (uint) 
    {
        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        address factory = IUniswapV2Router02(uniswapOption).factory();
        address lpAddress = IUniswapV2Factory(factory).getPair(optionAddress, underlyingAssetAddress);

        return IERC20(lpAddress).balanceOf(_user);
    }

    /*********************** uniswapOption 封装 **************************/

    function addLiquidity(
        uint _deadline,
        uint _target,
        uint _optionDesired,
        uint _underlyingAssetDesired,
        uint _optionMin,
        uint _underlyingAssetMin
    ) public validParamers(_deadline, _target) returns (uint amountA, uint amountB, uint liquidity) {
        
        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        return IUniswapV2Router02(uniswapOption).addLiquidity(optionAddress, underlyingAssetAddress, _optionDesired, _underlyingAssetDesired, _optionMin, _underlyingAssetMin, msg.sender, block.number.add(1800));
    }

    function revomeLiquidity(
        uint _deadline,
        uint _target,
        uint _liquidity,
        uint _optionMin,
        uint _underlyingAssetMin
    ) public returns (uint amountA, uint amountB) {
        
        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");

        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        return IUniswapV2Router02(uniswapOption).removeLiquidity(optionAddress, underlyingAssetAddress, _liquidity, _optionMin, _underlyingAssetMin, msg.sender, block.number.add(1800));
    }

    // type == 0 is buy option
    // type == 1 is sell option
    function swap(
        uint _deadline,
        uint _target,
        uint _type,
        uint _amountIn,
        uint _amountOutMin
    ) public returns (uint[] memory amounts) {
        
        require(_type == 0 || _type == 1, "Error: invalid type");
        
        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();
        
        address[] memory path = new address[](2);
        if (_type == 0) {
            path[0] = underlyingAssetAddress;
            path[1] = optionAddress;
        } else {
            path[0] = optionAddress;
            path[1] = underlyingAssetAddress;
        }
         
        return IUniswapV2Router02(uniswapOption).swapExactTokensForTokens(_amountIn, _amountOutMin, path, msg.sender, block.number.add(1800));
    }

    // 想要得到指定数量的underlyingAsset，需要输入多少option
    function getOptionIn(
        uint _deadline,
        uint _target,
        uint _amountOut
    ) public view returns (uint d) {

        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        address[] memory path = new address[](2);
        path[0] = optionAddress;
        path[1] = underlyingAssetAddress;
        
        return IUniswapV2Router02(uniswapOption).getAmountsIn(_amountOut, path)[0];
    }

    // 输入指定数量的underlyingAsset，可以得到多少option
    function getOptionOut(
        uint _deadline,
        uint _target,
        uint _amountIn
    ) public view returns (uint d) {

        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        address[] memory path = new address[](2);
        path[0] = underlyingAssetAddress;
        path[1] = optionAddress;
        
        return IUniswapV2Router02(uniswapOption).getAmountsOut(_amountIn, path)[1];
    }

    // 想要得到指定数量的option，需要输入多少underlyingAsset
    function getUnderlyingIn(
        uint _deadline,
        uint _target,
        uint _amountOut
    ) public view returns (uint d) {

        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        address[] memory path = new address[](2);
        path[0] = underlyingAssetAddress;
        path[1] = optionAddress;
        
        return IUniswapV2Router02(uniswapOption).getAmountsIn(_amountOut, path)[0];
    }

    // 输入指定数量的option，可以得到多少underlyingAsset
    function getUnderlyingOut(
        uint _deadline,
        uint _target,
        uint _amountIn
    ) public view returns (uint d) {

        address optionAddress = getOptionAddress(_deadline, _target);
        require(optionAddress != address(0), "Error: option not exist.");
        address underlyingAssetAddress = NsureCallToken(optionAddress).underlyingAsset();

        address[] memory path = new address[](2);
        path[0] = optionAddress;
        path[1] = underlyingAssetAddress;
        
        return IUniswapV2Router02(uniswapOption).getAmountsOut(_amountIn, path)[1];
    }
    
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
