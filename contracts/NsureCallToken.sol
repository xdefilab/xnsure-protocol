pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./Storage.sol";

contract NsureCallToken is ERC20, ERC20Detailed, ReentrancyGuard, Storage {
    using SafeMath for uint256;

    address public core;

    //标的资产: DAI
    address public underlyingAsset;
    uint256 public underlyingAssetDecimals;

    //行使资产: ETH
    address public strikeAsset;
    uint256 public strikeAssetDecimals;

    // 目标价格
    uint256 public targetPrice;
    // 行权价格
    uint256 public strikePrice;

    //到期块数
    uint256 public expirationBlockNumber;

    // 行权的金额
    uint256 public strikeAssetAmountPerOption;
    uint256 public expirableStrikeAssetAmount;
    uint256 public redeemableStrikeAssetAmount;

    // 期权记录
    uint256 public totalOptions;

    uint256 callTokenDecimals = 18;

    //key: seller, value: option token amount
    mapping(address => uint256) public sellerOption;

    modifier onlyCore() {
        require(msg.sender == core, "Not authorized");
        _;
    }

    //到期日之前为true
    modifier beforeExercisePeriod() {
        require(_exerciseStatus() == 0, "Error: exercise period has passed");
        _;
    }

    //处于行权期内为true
    modifier inExercisePeriod() {
        require(_exerciseStatus() == 1, "Error: not in exercise period");
        _;
    }

    //到期日之后为true
    modifier afterExercisePeriod() {
        require(_exerciseStatus() == 2, "Error: exercise period is not over");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _core,
        address _underlyingAsset,
        uint8 _underlyingAssetDecimals,
        address _strikeAsset,
        uint8 _strikeAssetDecimals,
        uint256 _targetPrice,
        uint256 _expirationBlockNumber
    ) public ERC20Detailed(_name, _symbol, 18) {
        core = _core;

        underlyingAsset = _underlyingAsset;
        underlyingAssetDecimals = _underlyingAssetDecimals;

        strikeAsset = _strikeAsset;
        strikeAssetDecimals = _strikeAssetDecimals;

        targetPrice = _targetPrice;
        expirationBlockNumber = _expirationBlockNumber;
    }

    function hasExpired() external view returns (uint256) {
        return _exerciseStatus();
    }

    // 管理员结算期间不允许交易
    // TODO: check transferFrom()
    // function _transfer(
    //     address from,
    //     address to,
    //     uint256 value
    // ) internal {
    //     require(
    //         _exerciseStatus() != 1,
    //         "Error: can not transfer in exercise period"
    //     );
    //     balanceOf[from] = balanceOf[from].sub(value);
    //     balanceOf[to] = balanceOf[to].add(value);
    //     emit Transfer(from, to, value);
    // }

    // 铸造期权
    function mint(address user, uint256 _strikeAssetAmount)
        public
        payable
        onlyCore
        beforeExercisePeriod
    {
        if (strikeAsset == address(0)) {
            require(
                msg.value == _strikeAssetAmount,
                "Error: invalid amount of strike asset"
            );
        } else {
            require(
                IERC20(strikeAsset).transferFrom(
                    msg.sender,
                    address(this),
                    _strikeAssetAmount
                ),
                "Error: transfer from error from controller to option"
            );
        }

        uint256 optionAmount = _strikeAssetAmount
            .mul(optionAmountPerStrike);

        sellerOption[user] = sellerOption[user].add(optionAmount);
        totalOptions = totalOptions.add(optionAmount);
        _mint(user, optionAmount);
    }

    // 管理员输入价格,并进行行权结算
    function exercise(uint256 _strikePrice) public onlyCore inExercisePeriod {
        strikePrice = _strikePrice;
        if (strikePrice <= targetPrice) {
            strikeAssetAmountPerOption = 0;
            expirableStrikeAssetAmount = 0;
        } else {
            uint256 maxUnderlyingAssetmountPerOption = strikePrice.div(
                optionAmountPerStrike
            );
            uint256 actUnderlyingAssetAmountPerOption = strikePrice.sub(
                targetPrice
            );
            uint256 underlyingAssetAmountPerOption = (
                maxUnderlyingAssetmountPerOption <
                    actUnderlyingAssetAmountPerOption
                    ? maxUnderlyingAssetmountPerOption
                    : actUnderlyingAssetAmountPerOption
            );

            strikeAssetAmountPerOption = strikePrice.mul(10 ** callTokenDecimals).div(
                underlyingAssetAmountPerOption
            );
            expirableStrikeAssetAmount = totalSupply()
                .mul(strikeAssetAmountPerOption)
                .div(10 ** callTokenDecimals);
        }
        redeemableStrikeAssetAmount = address(this).balance.sub(
            expirableStrikeAssetAmount
        );
    }

    // 使用期权赎回
    function redeem(address payable user, uint256 _optionAmount)
        public
        onlyCore
        afterExercisePeriod
    {
        // 使用期权赎回strikeAsset，任何人只要有期权就可以赎回
        uint256 strikeAssetAmount = _optionAmount
            .div(optionAmountPerStrike);
        
        // 如果是创建者，返回剩余的strikeAsset
        uint256 createdOption = sellerOption[user];
        if (createdOption > 0) {
            strikeAssetAmount = strikeAssetAmount.add(
                redeemableStrikeAssetAmount.mul(createdOption).div(totalOptions)
            );
            sellerOption[user] = 0;
        }
        if (strikeAsset == address(0)) {
            (user).transfer(strikeAssetAmount);
        } else {
            IERC20(strikeAsset).transfer(user, strikeAssetAmount);
        }
        _burn(user, _optionAmount);
    }

    function _exerciseStatus() internal view returns (uint256) {
        if (block.number < expirationBlockNumber) {
            return 0;
        } else if (strikePrice == 0) {
            return 1;
        } else {
            return 2;
        }
    }

    /*************************  test  ***************************/
    function setExpirationBlockNumber(uint _expirationBlockNumber) public onlyCore {
        expirationBlockNumber = _expirationBlockNumber;
    }
}
