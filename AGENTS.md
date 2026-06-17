# Project Agent Instructions

This file provides Qoder with project-level context and behavioral guidelines.
All rules here apply to every session and every SubAgent within this workspace.

---

## Project Overview

**QoderHarness Engineering** is a personal Qoder workflow template project,
providing standardized configuration patterns for permissions, lifecycle hooks,
knowledge management, and agent behavior.

- **Repository**: https://github.com/ZenRay/QoderTemplate.git
- **Current version**: V1.0
- **Config reference**: `.qoder/README.md`

---

## 上下文加载规则（Context Loading）

> 按需加载，避免每次会话全量消耗 context。AI 根据当前任务场景主动读取对应文件。

| 触发场景 | 必读文件 |
|----------|----------|
| **任何新会话开始** | `STATE.md` — 当前项目状态看板 |
| **查看上次进度或交接** | `docs/private/state/handoff.md` — 上次会话交接备忘 |
| **跨会话持续任务** | `docs/private/state/wip.md` — 进行中工作清单 |
| 涉及架构、约束或历史决策 | 运行 `/load-context [arch|constraints|adr|all]` |
| 涉及代码规范或工作流 | `docs/standards/`（comment-style / git-convention / workflow）|
| **初始化新项目 / 范式同步** | `.qoder/commands/paradigm-init.md`（绿地）或 `.qoder/commands/paradigm-sync.md`（已有项目升级）|
| 需要了解配置详情 | `.qoder/README.md` |

---

## SubAgent 广播规则

当 Qoder 启动子 Agent（SubAgent）执行专项任务时，子 Agent **必须在开始工作前**读取：

1. `AGENTS.md` — 行为规范（本文件）
2. `STATE.md` — 当前项目状态，避免与主会话冲突

子 Agent 完成任务后，若产生了状态变更（新文件、新决策、阶段推进），
应在返回结果时**明确说明变更内容**，由主会话决定是否更新 `STATE.md`。

---

## Core Behavioral Rules

### Code Standards（强制）

修改任何代码文件前，**必须主动读取**对应规范文件：

| 规范 | 文件 | 触发场景 |
|------|------|----------|
| 注释规范 | `docs/standards/comment-style.md` | 任何代码修改 |
| Git 提交规范 | `docs/standards/git-convention.md` | 任何 git commit / push |
| 工作流规范 | `docs/standards/workflow.md` | 制定会话计划或任务规划时 |

**核心约束**：
- 代码注释和文档字符串统一使用英文，仅在英文表达会导致歧义时用中文（例外）
- 公共函数必须有文档注释（参数、返回值）
- 禁止注释掉废弃代码（直接删除，Git 有记录）
- Shell 脚本必须在文件头声明事件类型和退出码说明

### Code Safety
- Always preview changes before applying edits to configuration files (`.qoder/**`, `.qoderwork/**`)
- Never delete files without explicit user confirmation
- When modifying hooks scripts, verify the exit code logic is correct
- Before writing to `~/Documents/PersonalKnowledge/`, check `userConfig.knowledgeArchive.enabled` in `.qoder/setting.json`
- Before creating session notes, check `userConfig.knowledgeNotes.enabled` in `.qoder/setting.json`

### Git Discipline
- Always run `git status` and `git diff` before committing
- Ask the user to confirm before executing `git commit` or `git push`
- Never force-push to `main` or `master` branches

### File Scope
- Source code edits are limited to `./src/**` and `./tests/**` by default
- Private docs (`docs/private/**`) are not tracked by Git — never commit them
- For edits outside defined scope, ask the user for confirmation first

---

## Project Structure

```
.
├── .qoder/
│   ├── agents/             # SubAgent definitions (hooks-reviewer)
│   ├── commands/           # 7 slash commands (archive-session, paradigm-init/adopt/sync, etc.)
│   ├── notes/              # Session drafts (not committed)
│   ├── repowiki/           # Auto-generated repo wiki
│   ├── skills/             # Reusable skills (KnowledgeExtractor)
│   ├── setting.json        # Project config (Git tracked)
│   ├── setting.local.json  # Local private overrides (not committed)
│   └── README.md           # Config documentation
├── .qoderwork/
│   ├── hooks/              # 6 lifecycle hooks (T1 security → T2 quality → T3 UX → T4 knowledge)
│   └── logs/               # Runtime logs (not committed)
├── docs/
│   ├── context/            # Layer 2 on-demand docs (architecture, constraints, adr/)
│   ├── standards/          # Engineering specs (comment-style, git-convention, workflow, migration-guide)
│   └── private/            # Private docs (not committed): state/wip.md + state/handoff.md
├── STATE.md                # Project status board (Git tracked, ≤30 lines)
└── AGENTS.md               # This file
```

---

## Hook Scripts Reference

详见 `.qoder/README.md`（事件→脚本映射、Tier 分级、timeout 配置）。退出码约定：`exit 0` = 通过，`exit 2` = 阻断。

---

## Knowledge Management

- **草稿层**：`.qoder/notes/`（开关：`knowledgeNotes.enabled`，不提交 Git）
- **精炼层**：`~/Documents/PersonalKnowledge/`（触发：`/archive-session`，开关：`knowledgeArchive.enabled`）

---

## Communication Style

- Respond in the user's preferred language (中文)
- Keep explanations concise; use tables and code blocks for structured info
- When uncertain about scope, ask before acting
