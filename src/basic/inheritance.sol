// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* 
1.Graph of inheritance
    A
   / \
  B   C
 / \ /
F  D,E

2. 基本信息
a. 继承的关键词：is
b. 父类如果需要继承的子类重写接口：用 virtual
c. 子类的实现：用 override

3. 逻辑
a. 继承顺序：基础 -> 派生（多层继承时）
b. 子类接口中调用父类接口的顺序：从右到左（多继承时，继承的是同层级，或没有层级关系的）

*/

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}

// 合约 B 继承 A
contract B is A {
    // 重写 foo 接口
    function foo() public pure virtual override returns (string memory) {
        return "B";
    }
}

// 合约 C 继承 A
contract C is A {
    // 重写 foo 接口
    function foo() public pure virtual override returns (string memory){
        return "C";
    }
}

// 多继承
// 当调用父合约的接口时：从右到左的顺序搜索
contract D is B, C {
    // 重写 foo 接口
    function foo() public pure override(B, C) returns (string memory) {
        // 这里会返回 “C"
        // 因为 C 是继承顺序中最右边的合约
        return super.foo();
    }
}

contract E is C, B {
    // 重写 foo 接口
    function foo() public pure override(C, B) returns (string memory){
        // 这里返回 "B"
        // 因为 B 是继承顺序中最右边的合约
        return super.foo();
    }
}

// 多层继承时:
// 继承顺序：基础合约 -> 派生合约
// 顺序不对时：编译时会报错
contract F is A, B {
    function foo() public pure override(A, B) returns (string memory) {
        return super.foo();
    }
}

/*
编译时报错：
Error: Compiler run failed:
Error (5005): Linearization of inheritance graph impossible

contract G is B, A {
    function foo() public pure override(B,A) returns (string memory) {
        return super.foo();
    }
}
*/


