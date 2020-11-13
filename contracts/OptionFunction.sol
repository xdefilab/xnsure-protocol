pragma solidity 0.5.17;

import './OptionToken.sol';

contract OptionFunction is OptionToken {
    
    address public core;
    bool public initialized;

    //标的资产
    address public underlyingAsset;
    uint256 public underlyingAssetDecimals;
    
    //行使资产
    address public strikeAsset;
    
    // 目标价格
    uint256 public targetPrice;
    // 行权价格
    uint256 public strikePrice;

    // 1个行使资产可以创建多少个期权
    uint public optionAmountPerStrike;
    //到期块数
    uint256 public expirationBlockNumber;

    // 行权的金额，
    uint256 public strikeAssetAmountPerOption;
    uint256 public expirableStrikeAssetAmount;
    uint256 public redeemableStrikeAssetAmount;

    // 期权记录
    uint256 public totalOptions;  
    mapping(address => uint256) public sellerOption;

    modifier onlyCore() {
        require(msg.sender == core, "Not authorized");
        _;
    }

    modifier beforeExercisePeriod() {
        require(_exerciseStatus() == 0, "Error: exercise period has passed");
        _;
    }

    modifier inExercisePeriod() {
        require(_exerciseStatus() == 1, "Error: not in exercise period");
        _;
    }

    modifier afterExercisePeriod() {
        require(_exerciseStatus() == 2, "Error: exercise period is not over");
        _;
    }

    function initialize (
        address _core,
        address _underlyingAsset,
        address _strikeAsset,
        uint256 _targetPrice,
        uint256 _expirationBlockNumber,
        uint256 _optionAmountPerStrike
    ) public {
        require(!initialized, "Error: have initialized");

        initialized = true;
        
        core = _core;
        
        underlyingAsset = _underlyingAsset;
        if (underlyingAsset == address(0)) {
            decimals = 18;
        } else {
            underlyingAssetDecimals = IERC20(_underlyingAsset).decimals();
        }
        
        strikeAsset = _strikeAsset;
        if (strikeAsset == address(0)) {
            decimals = 18;
        } else {
            decimals = IERC20(strikeAsset).decimals();
        }

        targetPrice = _targetPrice;
        expirationBlockNumber = _expirationBlockNumber;
        optionAmountPerStrike = _optionAmountPerStrike;
    }

    // 管理员结算期间不允许交易
    function _transfer(address from, address to, uint value) internal {
        require(_exerciseStatus() != 1, "Error: can not transfer in exercise perio");
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    // 铸造期权
    function mint(address user, uint _strikeAssetAmount) public payable onlyCore beforeExercisePeriod {
        
        if (strikeAsset == address(0)) {
            require(msg.value == _strikeAssetAmount, "Error: invalid amount of strike asset");
        } else {
            require(IERC20(strikeAsset).transferFrom(msg.sender, address(this), _strikeAssetAmount), "Error: transfer from error from controller to option");
        }
        
        uint optionAmount = _strikeAssetAmount.mul(strikeAssetAmountPerOption).div(decimals);
        sellerOption[user] = sellerOption[user].add(optionAmount);
        totalOptions = totalOptions.add(optionAmount);
        _mint(user, optionAmount);
    }

    // 管理员输入价格,并进行行权结算
    function exercise(uint _strikePrice) public onlyCore inExercisePeriod {
        strikePrice = _strikePrice;
        if (strikePrice <= targetPrice) {
            strikeAssetAmountPerOption = 0;
            expirableStrikeAssetAmount = 0;
        } else {
            uint maxUnderlyingAssetmountPerOption = strikePrice.div(optionAmountPerStrike);
            uint actUnderlyingAssetAmountPerOption = strikePrice.sub(targetPrice);
            uint underlyingAssetAmountPerOption = (maxUnderlyingAssetmountPerOption < actUnderlyingAssetAmountPerOption ? maxUnderlyingAssetmountPerOption : actUnderlyingAssetAmountPerOption);
            strikeAssetAmountPerOption = strikePrice.mul(decimals).div(underlyingAssetAmountPerOption);
            expirableStrikeAssetAmount = totalSupply.mul(strikeAssetAmountPerOption).div(decimals);
        }
        redeemableStrikeAssetAmount = address(this).balance.sub(expirableStrikeAssetAmount);
    }

    // 使用期权赎回
    function redeem(address payable user, uint _optionAmount) public onlyCore afterExercisePeriod {
        // 使用期权赎回strikeAsset，任何人只要有期权就可以赎回
        uint strikeAssetAmount = _optionAmount.mul(strikeAssetAmountPerOption).div(decimals);
        // 如果是创建者，返回剩余的strikeAsset
        uint createdOption = sellerOption[user];
        if (createdOption > 0) {
            strikeAssetAmount = strikeAssetAmount.add(redeemableStrikeAssetAmount.mul(createdOption).div(totalOptions));
            sellerOption[user] = 0;
        }
        if (strikeAsset == address(0)) {
            (user).transfer(strikeAssetAmount);
        } else {
            IERC20(strikeAsset).transfer(user, strikeAssetAmount);
        }
        _burn(user, _optionAmount);
    }

     function _exerciseStatus() internal returns (uint) {
        if (block.number < expirationBlockNumber) {
            return 0;
        } else if (strikePrice == 0) {
            return 1;
        } else {
            return 2;
        }
    }
}
