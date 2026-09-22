/**
 * Commitlint 配置
 * 遵循 Conventional Commits 规范
 * 文档：<https://commitlint.js.org/>
 */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // type 枚举
    'type-enum': [
      2,
      'always',
      [
        'feat', // 新功能
        'fix', // Bug 修复
        'docs', // 文档
        'style', // 代码格式（不影响逻辑）
        'refactor', // 重构
        'perf', // 性能优化
        'test', // 测试
        'chore', // 构建/工具/依赖
        'revert', // 回滚
        'ci', // CI 配置
      ],
    ],

    // scope 枚举
    'scope-enum': [
      2,
      'always',
      [
        'contracts', // 合约包
        'frontend', // 前端包
        'backend', // 后端包
        'shared', // 共享包
        'ci', // CI/CD
        'docs', // 文档
        'deps', // 依赖更新
        'release', // 发布
      ],
    ],

    // scope 允许为空
    'scope-empty': [0],

    // subject 不能以大写开头
    'subject-case': [2, 'never', ['upper-case', 'pascal-case', 'start-case']],

    // subject 不能以句号结尾
    'subject-full-stop': [2, 'never', '.'],

    // header 最大长度
    'header-max-length': [2, 'always', 100],

    // body 前必须空行
    'body-leading-blank': [2, 'always'],

    // footer 前必须空行
    'footer-leading-blank': [2, 'always'],

    // type 必须小写
    'type-case': [2, 'always', 'lower-case'],

    // scope 必须小写
    'scope-case': [2, 'always', 'lower-case'],
  },
}
