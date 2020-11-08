pragma solidity 0.5.17;

interface IVault {
    function deposit(uint256) external;

    function withdraw(uint256 _shares) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}
