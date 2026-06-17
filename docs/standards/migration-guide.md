# 范式迁移操作指南

> 本文档描述将 QoderHarness 工程范式复制到其他项目的操作流程。  
> 设计依据：`docs/private/CommonThink.md` §5（范式迁移与命令化复用体系设计）

---

## 迁移场景速查

| 场景 | 描述 | 命令 |
|------|------|------|
| **绿地（Green Field）** | 全新空项目，从零引入范式 | `/paradigm-init` |
| **棕地（Brown Field）** | 已有项目，渐进式采纳范式 | `/paradigm-adopt` |
| **范式同步（Sync）** | 已采纳范式的项目，跟进上游更新 | `/paradigm-sync` |

---

## 迁移内容分类框架

迁移时，所有文件按处理方式分为四类：

| 类型 | 具体内容 | 操作 |
|------|----------|------|
| **零修改复用** | `.qoder/commands/`、`.qoder/agents/`、`.qoder/skills/`、`docs/standards/`（本文件除外）、`.qoder/README.md`、`hooks/`（除 `auto-lint.sh`）| 直接 copy，不改任何内容 |
| **少量替换** | `AGENTS.md`（项目名/Repo URL/版本）、`setting.json`（`src/tests` 路径）、`auto-lint.sh`（linter 工具）| 替换 3~5 处占位符（见各场景说明）|
| **全部重建** | `docs/context/`（architecture/constraints/adr）、`docs/private/`（状态三件套）、`STATE.md` | 为新项目重新创建，不照抄 |
| **直接删除** | 范式研发期文档（均已移至 `docs/private/`，不再出现在 Template 中）| 无需操作 |

---

## 场景 A：绿地初始化

**适用**：全新空项目（通过 GitHub Template 创建或本地空目录）  
**执行命令**：`/paradigm-init`

### 前提条件

- GitHub Repo 已设为 Template Repository（Settings → ☑ Template repository），通过 "Use this template" 创建
- 或：本地空目录，`/paradigm-init` 自动通过 tarball in-memory 完成骨架复制

### 定制化要点（命令自动执行，此处供理解参考）

1. **AGENTS.md**：替换项目名、Repo URL、版本号（重置为 `V0.1`）
2. **setting.json**：根据项目类型调整 `Edit()` 路径权限
   - `code`：`src/**` + `tests/**`
   - `docs`：`topics/**` + `docs/context/**`
   - `mixed`：源码目录 + `docs/context/**`
3. **STATE.md**：重置为新项目初始状态
4. **auto-lint.sh**：模板已内置 `*.md` 分支；代码项目按技术栈确认对应 linter
5. **docs/context/**：删除继承的旧 ADR，创建新项目 ADR-001
6. **docs/private/**：创建 state/ 三件套（wip.md + handoff.md）

### 验收清单

- [ ] `AGENTS.md` 中项目名、Repo URL、版本已替换
- [ ] `STATE.md` 内容已重置为新项目初始状态
- [ ] `setting.json` 路径权限与新项目目录匹配
- [ ] `auto-lint.sh` linter 工具与技术栈匹配
- [ ] `docs/context/` 已重建（旧 ADR 已删除）
- [ ] `docs/private/` 已创建且已加入 `.gitignore`

---

## 场景 B：棕地采纳

**适用**：已有代码和目录结构的项目，需要渐进引入范式  
**执行命令**：`/paradigm-adopt`

### 核心原则

- **不覆盖**：永远不自动覆盖目标项目已有的同名文件
- **分模块**：按影响从小到大逐步导入，不要求一次全量迁移
- **幂等性**：每个步骤可安全重复执行

### 推荐导入顺序（影响从小到大）

```
1. docs/standards/    → 影响最小，纯文档，无冲突风险
2. .qoder/commands/   → 只新增命令，不改现有文件
3. .qoder/agents/     → 只新增 Agent，不改现有文件
4. .qoder/skills/     → 只新增 Skill，不改现有文件
5. .qoderwork/hooks/  → 影响运行时行为，需确认现有 hooks
6. .qoder/setting.json → 影响权限配置，需合并而非覆盖
7. AGENTS.md          → 影响最大，需要深度定制，放最后
```

### 关键注意事项

- **auto-lint.sh**：`/paradigm-adopt` 会自动合并缺失的语言分支（不整体覆盖）
- **setting.json**：永远不整体覆盖，只做 `userConfig` 开关和 `hooks` 事件的精确合并
- **AGENTS.md**：精确段落合并模式，检查 3 个关键段落（上下文加载规则 / SubAgent 广播 / Code Standards）

### 验收清单

- [ ] `docs/standards/` 已导入
- [ ] `.qoder/commands/`、`agents/`、`skills/` 已导入
- [ ] Hooks 已导入，无冲突，linter 已调整
- [ ] `setting.json` 已合并（非覆盖）
- [ ] `AGENTS.md` 已按目标项目实际情况定制
- [ ] 三件套和 `STATE.md` 已创建
- [ ] `.gitignore` 已加入 `docs/private/`

---

## 场景 C：范式同步

**适用**：已采纳范式的项目，需要跟进 QoderHarness 上游的范式更新  
**执行命令**：`/paradigm-sync`

### 同步前：评估变更范围

先确认上游更新了什么（查看 QoderHarness git log 或 AGENTS.md 版本号）：

| 变更类型 | 描述 | 风险 |
|----------|------|------|
| **Breaking** | 命令接口变更、setting.json 结构调整 | 高，需手动处理 |
| **Enhancement** | 新增命令/Agent/规范文档 | 低，可直接同步 |
| **Optional** | 文档描述优化、注释补充 | 可跳过 |

### 同步策略

- `/paradigm-sync` 自动执行版本比对、逐模块 diff、变更分级
- 生成三级报告（BREAKING / ENHANCEMENT / OPTIONAL），由用户选择应用级别
- 支持逐文件确认（选项 4）或只生成报告（选项 5）

### 验收

- [ ] 确认同步后 `AGENTS.md` 行数仍 ≤150 行
- [ ] 确认 `STATE.md` 行数仍 ≤30 行
- [ ] 运行 `shellcheck .qoderwork/hooks/*.sh` 零警告
- [ ] 运行 `/review-hooks` 确认 Hooks 适用性

---

## 附录：常见占位符替换清单

迁移时需要在目标项目中搜索并替换以下内容：

| 占位符（来自 QoderHarness）| 替换为 | 出现位置 |
|---------------------------|--------|---------|
| `QoderHarness` | 新项目名 | `AGENTS.md`、`STATE.md` |
| `ZenRay/QoderTemplate.git` | 新项目 Repo URL | `AGENTS.md` |
| `V0.x`（版本号）| `V0.1` | `AGENTS.md`、`STATE.md` |
| `ruff` | 对应 linter | `auto-lint.sh`（仅当技术栈不同时）|
| `src/**`, `tests/**` | 实际目录路径 | `setting.json` |

---

*文件路径：`docs/standards/migration-guide.md` | 随范式演进持续更新*  
*设计依据：`docs/private/CommonThink.md` §5*
