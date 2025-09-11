// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
modifier 说明：

一、用途
1. 检查调用者身份
2. 验证输入
3. 防重入攻击
*/

contract FunctionModifier {
    address public owner;
    uint256 public x = 10;
    bool public locked;

    constructor() {
        // 设置合约部署者为合约所有者
        owner = msg.sender;
    }

    // 1. 创建 modifier: 
    // 作用：检查调用者是否为合约所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // 符号 '_'：仅用于 modifer
        // 作用：告诉 Solidity 执行后续的代码
        _;
    }

    // 2. 创建 modifer: 带参数
    // 作用：检查传入的参数是不是 0 地址
    modifier validAddress(address _addr){
        require(_addr != address(0), "Not valid address");
        _;
    }

    // modify 应用：
    // 顺序：按函数声明的顺序执行
    // 本函数：先执行 onlyOwner, 再执行 validAddress
    function changeOwner(address _newOwner) 
    public
    onlyOwner               
    validAddress(_newOwner)
    {
        owner = _newOwner;
    }

    // 3. 创建 modifer
    // 作用：防重入攻击
    modifier noReentrancy(){
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    // 防重入应用
    function decrement(uint256 i) public noReentrancy {
        x-=i;

        // 输入i=1: 正常减1
        // 输入i=2(满足i>1): 交易失败（因重入了 decrement, 触发 noReentrancy 的防重入机制）
        if(i > 1)      decrement(i-1);  
    }
}