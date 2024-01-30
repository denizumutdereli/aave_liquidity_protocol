// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10; // aave compatibility

import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract Market {
    address payable owner;
    IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    IPool public immutable POOL;

    address private immutable linkTokenAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    IERC20 private link;

    event LiquiditySupplied(address indexed onBehalfOf, address indexed _token, uint256 indexed _amount);
    event LiquidityWithdrawn(address indexed to, address indexed _token, uint256 indexed _amount);

    modifier onlyOwner {
        require(msg.sender == owner, "only the owner");
        _;
    }

    constructor(address _addressProvider) {
        ADDRESSES_PROVIDER = IPoolAddressesProvider(_addressProvider);
        POOL = IPool(ADDRESSES_PROVIDER.getPool());
        owner = payable(msg.sender);
        link = IERC20(linkTokenAddress);
    }

    function supplyLiquidity(address _token, uint256 _amount) external {
        address asset = _token;
        uint256 amount = _amount;
        address onBehalfOf = address(this);
        uint16 referralCode = 0;
        POOL.supply(asset, amount, onBehalfOf, referralCode);
        emit LiquiditySupplied(onBehalfOf, asset, amount);
    }

    function withdrawLiquidity(address _token, uint256 _amount) external returns(uint256) {
        address asset = _token;
        address to = address(this);
        uint256 amount = _amount;
        uint256 withdrawn = POOL.withdraw(asset, amount, to);
        emit LiquidityWithdrawn(to, asset, amount);
        return withdrawn;
    }

    function getUserAccountData(address user) external view returns(
        uint256 totalCollateralBase,
        uint256 totalDebtBase,
        uint256 availableBorrowsBase,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    ) {
        return POOL.getUserAccountData(user);
    }

    function approveLINK(uint256 _amount, address _poolContractAddress) external returns(bool){
        return link.approve(_poolContractAddress, _amount);
    }

    function allowanceLINK(address _poolContractAddress) external view returns(uint256) {
        return link.allowance(address(this), _poolContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns(uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(owner, token.balanceOf(address(this)));
    }

    receive() external payable {}
}