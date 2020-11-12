pragma solidity 0.5.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";

import "./NsurePutToken.sol";
import "./Storage.sol";

contract Controller is Storage {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Math for uint256;

    address public core;

    struct PutOption {
        // IERC20 underlyingAsset;
        // IERC20 strikeAsset;

        address NsurePutToken;
        uint256 expirationBlockNumber;
    }

    // NsureToken pairs
    //mapping(address => IVault) public vaults;

    event Pause(address indexed user);
    event Unpause(address indexed user);
    event Emergency(address indexed user);

    modifier onlyCore() {
        require(msg.sender == core, "Not Authorized, Only Core");
        _;
    }

    constructor(address _core, address _safuAddress) public {
        core = _core;
        safuAddress = _safuAddress;
    }

    //query option list

    //Before Option Expiration
    //mint new option
    function mintOption() external {}

    //add pair to uniswap
    function addOptionToUni() external {}

    //add liquidity to uniswap pool
    function addLiquidityToUni() external {}

    //After Option Expiration
    //rm liquidity from uniswap
    function rmLiquidityFromUni() external {}

    //rm pair from uniswap
    function rmOptionFromUni() external {}

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
