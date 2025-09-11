// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Array {

    // 数组声明及初始化
    uint256[] public dynamicArray;                 // 动态数组
    uint256[] public initializedArray = [1,2,3];   // 动态数组，初始化
    uint256[5] public fixedArray;                  // 固定数组，长度为5

    // 1.读取操作
    function getElement(uint256 index) public view returns (uint256){
        require(index < dynamicArray.length, "Index out of bounds");
        return dynamicArray[index];   // 获取指定位置的元素
    }

    function getArrayLength() public view returns (uint256){
        return dynamicArray.length;   // 返回数组长度
    }

    function getAllElements() public view returns (uint256[] memory){
        return dynamicArray;          // 返回整个数组（注意: 大数组可能消耗大量 gas (节点承担))
    }

    // 2. 添加操作
    function addElement(uint256 value) public {
        dynamicArray.push(value);     // 再数组末尾添加，长度加1
    }

    function addMultipleElements(uint256[] memory values) public {
        for(uint256 i = 0; i< values.length; i++){
            dynamicArray.push(values[i]);           // 批量在末尾添加元素
        }
    }

    // 3. 修改操作
    function setElement(uint256 index, uint256 value) public {
        require(index < dynamicArray.length, "Index out of bounds");
        dynamicArray[index] = value;
    }

    // 4. 删除操作
    function removeLastElement() public {
        require(dynamicArray.length > 0, "Array is empty");
        dynamicArray.pop();     // 删除最后一个元素，长度-1
    }

    function clearElement(uint256 index) public {
        require(index < dynamicArray.length, "Index out of bounds");
        delete dynamicArray[index]; //将元素删除，实际上是重置该元素为默认值（0），不改变数组长度
    }

    // 5. 工具函数
    function isEmpty() public view returns (bool) {
        return dynamicArray.length == 0;  // 检查数组是否为空
    }

    function contains(uint256 value) public view returns (bool) {
        for(uint256 i = 0; i< dynamicArray.length; i++){
            if(value == dynamicArray[i])    return true;    // 检查数组是否包含某个值
        }
        return false;
    }

    // 6. 初始化测试数据
    function initializeTestData() public {
        dynamicArray = [10,20,30,40,50];
    }
}

// 删除元素：要求保持原有顺序
// 方法：从右到左移动
contract ArrayRemoveByShifting {
    uint256[] public arr;

    // 删除指定索引的元素，保持原有顺序
    // 原理：从删除位置开始，右边所有元素左移一位
    function removeWithOrder(uint256 index) public {
        require(index < arr.length, "Index out of bounds");
        require(index > 0, "Array is empty");

        // 从删除位置开始，右边所有元素左移一位
        for(uint256 i = index; i< arr.length - 1; i++) {
            arr[i] =  arr[i+1];  // 后面的元素覆盖前面的元素
         }

         // 删除最后一个元素
         arr.pop();  // 重复的
    }

}

// 删除元素：不要求原有顺序
// 方法：用最后一个元素覆盖，再删除最后元素
contract ArrayReplaceFromEnd {
    uint256[] public arr;

    // 删除指定索引的元素，不保持原有顺序
    // 原理：用最后一个元素替换要删除的元素，然后删除最后一个元素
    function removeWithoutOrder(uint256 index) public {
        require(index < arr.length, "Index out of bounds");
        require(arr.length > 0, "Array is empty");

        // 用最后一个元素覆盖要删除的元素
        arr[index] = arr[arr.length-1];

        // 删除最后一个元素
        arr.pop();
    }
}