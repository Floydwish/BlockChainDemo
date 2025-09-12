// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
本文件作用：
1.提供给 import.sol 引入
*/

struct Point {
    uint256 x;
    uint256 y;
}

error Unauthorized(address caller);

function add(uint256 x, uint256 y) pure returns (uint256){
    return x+y;
}

contract Example {
    string public name = "example";
}