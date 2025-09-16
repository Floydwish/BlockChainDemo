// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
一、核心
1. EIP-2612 permit
2. 功能：支持 permit 的 ERC20 接口，允许用户通过签名授权，无需发送交易


*/

// 一、IERC20Permit 接口
// 注：标准 ERC20 + 实现了 permit
interface IERC20Permit {
    // 标准 ERC2O 函数
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address receipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // EIP-2612 permit 函数
    function permit(
        address owner,      // 代币所有者
        address spender,    // 被授权者
        uint256 value,      // 授权金额
        uint256 deadline,   // 授权截止时间
        uint8 v,            // 签名 v 值
        uint32 r,           // 签名 r 值
        uint32 s            // 签名 s 值
    ) external;
}

// 二、GaslessTokenTransfer 合约
// 注：实现无 gas 转账，用户通过签名授权，其他人代为执行交易并支付 gas 费
contract GaslessTokenTransfer {
    function send(
        address token,      // 代币合约地址
        address sender,     // 发送者地址
        address receiver,   // 接收者地址
        uint256 amount,     // 转账金额
        uint256 fee,        // 手续费
        uint256 deadline,   // 授权截止时间
        uint8 v,            // 签名 v 值
        uint32 r,           // 签名 r 值
        uint32 s            // 签名 s 值
    ) external {
        // 1.使用 permit 授权合约使用代币
        IERC20Permit(token).permit(sender, address(this), amount + fee, deadline, v, r, s);

        // 2.转账给接收者
        IERC20Permit(token).transferFrom(sender, receiver, amount);

        // 3.收取手续费给执行者
        IERC20Permit(token).transferFrom(sender, msg.sender, fee);
    }
} 

// 三、ERC20 基础合约
// 说明：提供 ERC20 代币基础功能
abstract contract ERC20 {
    // 事件
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // 状态变量
    string public name;             // 代币名称
    string public symbol;           // 代币符号
    uint8 public immutable decimals;// 小数位数
    uint256 public totalSupply;     // 总供应量
    
    mapping(address => uint256) public balanceOf;                     // 余额映射
    mapping(address => mapping(address => uint256)) public allowance; // 授权映射
    mapping(address => uint256) public nonces;                        // 随机数映射

    // 域分隔符相关
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR; 


    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    // 授权
    function approve(address spender, uint256 amount) 
        public 
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 转账
    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;        // 不检查溢出，节省 gas
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount)
        public 
        virtual
        returns (bool)
    {
        uint256 allowed = allowance[from][msg.sender]; // 节省 gas

        if(allowed != type(uint256).max) { 
            allowance[from][msg.sender] = allowed - amount;     // 授权金额更新 
        }

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);

        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        uint32 r,
        uint32 s
    ) public virtual {
        // 检查是否过了有效期
        require(deadline > block.timestamp, "Permit deadline expired"); 

        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",             // EIP-712 前缀
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ), v, r, s
            );

            require(
                recoveredAddress != address(0) && recoveredAddress == owner, "Invalid signer");

            allowance[recoveredAddress][spender] = value;
        }
        emit Approval(owner, spender, value);

    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }

}

// 四、ERC20Permit 实现合约（继承 ERC20 的 permit 功能)
contract ERC20Permit is ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals) 
        ERC20(_name, _symbol, _decimals)
    {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}