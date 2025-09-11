// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
1. 无限循环
 gas 耗尽 -> 交易失败 -> 状态回滚 -> gas 不退

 2. 实际应用
 a. for: 可用（需注意优化 gas)
 b. while/do while: 很少用（基于第1点的原因）
*/

contract Loop {
    function loop() public pure {
        for(uint256 i = 0; i < 10; i++){
            if(i == 3) continue;
            if(i == 5) break;
        }

        uint256 j;
        while(j < 10){
            j++;
        }
    }
}