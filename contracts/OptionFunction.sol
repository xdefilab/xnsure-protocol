pragma solidity 0.5.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ERC20Detailed
} from "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./Const.sol";

contract NsureToken is ERC20, ERC20Detailed, ReentrancyGuard, Constants {
    
    address public core;

    //到期块数
    uint256 public expirationBlockNumber;

    //标的资产, DAI
    IERC20 underlyingAsset;
    //标的资产位数
    uint256 underlyingAssetDecimal;
    
    //行使资产, WETH
    IERC20 strikeAsset;
    //行使价格
    uint256 strikePrice;

    //是否允许交易
    bool isPublic = false;

    // 1个行使资产可以创建多少个期权
    uint strikeRate;

    //vault, 锁定underlying asset
    mapping(address => uint256) public vaultBalance;

    constructor(
        address _core,
        string memory _name,
        string memory _symbol,
        //标的资产
        IERC20 _underlyingAsset,
        //标的资产位数
        uint8 _underlyingAssetDecimals,
        //行使资产
        IERC20 _strikeAsset,
        //行使价格
        uint256 _strikePrice,
        //到期块数
        uint256 _expirationBlockNumber
    ) public ERC20Detailed(_name, _symbol, 18) {
        core = _core;
        underlyingAsset = _underlyingAsset;
        underlyingAssetDecimal = _underlyingAssetDecimals;
        strikeAsset = _strikeAsset;
        strikePrice = _strikePrice;
        expirationBlockNumber = _expirationBlockNumber;
    }

    modifier onlyCore() {
        require(msg.sender == core, "Not authorized");
        _;
    }

    //是否过期
    function hasExpired() external view returns (bool) {
        return _hasExpired();
    }

    //未过期为true
    modifier notExpired() {
        if (_hasExpired()) {
            revert("Option has expired");
        }
        _;
    }

    //已过期为true
    modifier alreadyExpired() {
        if (!_hasExpired()) {
            revert("Option has not expired");
        }
        _;
    }

    //收取Strike Asset，铸造期权Token
    function mint(uint256 amount) public beforeExpiration {
        require(strikeAsset.transferFrom(msg.sender, address(this), amount.mul(strikePrice)), "ERROR: strike asset transfer from sender");

        vaultBalance[msg.sender] = lockedBalance[msg.sender].add(amount);
        _mint(msg.sender, amount.mul(XONE));

        //isPublic = true;
    }

    //burn期权Token，解锁Strike Asset
    function burn(uint256 amount) public beforeExpiration {
        require(amount <= vaultBalance[msg.sender], "ERROR: strike asset not enough");

        vaultBalance[msg.sender] = vaultBalance[msg.sender].sub(amount);
        _burn(msg.sender,, amount.mul(XONE));

        require(strikeAsset.transfer(msg.sender, amount.mul(strikePrice)), "ERROR: strike asset can not transfer back");
    }

    //the amount of underlying token locked in this contract
    function underlyingBalanceOf() external view returns (uint256) {
        return underlyingAsset.balanceOf(address(this));
    }

    //the amount of strike token locked in this contract
    function strikeBalance() external view returns (uint256) {
        return strikeAsset.balanceOf(address(this));
    }

    function withdraw() external afterExpiration {
        _redeem(lockedBalance[msg.sender]);
    }

    function liquidation() external afterExpiration {}

    function _redeem(uint256 amount) internal {
    }

    function _hasExpired() internal view returns (bool) {
        return block.number >= expirationBlockNumber;
    }
}
