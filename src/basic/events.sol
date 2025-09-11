// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
Events:
1. 是什么：
- 记录到以太坊区块链的日志

2. 用途：
a. 更新前端：前端可以监听日志，更新 UI
b. 便宜的存储：比状态变量更便宜

3. 其他
a. 可过滤：indexed 参数支持过滤
b. 记录：永久记录在区块链上

4. 用法
a. 声明：event...
b. 触发：emit...
*/

contract Event {
    // 1. Event 声明
    // 索引参数数量：最多3个
    // 索引参数作用：用于作为过滤条件
    event Log(address indexed sender, string message);
    event AnotherLog();

    function test() public {
        emit Log(msg.sender, "Hello");
        emit Log(msg.sender, "EVM");

        emit AnotherLog();
    } 

}