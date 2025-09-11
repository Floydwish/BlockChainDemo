// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
try / catch 有用(能捕获到错误）的2个场景：
1. 调用外部合约的函数；
2. 创建合约时

*/

// 外部合约函数调用
contract Foo {
    address public owner;

    constructor(address _owner){
        require(_owner != address(0), "Invalid address"); // 输入0地址时触发错误，被 catch 捕获
        assert(_owner != 0x0000000000000000000000000000000000000001); // 输入地址1时触发错误，被 catch 捕获 （创建合约）
        owner = _owner;
    }

    function myFunc(uint256 x) public pure returns (string memory){
        require(x != 0, "Can not be zero");                // 输入 x=0 时触发错误，被 catch 捕获（外部调用）
        return "myFunc called";
    }

}

contract testTryCatch {
    event Log(string message);
    event LogBytes(bytes data);

    // 声明外部合约
    Foo public foo1;

    constructor(){
        // 合约创建：用于外部调用被 catch 的情况
        foo1 = new Foo(msg.sender);
    }

    // try/catch: 捕获外部接口调用时产生的错误
    // tryCatchExternalCall(0) => "external call failed"
    // tryCatchExternalCall(1) => "myFunc called"
    function tryCatchExternalCall(uint256 num) public{

        // try/catch: 必须声明返回值类型
        // 原因：编译器需要知道如何处理返回值（类型安全：明确返回值类型，避免类型推断错误）
        try foo1.myFunc(num) returns (string memory result){ // Foo 合约的 myFunc 明确返回 string memory
            emit Log(result);
        }
        catch{
                emit Log("external call failed");
        }
    }

    // try/catch: 捕获合约创建时产生的错误
    // tryCatchCreateContract(0x0000000000000000000000000000000000000000) => "Invalid address"
    // tryCatchCreateContract(0x0000000000000000000000000000000000000001) => ""
    // tryCatchCreateContract(0x0000000000000000000000000000000000000002) => "Foo created"
    function tryCatchCreateContract(address _owner) public {
        try new Foo(_owner) returns (Foo foo2) {
            // foo2 的使用
            emit Log("Foo created");
        }
        catch Error(string memory reason){
            // 捕获 revert() 和 require()
            emit Log(reason);
        }
        catch (bytes memory reason){
            // 捕获 assert() -> ""
            emit LogBytes(reason);
        }

    }
}
