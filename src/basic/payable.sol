// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
payable：
1.函数、地址加上 payable：可以接收 ether

*/

contract Payable {
    // 带有 payable 的地址可以发送 Ether(通过 transfer or send)
    address payable public owner;

    // 构造函数+payable: 可以接收 ether
    // 在合约部署时：可以接收 ether
    constructor() payable {
        owner = payable(msg.sender);
    }

    // 函数声明为 payable
    // 调用该函数时，携带 Ether
    // 该函数可以接收 Ether, 并自动存入合约，更新 balance
    // 函数体为空：不影响接收 ether
    function deposit() public payable {}

    // 函数未声明为 payable
    // 调用该函数时，如果携带 Ether
    // 该函数将抛出错误（因为没有 payable)
    function notPayable() public {}

    // 函数取出该合约中所有 Ether
    function withdraw() public {

        // 获取合约的 balance
        uint256 amount = address(this).balance;

        // 发送所有的 Ether 给 owner
        // "": 空数据，对于外部账户：直接转账（对于合约账户：触发目标合约的 fallback 函数）

        // 该方式：发送 ETH 的标准方式
        // 比 transfer 安全：不会因 gas 不足而失败（transfer 限定 2300 gas)
        // 比 send 安全：(send 限定 2300 gas， gas 不足时不抛出异常，返回 false, 交易失败)
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // 将本合约中的 Ether 发送到 输入的地址
    function transfer(address payable _to, uint256 _amount) public {

        // 输入的地址必须是 payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}