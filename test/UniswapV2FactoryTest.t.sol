// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "uniswapv2-core/contracts/interfaces/IERC20.sol";
import "uniswapv2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "uniswapv2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IWETH} from "uniswapv2-periphery/contracts/interfaces/IWETH.sol";

contract TestToken is ERC20 {
    constructor() ERC20("test", "TEST") {}
}

contract UniswapV2FactoryTest is Test {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    IWETH private weth = IWETH(WETH);
    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    function test_createPair() public {
        TestToken token = new TestToken();

        address pair = factory.createPair(address(token), WETH);

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        if (address(token) < WETH) {
            assertEq(token0, address(token), "token0 debe ser TEST");
            assertEq(token1, WETH, "token1 debe ser WETH");
        } else {
            assertEq(token0, WETH, "token0 debe ser WETH");
            assertEq(token1, address(token), "token1 debe ser TEST");
        }
    }
}
