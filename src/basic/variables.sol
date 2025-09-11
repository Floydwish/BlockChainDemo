// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
Solidity 中的 3 种类型的变量：

1.local: 局部变量
    a. 声明位置：函数内部
    b. blockchain：不保存

2.state：状态变量
    a. 声明位置：函数外部
    b. blockchain：保存

3.global：全局变量 (全局：针对以太坊网络而言)
    a. 位置: 以太坊网络 和 EVM
    b. 内容：区块信息（如 block.number）、交易信息(如 msg.sender)、地址信息(如 address(this).balance)

*/

contract variables{
    // 状态变量存储在 blockchain
    string public text = "hello";
    uint256 public num = 123;

    function doSomething() public view {
        // 局部变量不会存储在 blockchain, 尽在函数内部有效
        uint256 i = 456;

        // 全局变量
        uint256 blockNumber = block.number;
        address sender = msg.sender;
        uint256 balance = address(this).balance;
    }
}