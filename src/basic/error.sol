// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/*
1. 错误的结果
- 交易回滚：交易中出现错误，所有状态回滚

2. 抛出错误的方法
a. require: 检查输入和条件是否满足
b. revert: 类似 require
c. assert: 被检查代码不能为 false (如果命中，意味着代码有问题)

3. 节省 gas
a. 使用自定义错误处理
 */

 contract Error {
    function testRequire(uint256 _i) public pure {
        // require 用于检查的条件：
        // 1. 输入
        // 2. 条件（函数执行前的条件检查）
        // 3. 调用其他函数的返回值（确保函数调用返回了预期值）
        require(_i > 10, "Input must be greater than 10");

    }

    function testRevert(uint256 _i) public pure {
        // revert 用途：
        // 1. 条件检查复杂时：用require 不方便
        // 2. 正常情况：推荐用 require
        if(_i <= 10){
            revert("Input must be greater than 10");   // 与上面的 require 功能相同
        }
    }

    uint256 public num;

    function testAssert() public view {
        // assert 用法：
        // 1.检查：内部错误、不变量 (不应该发生的情况，代码错误)
        // 2.gas 消耗：消耗所有剩余 gas（惩罚性的：消耗 gas limit 的全部）

        // 这里的情况：
        // 检查：num 的值应该永远都是0
        // 原因：这个接口中不可能会更新 num 值
        assert(num==0);
    }

    // 自定义错误（节省 gas : 比 require, revert)
    // 原因：
    // 1.字符串错误：require/revert (每个字符都消耗 gas)
    // 2.自定义错误：只消耗 数字ID
    // 深入说明：字符串 = 长度 + 内容 + 编码； 错误 ID = 只有数字
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);

    function testCustomError(uint256 _withdrawAmount) public view {
        uint256 bal = address(this).balance;
        if(bal < _withdrawAmount){
            revert InsufficientBalance({balance: bal, withdrawAmount: _withdrawAmount});
        }
    }
 }

 contract Account {
    uint256 public balance;
    uint256 public constant MAX_UINT = 2**256 -1;

    function deposit(uint256 _amount) public {
        uint256 oldBalance = balance;
        uint256 newBalance = balance + _amount;

        // 正常 newBalance > oldBalance; 否则就是溢出了
        require(newBalance > oldBalance, "Overflow");

        balance = newBalance;

        // 预期：deposit 后的 balance 永远 >= oldBalance
        assert(balance >= oldBalance); 
    }

    function withdraw(uint256 _amount) public {
        uint256 oldBalance = balance;

        // balance 必须大于 _amount, 否则就会下溢
        require(balance >= _amount, "Underflow");

        // 同样功能的检查
        if(balance < _amount){
            revert("Underflow");
        }

        balance -= _amount;

        // 预期：取款后的 balance 永远小于取款前的 oldBalance
        assert(balance <= oldBalance);
    }
 }