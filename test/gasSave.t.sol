// test/GasGolf.t.sol
import "forge-std/Test.sol";
import "../src/basic/gasSave.sol";

contract GasGolfTest is Test {
    GasGolf public gasGolf;

    function setUp() public {
        gasGolf = new GasGolf();
    }

    function testGasUsage() public {
        uint256[] memory nums = new uint256[](10);
        nums[0] = 1;
        nums[1] = 2;
        nums[2] = 3;
        nums[3] = 4;
        nums[4] = 5;
        nums[5] = 10;
        nums[6] = 21;
        nums[7] = 32;
        nums[8] = 101;
        nums[9] = 50;

        // 测量 gas
        uint256 gasStart = gasleft();          // 获取当前剩余 gas
        gasGolf.sumIfEvenAndLessThan99(nums);
        uint256 gasUsed = gasStart - gasleft();// gas 消耗 = 操作前剩余 gas - 操作后剩余 gas

        console.log("Gas used:", gasUsed);
        assertEq(gasGolf.total(), 98);

        /*
        gasLeft 函数：
        1. 精确的 gas 测量：直接读取 EVM 的 gas 计数器
        2. 实时：返回实时的 gas
        3. 简单：合约中可调用

        */
    }
}