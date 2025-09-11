// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
变量存储位置分3类：
1. storage: 状态变量（存储在区块链）
2. memory: 函数内部变量（存储在内存中，函数调用结束后回收）
3. calldata: 主要用于 external 的函数参数（函数执行完自动清理）、只读
4. transient storage: 临时状态变量（不影响状态根，交易结束后清理）

gas 对比：
storage > memory > calldata
*/

contract DataLocations {
    // 状态变量
    uint256[] public arr;
    mapping(uint256 => address) map;

    // 临时状态变量（不参与状态根计算）
    uint256 public transient transientValue; // 临时存储状态变量

    struct MyStruct {
        uint256 foo;
    }

    mapping(uint256 => MyStruct) myStructs;
    
    
    function f() public {
        // 传入状态变量
        _f(arr, map, myStructs[1]);

        // 从 mapping 中获取结构体
        MyStruct storage myStruct = myStructs[1];

        // 在 memory 中创建结构体
        MyStruct memory myMemStruct = MyStruct(0);
    }


    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal{
        // do sth with storage variables
    }

    // 返回 memory 变量
    function g(uint256[] memory _arr) public returns (uint256[] memory){
        // do sth with memory 数组
    }

    function h(uint256[] calldata _arr) external {
        // do sth with calldata 数组
    }

    function transientExample() public {
        transientValue = 1; // 不影响状态根，在本次交易有效
    }

}