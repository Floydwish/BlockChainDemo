// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Immutable {
    // immutable 变量：类似常量（相同点：初始化赋值，之后不可变）
    // 常用于：在构造函数中设置（仅部署时初始化，后续不变）
    address public immutable myAddr;
    uint256 public immutable myUint;

    constructor(uint256 _myUint){
        myAddr = msg.sender;
        myUint = _myUint;
    }
}