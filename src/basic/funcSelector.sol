// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
函数选择器：
1. 是什么：calldata 的前4个字节作为函数选择器
2. 用途：指定要调用哪个函数
3. 如何得到：abi.encodeWithSignature("transfer(address,uint256)", 0xAddress, 123);

4. 如何使用可以省 gas
 a. 方式：预计算函数选择器（避免运行时计算）
 b. 适用场景：频繁调用的函数
*/

contract FunctionSelector {
    function getSelector(string calldata _func)
        external
        pure
        returns (bytes4)
    {
        return bytes4(keccak256(bytes(_func)));
    }
}