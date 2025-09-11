// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
delegatecall 特点：
1. 低级调用方式（类似 call)
2. A 合约调用 B 合约：B 中函数执行时，用的是 A 的上下文（如 msg.sender, msg.value)

*/

contract B {
    // 注意：存储布局必须与 contract A 完全一致
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }

}

contract A {

    uint256 public num;
    address public sender;
    uint256 public value;

    event DelegateResponse(bool success, bytes data);
    event CallResponse(bool success, bytes data);

    // 使用 delegatecall
    function setVarDelegateCall(address _contract, uint256 _num)
        public
        payable
    {
        // 预期结果：A 合约的状态变量修改了，B 合约不变（通过 remix 读取状态值确认）
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num));

        emit DelegateResponse(success, data);     
    }

    // 使用 call 
    function setVarCall(address _contract, uint256 _num) public payable {

        // 预期结果：B 合约的状态值改变，B 合约不变（通过 remix 查看变量确认）
        (bool success, bytes memory data) = _contract.call(
            abi.encodeWithSignature("setVars(uint256)", _num));

        emit CallResponse(success, data);
    }
}