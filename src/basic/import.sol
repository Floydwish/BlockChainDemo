// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
import 的3种类型
1. 第三方库：本地引入
2. 第三方库：url 引入
3. 自定义库：本地引入
*/

// 1.第三方库：本地引入（下载到本地后）
//import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

// 2.第三方库：url 引入 (建议安装到本地： forge install username/repository-name)
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";

// 3.自定义库：本地引入 (同一目录下)
import "./importFrom.sol";

// 导入 Unauthorized
// 导入 add (设置别名为 func)
// 导入 Point
import {Unauthorized, add as func, Point} from "./importFrom.sol";

/* 本地库目录结构：
├── Import.sol
└── importFrom.sol
*/



contract Import {

    // 初始化 importFrom
    Example public example = new Example();

    // 调用 name 获取名称
    function getExampleName() public view returns (string memory) {
        return example.name();
    }
}
