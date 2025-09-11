// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
一、如何在合约中创建另一个合约？
1.create:  new
2.create2: new + 指定 salt 

二、关于 create2
1. 原来 create 的特点
 a.创建时：每次创建合约地址都不同
 b.适用场景：用户账户、临时合约

2. create2 特点
 a. 创建时：可以提前预测到部署后的合约地址
 b. 适应场景：代理合约、升级合约、确定性部署
*/

// Car 合约
contract Car {
    address public owner;
    string public model;
    address public carAddr;

    // new 的时候调用
    constructor(address _owner, string memory _model) payable {
        owner = _owner;
        model = _model;
        carAddr = address(this);
    }
}

// Car 工厂合约
contract CarFactory {
    Car[] public cars;   // 保存所有生产的 Car

    // 事件：记录地址预测和实际地址
    event CarCreated(uint256 index, address predictedAddr, 
                    address actualAddr, string model, bytes32 salt);

    // create 生产方式：生产后（可以理解成：Car 的所在地址随机）
    // 未指定 salt, 地址计算时加入动态变化的 nonce, 生成的 Car 地址随机
    function create(address _owner, string memory _model) public {
        Car car = new Car(_owner, _model);  
        cars.push(car);
    }

    // 同 create
    // 创建时发送了 Ether
    function createAndSendEther(address _owner, string memory _model)
        public
        payable
    {
        Car car = (new Car){value: msg.value}(_owner, _model);
        cars.push(car);
    }

    // create2 生产方式：生产前（明确知道生产的 Car 地址）
    // 指定了 salt: 地址计算时用确定的 salt 替代 动态的 nonce, 地址可预测
    function create2(address _owner, string memory _model, bytes32 _salt)
        public
    {
        // 预测地址
        address predictedAddr = predictAddressWithParams(_salt, _owner, _model);

        // 创建合约
        Car car = (new Car){salt: _salt}(_owner, _model);
        cars.push(car);

        // 获取实际地址
        address actualAddr = address(car);

        // 发出事件
        emit CarCreated(cars.length - 1, predictedAddr, actualAddr, _model, _salt);
    }

    // 同 create2
    // 增加了发送 Ether
    function create2AndSendEther(address _owner, string memory _model, bytes32 _salt)
        public
        payable
    {
        // 预测地址
        address predictedAddr = predictAddressWithParams(_salt, _owner, _model);

        // 创建合约
        Car car = (new Car){value: msg.value, salt: _salt}(_owner, _model);
        cars.push(car);

        // 获取实际地址
        address actualAddr = address(car);

        // 发出事件
        emit CarCreated(cars.length -1, predictedAddr, actualAddr, _model, _salt);
    }

    // 预测地址
    function predictAddressWithParams(bytes32 _salt, address _owner, string memory _model) 
        public view returns (address) 
    {
        // type(Car).creationCode: Car合约的部署字节码（Creation Bytecode）(不是运行时字节码（Runtime Bytecode）)
        // abi.encode(_owner, _model): 字节数组（编码后的构造函数参数）
        // abi.encodePacked: 完整字节码
        bytes memory bytecode = abi.encodePacked(type(Car).creationCode, abi.encode(_owner, _model));

        // 完整字节码的哈希
        bytes32 bytecodeHash = keccak256(bytecode);

        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),    // create2 的固定前缀 （create 的固定前缀是 0xf0)
            address(this),   // deployer_address
            _salt,           // salt
            bytecodeHash     // bytecode hash
        )))));
    }

    function getCar(uint256 _index) public view returns 
            (address owner, string memory model, address carAddr, uint256 balance)
    {
        require(_index < cars.length, "Invalid index");
        Car car = cars[_index];

        return (car.owner(), car.model(), car.carAddr(), address(car).balance);
    }

    function calculateSalt(string memory input) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(input));
    }
}


