// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
1. abi.encode
 a. data -> bytes

2. abi.decode
 a. bytes -> data
*/

contract AbiDecode {
    struct MyStruct {
        string name;
        uint256[2] nums;
    }

    // ABI 编码
    function encode(uint256 x, address addr, uint256[] calldata arr, MyStruct calldata myStruct)
        external pure returns (bytes memory)
    {
        return abi.encode(x, addr, arr, myStruct);
    }

    // ABI 解码
    function decode(bytes calldata data)
        external pure returns (uint256 x, address addr, uint256[] memory arr, MyStruct memory myStruct)
    {
        (x, addr, arr, myStruct) = 
            abi.decode(data,(uint256, address, uint256[], MyStruct));
    }
}