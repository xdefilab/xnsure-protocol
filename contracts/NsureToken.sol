pragma solidity 0.5.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ERC20Detailed
} from "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract NsureToken is ERC20, ERC20Detailed {
    address public core;

    /**
     * This option is expired after this blocknumber.
     */
    uint256 public expirationBlockNumber;

    constructor(
        address _core,
        string memory _name,
        string memory _symbol,
        uint256 _expirationBlockNumber
    ) public ERC20Detailed(_name, _symbol, 18) {
        core = _core;
        expirationBlockNumber = _expirationBlockNumber;
    }

    modifier onlyCore() {
        require(msg.sender == core, "Not authorized");
        _;
    }

    /**
     * Check if the option has expired.
     */
    function hasExpired() external view returns (bool) {
        return _hasExpired();
    }

    modifier notExpired() {
        if (_hasExpired()) {
            revert("Option has expired");
        }
        _;
    }

    modifier alreadyExpired() {
        if (!_hasExpired()) {
            revert("Option has not expired");
        }
        _;
    }

    function mint(address account, uint256 amount) public onlyCore {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyCore {
        _burn(account, amount);
    }

    function burnForSelf(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _hasExpired() internal view returns (bool) {
        return block.number >= expirationBlockNumber;
    }
}
