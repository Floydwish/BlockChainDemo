// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AssemblyError {

    // 测试 gas 消耗：1508
    function yul_revert(uint256 x) public pure {
        assembly {
            // revert(p, s) - end execution
            //                revert state changes
            //                return data mem[p…(p+s))
            if gt(x, 10) { revert(0, 0) }   // gt: great than
            // revert(p, s)  p:内存指针，指向待返回的错误数据；s:数据长度，要返回的字节数
        }
    }

    // 测试 gas 消耗：5699
    function solidity_revert(uint256 x) public pure {
        require(x <= 10, "Invalid number");
    }
}