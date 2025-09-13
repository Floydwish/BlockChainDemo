// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
节省 gas 的方法：
1.用 calldata 替代 memory
2.把 状态变量加载到 memory
3.使用 ++i, 而不是 i++
4.缓存数组
5.短路求值
*/

contract GasGolf {
    
    uint256 public total;

    /* nums 数组长度：10

     0.start - 39533                        
     1.calldata 替代 memory 数组：36908       (避免将数据复制到内存)   
     2.将状态变量 total 加载到 memory: 36047   (避免重复操作状态变量)
     3.短路求值（应用在判断条件）：35537          (避免额外的变量，以及某些值只算第1个条件，省去第2个条件的计算)
     4.++i 替换 i++ : 35487                  (节省堆栈操作，更高效的操作码)
     5.缓存数组长度：35419                     (避免每次循环都读取数组长度)
     6.将数组从参数加载到 memory: 35059         (避免重复访问数组元素)
     7.不检查 i 的上溢和下溢：35059             (本次测试：gas 无变化) 

    */

    function sumIfEvenAndLessThan99(uint256[] memory nums) external {

        for(uint256 i = 0; i< nums.length; i++){
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if(isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }
    

    function gasSave_sumIfEvenAndLessThan99(uint256[] calldata nums) external {
        uint256 _total = total;
        uint256 len = nums.length;

        for(uint256 i = 0; i < len;) {
            uint256 num = nums[i];
            if(num % 2 == 0 && num < 99) {
                _total += num;
            }
            unchecked {
                ++i;
            }
        }
        total = _total;
    }
}

/*
关于 unchecked 说明：
一、作用
1. 节省 gas (省去了检查溢出的操作)
2. 阻止溢出时抛出的错误（运行时，不会抛出错误，但结果是错的）

二、使用场景
1. 代码块：循环、数组
2. 具体场景：DeFi 协议、NFT 项目、代币合约
*/