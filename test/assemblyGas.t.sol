// test/GasGolf.t.sol
import "forge-std/Test.sol";
import "../src/basic/assemblyError.sol";

contract AssemblyErrorfTest is Test {
    AssemblyError public assemblyError;

    function setUp() public {
        assemblyError = new AssemblyError();
    }

   // 使用 vm.expectRevert 进行更精确的测试
function testPreciseGasComparison() public {
    // 测试汇编版本
    vm.expectRevert();
    uint256 gasStart = gasleft();
    assemblyError.yul_revert(15);
    uint256 assemblyGas = gasStart - gasleft();
    console.log("Assembly revert gas:", assemblyGas);

    // 测试 Solidity 版本
    vm.expectRevert("Invalid number");
    gasStart = gasleft();
    assemblyError.solidity_revert(15);
    uint256 solidityGas = gasStart - gasleft();
    console.log("Solidity revert gas:", solidityGas);
}
        


}