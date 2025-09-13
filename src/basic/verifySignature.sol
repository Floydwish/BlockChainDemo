// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
链下签名，链上验证：
一、签名
1.创建待签名的 message
2.获得 message 的 hash
3.签名这个 hash (链下签名：让私钥更安全)

二、验证
1.重新创建 hash (用原始的 message)
2.从签名和 hash 中得到 签名者
3.比较 "计算得到的签名者" 和 "声称的签名者" 是否一致

三、测试(Todo)
1.开发阶段（快速验证，无需前端）
- Foundry

2.生产环境：
- wagmi
- ethers.js

*/

contract VeritySignature {
    /* 1.解锁 MetaMask 账户
        在浏览器中调用 ethereum.enable()解锁 MetaMask 钱包，获取账户访问权限

        ethereum.enable()
    */

    /* 2.获取 消息 的 hash 
        调用 getMessageHash， 传入接收者地址、金额、消息内容，随机数，返回32字节的哈希值。

        getMessageHash(
        0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C,
        123,
        "coffee and donuts",
        1
    )
    hash = "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd"
    */

    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    /* 3.签名消息的 hash
        a.使用浏览器：调用 ethereum.request 方法进行签名
        b.使用 web3: 调用 web3.personal.sign 方法
        c.返回：65 字节的签名数据
        d.注意：不同账户会产生不同的签名
    */
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32)
    {
        // 格式："\x19Ethereum Signed Message\n" + len(msg) + msg
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    /* 4.验证签名
        调用 verify, 传入签名者地址、接收者、金额、消息、随机数和签名，验证签名是否有效
    */

    function verify(
        address _signer,
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount,_message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    // 恢复签名者
    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public 
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            // 第1个32字节：签名的长度
            // mload(p) 从内存地址p开始加载接下来的32字节到内存中

            // 第2个32字节：r 值
            // add(sig, 32): sig 指针 + 32，跳过签名的前32字节（得到第 33~64 字节）
            r := mload(add(sig, 32))

            // 第3个32字节：s 值
            // sig 指针 + 64： 跳过签名的前64字节（得到第 65~96 字节）
            s := mload(add(sig, 64))

            // 第4个32字节的第1个字节：v 值
            v := byte(0, mload(add(sig, 96)))
        }

        // 隐式 return (r, s, v)
    }
}

/*
=== Remix 测试说明 ===

1. 重要注意事项：
   - Remix 处理消息哈希的方式与合约不同
   - Remix 会对消息哈希再次进行哈希
   - 合约直接使用消息哈希
   - 结果：最终的ETH签名消息哈希会不同

2. 具体差异示例：
   Message hash:    0x56f00a5093efc595178316938b3e9ab51b37610ca57b1b471aa4ce801f05251d
   Remix output:   0xd3445702e9995d1b351adf2606d88910d12dd95554f0bbdaa8d02061933c6363
   Contract output: 0xed08430382ce60ae9e2b032b99a36b2c5c5c5a3fa1d293926ce87c723f2fce84

3. 解决方案：
   - 建议使用 ethers.js 或 web3.js 进行正确测试
   - 这些库与合约的处理方式一致

=== Remix 测试步骤 ===

步骤1：获取消息哈希
- 调用 getMessageHash 函数
- 参数：
  address _to: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
  uint256 _amount: 123
  string _message: "coffee and donuts"
  uint256 _nonce: 1
- 复制返回的哈希值

步骤2：签名消息哈希
- 在"部署和运行交易"标签页
- 选择第一个账户
- 点击"+"号后的签名图标
- 粘贴消息哈希
- 点击"签名"
- 返回：哈希值和签名

步骤3：验证签名
- 调用 verify 函数
- 参数：
  address _signer: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
  address _to: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
  uint256 _amount: 123
  string _message: "coffee and donuts"
  uint256 _nonce: 1
  bytes signature: [步骤2的签名]
- 预期结果：返回 true

=== 总结 ===
- 警告：Remix的签名处理与合约不一致
- 建议：使用 ethers.js 或 web3.js 进行正确测试
- 目的：提供完整的测试流程和参数示例
- 问题：Remix会额外哈希一次，导致验证失败
*/
