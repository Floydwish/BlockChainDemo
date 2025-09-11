// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Counter{
    uint256 public count;

    // 获取当前 count
    function get() public view returns(uint256){
        return count;
    }

    // count 加1
    function inc() public {
        count++;
    }

    // count 减1
    // 注：solidity version <0.8 时，存在溢出问题
    function dec() public{
        count--;
    }
}