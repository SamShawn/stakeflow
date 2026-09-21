# StakeFlow

多链质押与奖励分发协议 —— Web3 全栈实战项目。

## 技术栈

| 层 | 技术 |
|----|------|
| 合约 | Solidity + Foundry + OpenZeppelin (UUPS) |
| 前端 | Next.js + TypeScript + Tailwind + Wagmi + viem + RainbowKit |
| 后端 | NestJS + PostgreSQL + Redis + viem |
| 共享 | TypeScript（ABI / 类型 / 地址） |
| 工程 | pnpm workspace + Turborepo + GitHub Actions |

## 项目结构

```
stakeflow/
├── packages/
│   ├── contracts/   # Foundry 合约
│   ├── frontend/    # Next.js DApp
│   ├── backend/     # NestJS 索引服务
│   └── shared/      # ABI / 类型 / 地址
├── scripts/         # 工具脚本
├── docs/            # 文档与 ADR
└── .github/         # CI/CD
```

## 快速开始

```bash
# 环境要求：Node 20+、pnpm 9+
corepack enable

# 安装依赖
pnpm install

# 启动所有服务（开发模式）
pnpm dev

# 构建
pnpm build

# 测试
pnpm test
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `pnpm dev` | 启动所有服务 |
| `pnpm build` | 构建所有包 |
| `pnpm test` | 运行所有测试 |
| `pnpm lint` | 代码检查 |
| `pnpm typecheck` | 类型检查 |
| `pnpm format` | 格式化代码 |
| `pnpm contracts:build` | 编译合约 |
| `pnpm contracts:test` | 测试合约 |
| `pnpm contracts:anvil` | 启动本地链 |
| `pnpm sync-abis` | 同步 ABI 到 shared |

## 文档

- [架构设计](docs/architecture.md)（待补）
- [部署流程](docs/deployment.md)（待补）
- [安全说明](docs/security.md)（待补）
- [仓库管理](docs/repo-management.md)（待补）

## License

MIT
