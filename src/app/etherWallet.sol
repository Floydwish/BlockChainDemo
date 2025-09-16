// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
最简钱包：
1.任何人可以发送 ETH
2.只有 owner 可以 withdraw
*/

contract EtherWallet {
    // 所有者地址
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);  // 将部署者设置为所有者，可接收 ETH
    }

    // 1. 接收：用于接收任何人发的 ETH
    receive() external payable {}

    // 2. 取款：仅允许 owner
    function withdraw(uint256 _amount) external {
        require(msg.sender == owner, "Not owner");
        payable(msg.sender).transfer(_amount);
    }

    // 3. 查询：获取钱包余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }


}