// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract constants {
    // 常量：编译时确定，运行时只读、全大写命名
    // 优点：省 gas （读取常量不需要 gas）
    address public constant MY_ADDRESS = 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3;
    uint256 public constant MY_UINT = 123;
}