// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
1. 交易费：用 ether 支付
2. 类比：1 ether = 10^18 wei（1美元 = 100 美分）
*/

contract EtherUnits {
    // 1 wei == 1
    uint256 public oneWei = 1 wei;
    bool public isOneWei = (oneWei == 1);

    // 1 gwei == 10^9 wei
    uint256 public oneGwei = 1 gwei;
    bool public isOneGwei = (oneGwei == 1e9);

    // 1 ether == 10^18 wei
    uint256 public oneEther = 1 ether;
    bool public isOneEther = (oneEther == 1e18);

    /*
    ether 的双重身份：

    1.作为货币（以太币）：用于 支付 gas 费、转账交易、DeFi 协议等

    2.作为单位（1e18）：用于 数值计算、单位转换、精度处理等
    */
}