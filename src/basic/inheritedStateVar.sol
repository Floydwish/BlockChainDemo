// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
前置说明：
1. B 继承 A 合约之后：状态变量不 (像 function 一样 ) 重写
2. 正确方式：B 不重写 A 的状态变量，直接用该状态变量（如下面的 示例 合约C)
*/

contract A {
    string public name = "contract A";

    function getName() public view returns (string memory) {
        return name;
    }
}

// 不允许重写状态变量
// contract B 编译报错
/*
contract B is A {
    // 错误的方式：
    string public name = "contract B";
}
*/

contract C is A {
    // 正确的方式：重写继承的状态变量
    constructor() {
        name = "contract C";
    }

    // 查看结果
    // C.getName() 会返回 "contract C"
}

