// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
Events 高级使用方式：
1. 实时更新：事件过滤、监控
2. 数据分析: 日志分析、解码
3. dApps 架构: 去中心化应用的事件驱动架构
4. 实时通知：事件订阅

最佳实践：
1. 索引合适的参数：方便高效过滤和搜索（如 地址通常索引，金额通常不索引）
2. 避免冗余事件：不要发出已被底层库或合约覆盖的事件（比如 MyToken is ERC20(OpenZeppelin), transfer时不用发出事件，因为 ERC20 已经发了）
3. 事件不能在 view 或 pure 函数中使用：因为事件存储日志，会改变区块链状态 （view/pure 发出日志，编译会报错）
4. gas 成本：发出事件有 gas 成本，特别是索引参数，可能影响合约的整体 gas 消耗 （合理索引，减少不必要的 gas 消耗）

*/

/*
事件驱动架构:
1.是什么
a. 用事件来协调和触发流程的不同阶段（而不是直接调用函数）
b. 状态管理：通过事件记录流程状态

2.基本流程
a.发起阶段 -> 发出事件 -> b.确认阶段 -> 发出事件 -> 3. 完成阶段

*/

contract EventDrivenArchitecture {

    // 交易初始化事件
    event TransferInitiated(
        address indexed from, address indexed to, uint256 value
    );

    // 交易确认事件
    event TransferConfirmed(
        address indexed from, address indexed to, uint256 value
    );

    mapping(bytes32 => bool) public transferConfirmations;

    // 交易初始化
    function initiateTransfer(address to, uint256 value) public {
        emit TransferInitiated(msg.sender, to, value);
        // ... 函数逻辑
        // 生成 transferId
        
    }

    // 交易确认（如确认转账）
    function confirmTransfer(bytes32 transferId) public {
        require(
            !transferConfirmations[transferId], "Transfer already confirmed"
        );
        
        transferConfirmations[transferId] = true;

        emit TransferConfirmed(msg.sender, address(this), 0);

        // ... 确认交易的逻辑
    }
}


/*
一、角色
1. 合约 A : 实现 IEventSubscriber ， 作为订阅者
2. 合约 B : EventSubscription， 作为订阅服务提供者

二、逻辑
1. 添加订阅：合约 A 调用 合约B 的subscribe
2. 有人转账：合约 B 发出事件；同时调用 合约A的 handleTransferEvent（合约 A 就知道了）

*/

// 事件订阅、实时更新
interface IEventSubscriber {
    function handleTransferEvent(address from, address to, uint256 value) external;
}

contract EventSubscription {

    // 事件
    event LogTransfer(address indexed from, address indexed to, uint256 value);

    // 保存订阅者列表
    mapping(address => bool) public subscribers;
    address[] public subscriberList;

    // 增加订阅
    function subscribe() public {
        require(!subscribers[msg.sender], "Already subscribed");
        subscribers[msg.sender] = true;
        subscriberList.push(msg.sender);
    }

    // 删除订阅
    function unsubcribe() public {
        require(subscribers[msg.sender], "Not subcribed");
        subscribers[msg.sender] = false;

        // 删除订阅：最后一个覆盖到删除位置，再删除最后一个
        for(uint256 i = 0; i< subscriberList.length; i++){
            if(subscriberList[i] == msg.sender){
                subscriberList[i] = subscriberList[subscriberList.length -1]; 
                subscriberList.pop();
                break;
            }
        }
    }

    // 有人调用 transfer 转账
    function transfer(address to, uint256 value)  public {
        emit LogTransfer(msg.sender, to, value);

        for(uint256 i = 0; i< subscriberList.length; i++){
            IEventSubscriber(subscriberList[i]).handleTransferEvent(msg.sender, to, value);
        }
    }
}