// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
一、interface 不能做什么：
1. 不能定义构造函数
2. 不能声明状态变量
3. 不能实现任何功能；

二、interface 能做什么
1. 可以继承自其他 interface
2. 所有函数必须 external
*/

// 示例1：
// 合约定义
contract Counter {
    uint256 public count;

    function increment() external {
        count += 1;
    }
}

// 接口定义
interface ICounter {
    function count() external view returns (uint256);

    function increment() external;
}

// 接口使用
contract MyContract {
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }

    function getCounter(address _counter) external view returns (uint256){
        return ICounter(_counter).count();
    }
}

// 示例2
// Uniswap example
interface UniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface UniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract UniswapExample {
    address private factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function getTokenReserves() external view returns (uint256, uint256) {
        address pair = UniswapV2Factory(factory).getPair(dai, weth);
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(pair).getReserves();
        return (reserve0, reserve1);
    }
}

