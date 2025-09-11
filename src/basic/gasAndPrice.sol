// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
一、gas 基础
1.gas 理解 (EIP1559 以前)
 a. 是什么：计算工作量的单位，每个操作消耗固定的 gas

2. gas 双重限制
 a. gas limit: 用户限制每笔交易的最大 gas 量
 b. block gas limit: 协议限制，每一个区块最大 gas 数量

二、传统竞价模式（EIP-1559 以前的计算方法
1.交易费用怎么算：
交易费 = gas 消耗量 * gas 价格

 2. 传统模式的问题 (竞价)
 a. 用户利益损失：用户盲目抬高 gas 价格，支付不必要的费用
 b. 用户体验差：gas 价格波动剧烈
 c. 矿工得利：矿工获得全部费用，没有燃烧机制
 d. 鼓励矿工作恶：矿工倾向于抬高 gas 费

 三、当前模式（EIP-1559 的计算方法）
 1. EIP-1559 下
 交易费 = gas used * (base fee + priority fee)
 交易费 = gas 消耗量 * (基础费 + 优先费)

 2.收益分配
 base fee: 网络自动、动态计算，燃烧销毁（通缩机制； 拥堵时 base fee 上涨，抑制需求； 空闲时下降，鼓励使用）
 priority fee: 用户设置，给矿工的小费 （激励矿工，优先打包用户的交易； 根据交易的紧急程度设置。 举例: 交易时会允许用户选择不同的优先级）

 3.优点（相对传统竞价模式）
 1. 用户利益：避免了盲目抬高 gas 价格；
 2. 用户体验：自动调节机制下，gas 价格相对平缓
 3. 燃烧机制：基础费用燃烧掉，通缩模式
 4. 激励机制：收益方式改变，避免了矿工作恶，推高 gas 费

 4.用户设置：
 a. max fee: 愿意支付的最大总费用（每单位 gas)
 b. max priority fee: 愿意支付的最大优先费 (每单位 gas)
 c. gas limit: 愿意消耗的最大 gas 数量
 d. 实际每单位 gas 费用：min(max fee, base fee + priority fee)
 e. gas limit 防失败；max fee 防高额；priority fee 控优先级

 5.用户不能设置
 a. base fee: 自动计算 (网络拥堵状况决定)
 b. gas used: 由实际消耗决定。
 c. 最终费用 = gas used * min(max fee, base fee + priority fee)
*/

contract Gas {
    uint256 public i = 0;

    // Gas 耗尽 -> 交易失败 -> 状态回滚 -> Gas 不退还

    // 1.这笔交易会花光所有 gas, 并因此导致交易失败
    // 2.交易失败，状态变量不会变化（交易回滚）
    // 3.已经花费的 gas, 不会退回。
    function forever() public {
        // 结果：直到所有的 gas 花光，交易停止，失败
        while(true){
            i += 1;
        }
    }
}