// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
library 特点：
1. 是特殊的 contract 
  a.不能有状态变量
  b.不能接收 ether
  c.主要用途：提供可重用的函数逻辑

2. 如果 library 中所有函数都是 internal:
  a.不需要单独部署库
  b.编译器会把库直接嵌入合约
  c.gas 成本更低（不需要外部调用）

3. 如果 library 有 public、external 函数：
  a.库必须先单独部署到链上
  b.合约部署时通过链接引用已部署的library
  c.gas 成本更高（需要外部调用）

*/

library Math {
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0 (default value)
    }
}

contract TestMath {
    function testSquareRoot(uint256 x) public pure returns (uint256){
        return Math.sqrt(x);
    }
}