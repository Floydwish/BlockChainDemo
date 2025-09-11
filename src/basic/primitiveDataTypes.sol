// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Primitives{
    bool public boo = true;

    /*
    uint 表示无符号整数，不同类型如下：
    uint8:   0 ~ 2^8-1
    uint16:  0 ~ 2^16-1
    ...
    uint256: 0 ~ 2^256-1
    */
    uint8 public u8 = 1;
    uint256 public u256 = 456; 
    uint public u = 123;        //uint 是 uint256 的别名

    // 如何验证 uint 等同于 uint256
    // 方式1：使用 type
    function checkTypes() public pure returns(bool){
        return type(uint).max == type(uint256).max;
    }

    /* int 类型表示负数
    int 256范围：-2^255 ~ 2^255-1
    */
    int8 public i8 = -1;
    int256 public i = -123; // int256 等同于 int

    // 获取最小值、最大值
    int256 public minInt = type(int256).min;
    int256 public maxInt = type(int256).max;

    // 地址类型
    address public addr0 = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    /* 2种类型的 bytes
        1. 固定类型：bytes1, bytes2 ... bytes32
        2. 动态类型：byte[], 等价于 bytes(更方便的写法)
    */

    // 固定类型 
    bytes1 a = 0xa5; // [10100101]
    bytes1 b = 0x56; // [01010110]
    
    // 默认值
    // 没有赋值的变量，编译器将自动分配初始值
    bool public defaultBoo;         // false
    uint256 public defaultUint;     // 0
    int256 public defaultInt;       // 0
    address public defaultAddr;     // 0x0000000000000000000000000000000000000000

    /*关于地址长度
      1. 私钥：32字节
      2. 公钥：64字节（未压缩）
      3. 公钥哈希：32字节（使用 Keccak256）
      4. 地址：20字节（取哈希的后20字节）16进制时为42字符（包括 0x)
      5. 公钥 -> Keccak256 -> 取后20个字节 -> 以太坊地址
    */
    function explainAddressLength() public pure {
        //"地址 = Keccak256(公钥) 的后20字节"; // Keccak256 为哈希函数（确定性、单向性、雪崩效应、抗碰撞）
        // 原因：20字节 = 160位，提供 2^160 个可能的地址，足够大且不会太长（16字节太少，32字节太大）
    }

    // 编译时：forge 提示：使用了低效的哈希机制，建议用内敛汇编（use of inefficient hashing mechanism; consider using inline assembly）
    function generateAddress(bytes memory publicKey) public pure returns (address){
        // 1.对公钥进行 keccak256 哈希
        bytes32 hash = keccak256(publicKey);

        // 2.取后20个字节作为地址
        // uint160 截取的是后160位，而不是前160位：因为以太坊使用“大端序: 高位在前，低位在后”
        address addr = address(uint160(uint256(hash)));

        return addr;
    }

    // 低效的哈希生成
    function inefficientStringHash(string memory str) public pure returns (bytes32) {
        // 低效方式
        return keccak256(abi.encodePacked(str));
    }

    // 高效的哈希生成
    function efficientStringHash(string memory str) public pure returns (bytes32 result) {
        // 高效方式
        assembly {
            // 1.使用场景：频繁调用的哈希函数、gas 敏感的操作、性能关键代码
            // 2.优点：gas 效率高、性能好、直接调用操作码（灵活性）
            // 3.缺点：代码可读性差、调试困难、容易出错
            // 4.平衡：性能关键处使用，其他地方保持可读性
            
            // 语法：result := keccak256(ptr, length)
            result := keccak256(add(str, 0x20), mload(str))
        }
    }




}