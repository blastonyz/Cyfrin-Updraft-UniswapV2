// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "uniswapv2-core/contracts/interfaces/IERC20.sol";
import "uniswapv2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "uniswapv2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IWETH} from "uniswapv2-periphery/contracts/interfaces/IWETH.sol";

contract UniswapV2Liquidity is Test {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant UNISWAP_V2_ROUTER_02 =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address private constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; 

    IERC20 private dai = IERC20(DAI);
    IUniswapV2Router02 private router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);

    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);   

    IWETH private weth = IWETH(WETH);
 
    address private constant user = address(100);

    function setUp() public {
        deal(user, 100 * 1e18);
        vm.startPrank(user);
        weth.deposit{value: 100 * 1e18}();
        IERC20(address(weth)).approve(address(router), type(uint256).max);
        vm.stopPrank();

        deal(DAI, user, 1000000 * 1e18);
        vm.startPrank(user);
        dai.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_addLiquidity() public {
        address pair = factory.getPair(DAI, WETH);

        vm.startPrank(user);

        (uint256 amountA, uint256 amountB, uint256 Liquidity) = router
            .addLiquidity({
                tokenA: DAI,
                tokenB: WETH,
                amountADesired: 1000 * 1e18,
                amountBDesired: 1 * 1e18,
                amountAMin: 1,
                amountBMin: 1,
                to: user,
                deadline: block.timestamp
            });

        vm.stopPrank();

        console2.log("DAI", amountA);
        console2.log("WETH", amountB);
        console2.log("LIQ", Liquidity);

        assertGt(IERC20(pair).balanceOf(user), 0, "LP = 0 ");
    }

    function test_removeLiquidity() public {
         address pair = factory.getPair(DAI, WETH);

        vm.startPrank(user);

        (uint256 amountA, uint256 amountB, uint256 Liquidity) = router
            .addLiquidity({
                tokenA: DAI,
                tokenB: WETH,
                amountADesired: 1000 * 1e18,
                amountBDesired: 1 * 1e18,
                amountAMin: 1,
                amountBMin: 1,
                to: user,
                deadline: block.timestamp
            });

        console2.log("DAI", amountA);
        console2.log("WETH", amountB);
        console2.log("LIQ", Liquidity);

        IERC20(pair).approve(address(router), type(uint256).max);

        (uint256 amountA1,uint256 amountB2) =  router.removeLiquidity({
            tokenA: DAI,
            tokenB: WETH,
            liquidity: Liquidity,
            amountAMin: 1,
            amountBMin: 1,
            to: user,
            deadline: block.timestamp
            });

        vm.stopPrank();

        console2.log("DAI2", amountA1);
        console2.log("WETH2", amountB2);

        assertEq(IERC20(pair).balanceOf(user),0, "LP = 0");   
    }
}
