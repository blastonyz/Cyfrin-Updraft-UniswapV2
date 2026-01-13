// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "uniswapv2-core/contracts/interfaces/IERC20.sol";
import "uniswapv2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IWETH} from "uniswapv2-periphery/contracts/interfaces/IWETH.sol";

contract UniswapV2SwapAmountsTest is Test {
    // Mainnet addresses - make sure to fork mainnet for testing
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address private constant UNISWAP_V2_ROUTER_02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private mkr = IERC20(MKR);
    IUniswapV2Router02 private router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);

    address private constant user = address(100);

    function test_getAmountsOut() public view {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;
        uint256 amountIn = 1e18;

        uint256[] memory amounts = router.getAmountsOut(amountIn, path);

        console2.log("weth", amounts[0]);
        console2.log("dai", amounts[1]);
        console2.log("mkr", amounts[2]);
    }

    function test_getAmountIn() public view {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountIn = 1e18;

        uint256[] memory amounts = router.getAmountsOut(amountIn, path);

        console2.log("weth", amounts[0]);
        console2.log("dai", amounts[1]);
        console2.log("mkr", amounts[2]);
    }

    function setUp() public {
        deal(user, 100 * 10e18);
        vm.startPrank(user);
        weth.deposit{value: 100 * 1e18}();
        IERC20(address(weth)).approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_swapExactTokensForTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountIn = 1e18;

        uint256 amountOutMin = 1;

        vm.startPrank(user);

        uint256[] memory amounts = router.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: user,
            deadline: block.timestamp
        });

        console2.log("weth", amounts[0]);
        console2.log("dai", amounts[1]);
        console2.log("mkr", amounts[2]);

        assertGe(mkr.balanceOf(user), amountOutMin, "MKR balance of user");
    }

    function test_swapTokensForExactTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountOut = 0.01 * 1e18;
        vm.startPrank(user);

        uint256[] memory amountsRequired = router.getAmountsIn(amountOut, path);
        uint256 amountInMax = amountsRequired[0];

        uint256[] memory amounts = router.swapTokensForExactTokens({
            amountOut: amountOut,
            amountInMax: amountInMax,
            path: path,
            to: user,
            deadline: block.timestamp
        });

        console2.log("weth", amounts[0]);
        console2.log("dai", amounts[1]);
        console2.log("mkr", amounts[2]);

        assertGe(mkr.balanceOf(user), amountOut, "MKR balance of user");
    }
}
