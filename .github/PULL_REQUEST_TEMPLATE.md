<!-- 感谢提交 PR！请填写以下内容，帮助 Reviewer 快速理解你的改动。 -->

## 变更类型

<!-- 勾选本 PR 的类型（至少一项） -->

- [ ] `feat`：新功能
- [ ] `fix`：Bug 修复
- [ ] `refactor`：重构（不改变外部行为）
- [ ] `perf`：性能优化
- [ ] `docs`：文档
- [ ] `test`：测试
- [ ] `chore`：构建/工具/依赖
- [ ] `ci`：CI/CD 配置

## 变更内容

<!-- 简要描述这个 PR 做了什么，为什么这么做。 -->

## 关联 Issue

<!-- 用 Closes / Fixes / Resolves 关联 Issue，例如：Closes #12 -->

Closes #

## 影响范围

<!-- 勾选受影响的模块，帮助 Reviewer 评估影响。 -->

- [ ] 合约（`packages/contracts`）
- [ ] ABI（需同步到 `shared`）
- [ ] 前端（`packages/frontend`）
- [ ] 后端（`packages/backend`）
- [ ] 共享包（`packages/shared`）
- [ ] CI/CD（`.github/workflows`）
- [ ] 文档（`docs`）
- [ ] 依赖更新

## 测试情况

<!-- 说明你做了什么测试，如何验证改动正确。 -->

- [ ] 本地测试通过
- [ ] 新增/更新了测试用例
- [ ] 合约改动已通过 `forge test`
- [ ] 合约改动已通过 Slither 扫描
- [ ] 前端本地跑通完整流程
- [ ] 后端 API 手动验证
- [ ] 已在测试网验证

### 测试命令

```bash
# 粘贴你运行的测试命令
pnpm test
```

## 截图 / 链接

<!-- 前端改动附截图/GIF；合约改动附 Etherscan 链接；API 改动附请求示例。 -->

## Checklist

<!-- 提交前请确认以下事项。 -->

- [ ] 代码符合项目规范（`pnpm lint` 通过）
- [ ] 类型检查通过（`pnpm typecheck`）
- [ ] 无硬编码密钥、私钥、API Key
- [ ] 无调试代码（`console.log`、`debugger`、临时注释）
- [ ] 已更新相关文档（如需要）
- [ ] 无新增安全风险
- [ ] 分支已 rebase 到最新 `main`

## 补充说明

<!-- 任何 Reviewer 需要知道的额外信息。 -->
