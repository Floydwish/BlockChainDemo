// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
一、fallaback 会被调用的情况：
1. 被调用函数不存在；
2. 直接发送 Ether, 不带数据，但是 receive 不存在；
3. 直接发送 Ether, 带数据。

图示：
                send Ether
                    |
           msg.data is empty?
                /           \
            yes             no
             |                |
    receive() exists?     fallback()
        /        \
     yes          no
      |            |
  receive()     fallback()


二、其他
1. fallback 有 2300 gas limit: 当发送方是 transfer 或 send 时（因为这是 transfer 和 send 的限制）
2. fallback 在输入、输出中：可选接收 data
*/

contract Fallback {
    event Log(string func, uint256 gas);

    // fallback 必须声明为 external (声明为 payable 表示可以接收 Ether)
    fallback() external payable {

        // 发送方是 send / transfer: 存在 2300 gas 限制
        // 发送方是 call: 所有剩余 gas
        emit Log("fallback", gasleft());
    }

    // receive 被调用：当 msg.data 为空时
    receive() external payable {
        emit Log("receive", gasleft());
    }

    // 获取余额
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
}

contract SendToFallback{

    // 调用方 transfer
    // 接收方：fallback
    // 限制：2300 gas
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    // 调用方：call
    // 接收方：fallback
    // 限制：所有剩余 gas
    function callFallback(address payable _to) public payable {
        (bool success, ) = _to.call{value: msg.value}("");
        require(success, "Failed to send Ether");
    }
}

/*
一、调用流程（代理模式演示：fallback 作为 透明代理 转发调用）
    // 1. 部署合约
    Counter counter = new Counter();                                       // 目标合约
    FallbackInputOutput proxy = new FallbackInputOutput(address(counter)); // 代理合约
    TestFallbackInputOutput;                                               // 测试合约

    // 2. 获取函数调用数据（获取目标合约的接口）
    (bytes memory getData, bytes memory incData) = testContract.getTestData();
    // getData = abi.encodeCall(Counter.get, ())
    // incData = abi.encodeCall(Counter.inc, ())

    // 3. 通过代理调用（测试合约 -> 代理合约 -> 目标合约）
    testContract.test(address(proxy), getData);  // 调用Counter.get()
    testContract.test(address(proxy), incData);  // 调用Counter.inc()

    // 4. 查看结果
    通过 remix 可以看到 事件日志（包含返回的count 值）

二、应用场景
1. 升级代理：通过更换 target 地址来升级合约
2. 权限控制：在代理层添加访问控制
3. 日志记录：记录所有对目标合约的调用

*/

// 目标合约
contract Counter {
    uint256 public count;

    function get() external view returns (uint256){
        return count;
    }

    function inc() external returns (uint256) {
        count +=1;
        return count;
    }
}

// 代理合约：所有调用通过本合约转发
// 代理合约核心：fallback
contract FallbackInputOutput {
    address immutable target;

    constructor(address _target){
        target = _target;
    }

    // 1.可以接收、返回 bytes 数据
    // 2.即使本合约没有定义函数，也可以调用目标合约的函数
    // 3.ETH 也可以转发：{value: msg.value}
    fallback(bytes calldata data) external payable returns (bytes memory) {

        // data 是目标合约的接口
        // 执行的操作：
        // 1.解析 data: 提取函数选择器（前4字节）
        // 2.查找函数：在targe 合约中找到匹配的函数（这里是 Counter 合约）
        // 3.执行函数：调用找到的函数
        // 4.返回结果：返回执行结果
        (bool ok, bytes memory res) = target.call{value: msg.value}(data); 
        require(ok,"call failed");
        return res;
    }
}

// 测试合约
contract TestFallbackInputOutput {
    event Log(bytes res);

    function test(address _fallback, bytes calldata data) external {
        (bool ok, bytes memory res) = _fallback.call(data);  // 调用到：代理合约的 callback
        require(ok, "call failed");
        emit Log(res);
    }

    function getTestData() external pure returns (bytes memory, bytes memory) {
        return (abi.encodeCall(Counter.get,()), abi.encodeCall(Counter.inc, ()));
    }
}