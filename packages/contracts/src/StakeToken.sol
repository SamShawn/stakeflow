// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title StakeToken
/// @notice 质押代币（StakeFlow 协议中用户质押的资产）
/// @dev 继承 OpenZeppelin ERC20，部署时铸造初始供应量给部署者
///      仅 owner 可以后续增发（用于测试和演示场景）
contract StakeToken is ERC20, Ownable {
    /// @notice 部署合约，铸造初始供应量给部署者
    /// @param initialSupply 初始供应量（以 wei 为单位，即 10^18 最小单位）
    /// @param initialOwner 初始 owner（通常是部署者）
    constructor(
        uint256 initialSupply,
        address initialOwner
    ) ERC20("StakeFlow Stake Token", "sFLOW") Ownable(initialOwner) {
        _mint(initialOwner, initialSupply);
    }

    /// @notice 增发代币（仅 owner）
    /// @dev 用于测试网演示或后续激励计划；主网部署时建议放弃 owner 权限
    /// @param to 接收地址
    /// @param amount 增发数量
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice 销毁代币
    /// @dev 任何人都可以销毁自己持有的代币
    /// @param amount 销毁数量
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
