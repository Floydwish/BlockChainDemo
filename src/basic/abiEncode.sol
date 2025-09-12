// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
1.ABI 编码演进过程，常见方式对比：

┌─────────────────────┬──────────┬──────────┬──────────┬─────────────────────┬─────────────────────┐
│ 编码方法             │ 安全性     │ 性能     │ 灵活性    │ 优点                 │ 缺点                │
├─────────────────────┼──────────┼──────────┼──────────┼─────────────────────┼─────────────────────┤
│ call                │ 低       │ 高        │ 最高     │ 最灵活，可调用任意      │ 无类型检查，容易出错   │
│                     │          │          │          │ 函数                 │                     │
├─────────────────────┼──────────┼──────────┼──────────┼─────────────────────┼─────────────────────┤
│ encodeWithSignature │ 低       │ 中        │ 高       │ 简单直观，支持动态     │ 容易拼写错误，类型     │
│                     │          │          │          │ 函数名               │ 不检查               │
├─────────────────────┼──────────┼──────────┼──────────┼─────────────────────┼─────────────────────┤
│ encodeWithSelector  │ 中       │ 高        │ 中       │ 比签名更高效，避免     │ 仍可能类型错误，需要    │
│                     │          │          │          │ 字符串计算            │ 接口定义             │
├─────────────────────┼──────────┼──────────┼──────────┼─────────────────────┼─────────────────────┤
│ encodeCall          │ 高       │ 高        │ 低       │ 完全类型安全，编译     │ 灵活性较低，需要接口   │
│                     │          │          │          │ 时检查               │ 定义                │
└─────────────────────┴──────────┴──────────┴──────────┴─────────────────────┴─────────────────────┘

2.使用场景
┌─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┐
│ 推荐顺序              │ 使用场景             │ 错误类型             │ 示例                 │
├─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│ 1. encodeCall       │ 生产环境             │ 编译时错误            │ abi.encodeCall(     │
│                     │                     │                     │ IERC20.transfer,    │
│                     │                     │                     │ (to, amount))       │
├─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│ 2. encodeWithSelector│ 性能要求高           │ 类型错误             │ IERC20.transfer.    │
│                     │                     │                     │ selector            │
├─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│ 3. encodeWithSignature│ 动态场景           │ 拼写错误              │ "transfer(address,  │
│                     │                     │                     │ uint256)"           │
├─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│ 4. call             │ 特殊需求             │ 运行时错误            │ _contract.call(data)│
└─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┘
*/

// 定义接口
// 只声明函数签名，不实现
interface IERC20 {
    function transfer(address, uint256) external;
}

// 简单代币合约
// 实现空的 transfer 函数
contract Token{
    function transfer(address, uint256) external {}
}

// ABI 编码合约
// 4 种不同的 ABI 编码方式
contract AbiEncode {

    // 1.call: 低级调用，灵活性高，不检查类型，容易运行时错误
    function test(address _contract, bytes calldata data) external {
        (bool success, ) = _contract.call(data);
        require(success, "call failed");
    }

    
    // 2.encodeWithSignature: 函数签名编码，不检查类型，容易拼写错误，运行时错误
    function encodeWithSignature(address to, uint256 amount) 
        external
        pure
        returns (bytes memory)
    {
        // 不会检查 "transfer(address,uint256)" （拼写错误）
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    // 3.encodeWithSelector:选择器编码，容易类型错误
    function encodeWithSelector(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // 不检查类型：(IERC20.transfer.selector, to, amount)
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    // encodeCall: 类型安全编码，编译时发现错误
    function encodeCall(address to, uint256 amount)
        external
        pure 
        returns (bytes memory)
    {
        // 检查类型：类型错误无法通过编译
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}

