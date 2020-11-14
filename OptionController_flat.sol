
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/interfaces/IUniswapV2Router02.sol

pragma solidity 0.5.17;

interface IUniswapV2Router02{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        uint optionDeadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB, uint deadline) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

// File: contracts/Const.sol

pragma solidity 0.5.17;

contract Constants {
    uint256 internal constant XONE = 10**18;

    //system status
    uint8 public constant STATUS_NORMAL = 0;
    uint8 public constant STATUS_EMERGENCY = 1;

    //order direction
    uint256 public constant ORDER_OPTION_CALL = 11;
    uint256 public constant ORDER_OPTION_PUT = 12;
}

// File: contracts/Storage.sol

pragma solidity 0.5.17;


contract Storage is Constants {
    //uniswap
    address public uniswapFactoryAddress;

    uint8 public systemStatus = STATUS_NORMAL;
    bool public systemPaused = false;

    //SAFU address
    address public safuAddress;
    //SAFU balance
    int256 public safuBalance;

    //1个行使资产可以创建多少个期权
    uint256 public optionAmountPerStrike = 5;
}

// File: contracts/NsureCallToken.sol

pragma solidity 0.5.17;







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
            .mul(strikeAssetAmountPerOption)
            .div(callTokenDecimals);
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

            strikeAssetAmountPerOption = strikePrice.mul(callTokenDecimals).div(
                underlyingAssetAmountPerOption
            );
            expirableStrikeAssetAmount = totalSupply()
                .mul(strikeAssetAmountPerOption)
                .div(callTokenDecimals);
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
            .mul(strikeAssetAmountPerOption)
            .div(callTokenDecimals);
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
}

// File: contracts/OptionController.sol

pragma solidity 0.5.17;







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
