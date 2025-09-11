// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
一、发送 Ether 的3种方式：
1. transfer: 2300 gas 限制，失败了抛出错误
2. send: 2300 gas 限制，返回 bool
3. call: 使用所有或者设置的 gas, 返回 bool （推荐使用）

二、推荐的发送方式：call
1. 使用方式
    a. call 接口
    b. 结合：防重入

2. 如何防重入
    a. 先更新状态变量，再转账（调用其他合约）
    b. 使用防重入的 modifier

三、接收 Ethter 的种方式：
1. receive() external payable: msg.data 为空时被调用  （原因：纯转账，以太坊设计机制）
2. fallback() external payable：msg.data 不为空时被调用（原因：默认函数，转账+有数据时、函数不存在时调用）

四、判断接收 Ether 函数的逻辑
           send Ether
               |
         msg.data is empty?
              /       \
            yes        no
            /            \
    receive() exists?   fallback()
         /      \
        yes     no
        /         \
    receive()   fallback()

*/

contract ReceiveEther {

    // 调用 receive 接收 Ether: msg.data 为空
    receive() external payable {}

    // 调用 callback 接收 Ether: msg.data 不为空
    fallback() external payable {}

    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
}

contract SendEther {
    
    function sendViaTransfer(address payable _to) public payable {
        // 该接口不推荐使用: 以前用于发送 Ether
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) public payable {
        // 该接口不推荐使用：以前用于发送 Ether
        // 接口返回 bool: 用于判断是否成功
        bool success = _to.send(msg.value);
        require(success, "Failed to send Ether");
    }

    function sendViaCall(address payable _to) public payable {

        // 该接口推荐使用：当前推荐方法，用于发送 Ether
        // 返回 bool: 用于判断是否成功
        (bool success, bytes memory data) = _to.call{value: msg.value}("");
        require(success, "Failed to send Ether");
    }
}

