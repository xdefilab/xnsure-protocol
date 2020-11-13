pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./Storage.sol";

contract NsurePutToken is ERC20, ERC20Detailed, ReentrancyGuard, Storage {
    using SafeMath for uint256;

    //到期块数
    uint256 public expirationBlockNumber;

    //基础资产, WETH
    IERC20 public underlyingAsset;
    //基础资产位数
    uint256 public underlyingAssetDecimals;

    //行使资产, DAI
    IERC20 public strikeAsset;
    //行使资产位数
    uint256 public strikeAssetDecimals;

    //行使价格
    uint256 public strikePrice;

    //是否允许交易
    bool public isPublic = false;

    //put option
    uint256 public orderDirection = ORDER_OPTION_PUT;

    //vault
    //key: user, value: strike asset数量
    mapping(address => uint256) public vaultBalance;

    event LOG1(uint256 indexed a, string b);

    constructor(
        string memory _name,
        string memory _symbol,
        //标的资产
        IERC20 _underlyingAsset,
        //标的资产位数
        uint8 _underlyingAssetDecimals,
        //行使资产
        IERC20 _strikeAsset,
        //行使资产位数
        uint8 _strikeAssetDecimals,
        //行使价格
        uint256 _strikePrice,
        //到期块数
        uint256 _expirationBlockNumber
    ) public ERC20Detailed(_name, _symbol, 18) {
        underlyingAsset = _underlyingAsset;
        underlyingAssetDecimals = _underlyingAssetDecimals;
        strikeAsset = _strikeAsset;
        strikeAssetDecimals = _strikeAssetDecimals;
        strikePrice = _strikePrice;
        expirationBlockNumber = _expirationBlockNumber;
    }

    //是否过期
    function hasExpired() external view returns (bool) {
        return _hasExpired();
    }

    //未过期为true
    modifier notExpired() {
        if (_hasExpired()) {
            revert("ERROR: Option has expired");
        }
        _;
    }

    //已过期为true
    modifier alreadyExpired() {
        if (!_hasExpired()) {
            revert("ERROR: Option has not expired");
        }
        _;
    }

    //mint DAI并铸造期权Token
    //支付Strike Asset，锁在Vault
    //amount: 希望铸造的NsurePutToken数量
    function mint(uint256 amount) public notExpired nonReentrant {
        require(
            //支付DAI
            strikeAsset.transferFrom(
                msg.sender,
                address(this),
                amount.mul(strikePrice)
            ),
            "ERROR: strike asset transfer from sender"
        );

        //更新锁定的DAI数量
        vaultBalance[msg.sender] = vaultBalance[msg.sender].add(amount);

        //铸造等量的NsurePutToken
        _mint(msg.sender, amount.mul(XONE));
    }

    //the amount of underlying token locked in this contract
    function underlyingBalanceOf() external view returns (uint256) {
        return underlyingAsset.balanceOf(address(this));
    }

    //the amount of strike token locked in this contract
    function strikeBalance() external view returns (uint256) {
        return strikeAsset.balanceOf(address(this));
    }

    //到期前，调用方行权拿到strike asset
    //若已行权而没有足够的strike asset，则转换为underlying asset返回给调用方
    //amount: NsurePutToken数量
    function exercise(uint256 amount) external notExpired {
        uint256 underlyingAmount = amount.mul(
            10**uint256(underlyingAssetDecimals)
        );

        emit LOG1(underlyingAmount, "underlyingAmount");

        require(
            underlyingAsset.transferFrom(
                msg.sender,
                address(this),
                underlyingAmount
            ),
            "ERROR: transfer underlying token from user"
        );

        _burn(msg.sender, amount.mul(XONE));

        require(
            strikeAsset.transfer(msg.sender, amount.mul(strikePrice)),
            "ERROR: transfer strike token to caller"
        );
    }

    //到期后，赎回
    function redeem() external alreadyExpired {
        require(
            vaultBalance[msg.sender] > 0,
            "ERROR: user vaultBalance is zero"
        );

        //amount: NsureToken数量
        uint256 amount = vaultBalance[msg.sender];
        // Calculates how many underlying/strike tokens the caller will get back
        //当前strike asset余额
        uint256 currentStrikeBalance = strikeAsset.balanceOf(address(this));
        //strike asset应该收到的数量：NsureToken amount * strikePrice
        uint256 strikeToReceive = amount.mul(strikePrice);
        uint256 underlyingToReceive = 0;
        if (strikeToReceive > currentStrikeBalance) {
            // Ensure integer division and rounding
            uint256 strikeAmount = currentStrikeBalance.div(strikePrice);
            strikeToReceive = strikeAmount.mul(strikePrice);

            uint256 underlyingAmount = amount - strikeAmount;
            underlyingToReceive = underlyingAmount.mul(
                10**uint256(underlyingAssetDecimals)
            );
        }

        // Unlocks the underlying token
        vaultBalance[msg.sender] = vaultBalance[msg.sender].sub(amount);
        if (strikeToReceive > 0) {
            require(
                strikeAsset.transfer(msg.sender, strikeToReceive),
                "ERROR: Couldn't transfer back strike tokens to caller"
            );
        }
        if (underlyingToReceive > 0) {
            require(
                underlyingAsset.transfer(msg.sender, underlyingToReceive),
                "ERROR: Couldn't transfer back underlying tokens to caller"
            );
        }
    }

    function _hasExpired() internal view returns (bool) {
        return block.number >= expirationBlockNumber;
    }
}
