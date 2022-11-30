// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.10;

import "hardhat/console.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IFlashLoanSimpleReceiver} from "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import './JoeRouter02.sol';
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';



abstract contract FlashLoanSimpleReceiverBase is IFlashLoanSimpleReceiver {
    IPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    IPool public immutable override POOL;
    

    constructor(IPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        POOL = IPool(provider.getPool());

    }
}

contract SimpleFlashLoanV3 is FlashLoanSimpleReceiverBase {
    address wEthAddress = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    constructor(IPoolAddressesProvider _addressProvider)
        FlashLoanSimpleReceiverBase(_addressProvider)
    {}

    function withdraw(address asset) external {

        uint256 balance = IERC20(asset).balanceOf(address(this));
        require(balance > 0 , "no balance dude sorry not sorry");

        IERC20(asset).approve(address(this), balance);
        IERC20(asset).transfer(address(0x30b3Ac6A000931C1826b4B5e2C6AFc73BE46f5C1) , balance);
    }

     function approveRouter(address router) external  {
        WrappedEth(wEthAddress).approve(router, type(uint256).max);
    }

    function executetradess(
        IJoeRouter01 router,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address token
    ) external returns  (uint256) {

        bytes memory params = "";
        uint16 referralCode = 0;   
       
        console.log("prints");
        POOL.flashLoanSimple(address(this), token, amountIn, params, referralCode);
        console.log("win");



        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 18
        );
        console.log("tiger eye or cats eye");

        
       
       

        console.log("prints");
        POOL.flashLoanSimple(address(this), token, amountIn, params, referralCode);
        console.log("win");
       
         TransferHelper.safeApprove(token, address(0x794a61358D6845594F94dc1DB02A252b5b4814aD), amountIn);
        IERC20(token).approve(address(POOL), amountIn);



       // uint256[] memory amounts = router.swapExactTokensForTokens(
        //    amountIn,
        //    amountOutMin,
       //     path,
       //     address(this),
       //     block.timestamp + 99
      //  );
     //   console.log("tiger eye or cats eye");
    

      

        
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // Logic go here.
      

        // Approve the LendingPool contract allowance to *pull* the owed amount
        uint256 amountOwed = amount + premium;
        //FAUCET.mint(asset, premium);
        IERC20(asset).approve(address(POOL), amountOwed);

        return true;
    }

    function executeFlashLoan(address asset, uint256 amount) public {
        address receiverAddress = address(this);
       
        bytes memory params = "";
        uint16 referralCode = 0;
        console.log("prints");
        POOL.flashLoanSimple(receiverAddress, asset, amount, params, referralCode);
        console.log("masuk");
    }
}
