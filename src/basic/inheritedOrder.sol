// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* 继承关系
   A
 /  \
B   C
 \ /
  D
*/

/*
一、父合约调用的2种方式
1. 直接用父合约调用
a. 示例：A.foo()

2. 用 super 调用
a. 示例：super.foo()
*/

/* 验证情况：
1. 已在 Sepolia 测试验证
2. 方式：remix、sepolia-listener 工程

*/

contract A {
    // 使用 event 追踪函数调用顺序
    event Log(string message);

    function foo() public virtual {
        emit Log("A.foo called");
    }

    function bar() public virtual {
        emit Log("A.bar called");
    }
}

contract B is A {
    function foo() public virtual override {
        emit Log("B.foo called");
        A.foo();
    }

    function bar() public virtual override {
        emit Log("B.bar called");
        super.bar();
    }
}

contract C is A {
    function foo() public virtual override {
        emit Log("C.foo called");
        A.foo();
    }

    function bar() public virtual override {
        emit Log("C.bar called");
        super.bar();
    }
}

contract D is B, C {
    // Try:
    // - Call D.foo and check the transaction logs.
    //   Although D inherits A, B and C, it only called C and then A.
    // - Call D.bar and check the transaction logs
    //   D called C, then B, and finally A.
    //   Although super was called twice (by B and C) it only called A once.


    /* 调用 合约 D.foo() 的预期结果：C -> A (2个事件)
    1. C.foo called
    2. A.foo called

    */
    function foo() public override(B, C) {
        super.foo();
    }


    /* 调用 合约 D.bar() 的预期结果：C -> B -> A （3个事件）
    1. C.bar called
    2. B.bar called
    3. A.bar called
    */
    function bar() public override(B, C) {
        super.bar();
    }
}