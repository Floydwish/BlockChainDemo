// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
一、keccak256 函数
1.功能
 a.计算输入数据的 Keccak-256 hash

2.应用场景
 a.创建唯一 ID
 b.验证数据的方案
 c.紧凑的加密签名

 3.encode 的2种方式：
 a.abi.encode
   1)将数据编码成带填充的字节
   2)保留所有数字信息
   3)处理动态类型时更安全
   4)产生更长的输出（由于填充）
 b.abi.encodePacked (2个以上动态类型时：用 encode 替代)
   1)压缩编码
   2)比 abi.encode 更短的输出
   3)节省 gas
   4)处理动态类型时存在哈希冲突的风险

*/

contract HashFunction {
    function hash(string memory _text, uint256 _num, address _addr)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_text, _num, _addr));
    }

    // 2个以上的动态类型时，容易出现 哈希碰撞（encodePacked 直接拼接）
    // 这种情况下，用 encode 替代（有填充）
    function collision(string memory _text, string memory _anotherText)
        public
        pure
        returns (bytes32)
    {
        // encodePacked(AAA, BBB) -> AAABBB -> hash A
        // encodePacked(AA, ABBB) -> AAABBB -> hash A
        // 不同的输入 -> 相同的输出
        return keccak256(abi.encodePacked(_text, _anotherText));
    }
}

contract GuessTheMagicWord {
    bytes32 public answer = 0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;

    function guess(string memory _word) public view returns (bool) {
        return keccak256(abi.encodePacked(_word)) == answer;
    }
}