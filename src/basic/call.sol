// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
1. call 是什么
a. 低级函数，用于与其他合约交互

2. call 推荐用法
a. 通过 fallback 发送 Ether 时（没有 2300 gas 限制）

3. call 不推荐用法
a. 不推荐用于：已存在的函数调用
b. 原因：
    1. 不会触发 revert（即使目标函数 revert)
    2. 会绕过类型检查（正常函数调用，有类型检查）
    3. 不会检查函数是否存在（正常函数调用时，在编译时检查函数是否存在）
*/

contract Receiver {
    event Received(address caller, uint256 amount, string message);

    fallback() external payable {
        emit Received(msg.sender, msg.value, "fallback was called");
    }

    function foo(string memory _message, uint256 _x)
    public
    payable
    returns (uint256)
    {
        emit Received(msg.sender, msg.value, _message);

        return _x+1;
    }
}

contract caller {

    event Response(bool success, bytes data);

    // 1.调用存在的函数
    // 背景信息：合约调用者不知道 Receiver 的代码, 知道合约部署地址、被调函数
    function testCallfoo(address payable _addr) public payable {

        // call 也可以设置 gas 
        (bool success, bytes memory data) = _addr.call{
            value: msg.value, 
            gas: 5000
            }(abi.encodeWithSignature("foo(string, uint256)","call foo", 123));

            emit Response(success, data);
    }

    // 2.调用不存在的函数，触发 fallback 
    function testCallDoesNotExist(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value} (
            abi.encodeWithSignature("doesNotExist")
        );
        
        emit Response(success, data);
    }
}