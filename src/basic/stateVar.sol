// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleStorage {
    // 状态变量
    uint256 public num;

    // 写状态变量：需要发送交易，消耗 gas
    function set(uint256 _num) public {
        num = _num;
    }

    // 读状态变量：不发送交易，不消耗 gas（用户不承担，但是节点承担 (查询消耗的 gas 较少)
    function get() public view returns (uint256){
        return num;
    }

    /*
    验证：
    1. 环境：Remix
    2. 部署：Sepolia 测试网
    3. 操作：
        a. 读状态：get 接口，没有调 MetaMask, 没有交易
        b. 写状态：set 接口，调 MetaMask, 发送交易，消耗 gas
    */
}