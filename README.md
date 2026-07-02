# Alibaba Java Development Guide Skill

> 《阿里巴巴 Java 开发手册（黄山版）》的 Claude Code / Codex 的Skill —— 让 AI 编码助手在写 Java 代码时自动遵循阿里Java开发规约。

`码出高效，码出质量。`

---

## 一、为什么需要这个 Skill

大模型写 Java 代码时，常见三类问题：

| 问题 | 表现 | 后果 |
|------|------|------|
| **命名随意** | `List<Map<String,Object>>` 满天飞、布尔值叫 `flag`、常量不全大写 | 可读性差、团队风格不统一 |
| **隐患代码** | `Date` 而非 `LocalDateTime`、`==` 比字符串、`try-catch` 吞异常、SQL 字符串拼接 | 线上故障、SQL 注入、NPE |
| **架构混乱** | DAO 直接返回给前端、Service 越层调用、缺少 DTO/VO 分层 | 难维护、难扩展 |

**根因**：模型缺少一份**权威、结构化、可按需检索**的工程规约上下文。把整本手册塞进 prompt 会爆上下文窗口；让模型"凭记忆"遵循阿里规约又会丢失条文细节和【强制/推荐/参考】分级。

**本 Skill 的解法**：

- 📚 **完整收录**黄山版 7 大维度（编程规约 / 异常日志 / 单元测试 / 安全规约 / MySQL / 工程结构 / 设计规约）共 2000+ 行条文
- 🧭 **按需路由**——`SKILL.md` 只做导航，命中场景时才读取对应 `data/*.md`，节省 token
- 🏷️ **保留分级**——每条规约标注【强制】/【推荐】/【参考】，AI 能区分优先级
- ✅ **正例 + 反例**——条文附带提倡写法与真实故障雷区，AI 修复时有的放矢

## 二、规约来源

本 Skill 内容**完整来源于**：

> **《Java 开发手册（黄山版）》** v1.7.1，2022.02.03 发布
> 作者：阿里巴巴集团 / 阿里云飞天诚信

黄山版是阿里 Java 开发手册的最新公开版本，在其前身（嵩山版、泰山版等）基础上修订而成，是**中文 Java 社区影响力最大、被广泛采纳的工程规约**之一。手册以 Java 开发者视角划分为七个维度，并附三张参考表（版本历史、专有名词解释、错误码全量列表）。

> ⚠️ **版权说明**：手册原文版权归阿里巴巴所有。本项目仅以 Skill 形式做工程化封装与便捷分发，便于开发者团队在 AI 辅助编码中统一遵循。如需官方原版，请参考阿里巴巴官方发布渠道。

## 三、仓库结构

```
alibaba-java-development-guide/
├── SKILL.md                          # 路由入口（AI 据此按需检索）
├── README.md                         # 本文件
└── data/
    ├── 01-coding-standards.md        # 一、编程规约（命名/OOP/集合/并发/注释...）
    ├── 02-exception-logging.md       # 二、异常日志（错误码/try-catch/NPE/日志）
    ├── 03-unit-testing.md            # 三、单元测试（AIR/BCDE/Mock/覆盖率）
    ├── 04-security-standards.md      # 四、安全规约（脱敏/SQL注入/XSS/CSRF）
    ├── 05-mysql-database.md          # 五、MySQL 数据库（建表/索引/ORM/分页）
    ├── 06-project-structure.md       # 六、工程结构（分层/DO-DTO-VO/二方库）
    ├── 07-design-standards.md        # 七、设计规约（UML/弱依赖/SOLID/DRY）
    └── 08-appendix.md                # 附录（版本历史/名词/错误码）
```

每条规约的内部结构：`规约编号 + 级别 + 说明 + 正例 + 反例`。

## 四、安装到 Claude Code

把整个目录放到 Claude Code 的 skills 目录下。

### 方式 A：用户级（全局生效，推荐）

适用于你希望在**所有项目**里都让 Claude 遵循阿里规约。

```bash
# 1. 进入用户 skills 目录（不存在则创建）
mkdir -p ~/.claude/skills
cd ~/.claude/skills

# 2. 克隆本仓库（目录名即为 skill 名）
git clone https://github.com/Sxuan-Coder/alibaba-java-development-guide.git

# 3. 验证：应能看到 SKILL.md
ls alibaba-java-development-guide/SKILL.md
```

Windows (PowerShell) 等价命令：

```powershell
mkdir "$env:USERPROFILE\.claude\skills" -Force
cd "$env:USERPROFILE\.claude\skills"
git clone https://github.com/Sxuan-Coder/alibaba-java-development-guide.git
```

完成后，重启 Claude Code，输入 `/` 即可在 skill 列表中看到 `alibaba-java-development-guide`。

### 方式 B：项目级（仅当前仓库生效）

适用于团队希望把规约**随仓库一起分发**（提交进版本库，团队成员 clone 后即生效）。

```bash
# 在你的业务项目根目录下
cd /path/to/your-java-project
mkdir -p .claude/skills
git clone https://github.com/Sxuan-Coder/alibaba-java-development-guide.git .claude/skills/alibaba-java-development-guide
```

建议把 `.claude/skills/alibaba-java-development-guide` 加入业务仓库的版本管理，方便全团队共享。

### 验证安装

在 Claude Code 中任意 Java 项目里提问，例如：

> "帮我 review 这个 Service 类，对照阿里规约"

Claude 会自动加载本 Skill，按需读取 `data/02-exception-logging.md`、`data/06-project-structure.md` 等章节并给出条文级反馈。

## 五、安装到 Codex (OpenAI Codex CLI)

Codex CLI 使用 `~/.codex/` 作为配置根目录，支持通过 `prompts/` 注入 slash 命令、并通过 `AGENTS.md` 让 AI 引用规约文件。本 Skill 的 `data/` 章节是纯 Markdown，可被 Codex 直接读取引用。

### 方式 A：作为可引用的知识库（推荐）

```bash
mkdir -p ~/.codex/alibaba-java-guide
cd ~/.codex/alibaba-java-guide
git clone https://github.com/Sxuan-Coder/alibaba-java-development-guide.git .
```

然后在你的 Java 项目根目录创建 `AGENTS.md`，让 Codex 在编码时主动参考规约：

```markdown
# Codex Agent 指引

编写或审查 Java 代码时，必须对照《阿里巴巴 Java 开发手册（黄山版）》。
完整条文位于：~/.codex/alibaba-java-guide/

按场景读取对应章节：
- 命名 / OOP / 集合 / 并发 → data/01-coding-standards.md
- 异常 / 日志 / NPE        → data/02-exception-logging.md
- 单元测试                  → data/03-unit-testing.md
- 安全（脱敏/SQL注入/XSS）  → data/04-security-standards.md
- 建表 / 索引 / ORM         → data/05-mysql-database.md
- 分层 / DTO/VO             → data/06-project-structure.md
- 设计 / UML / SOLID        → data/07-design-standards.md
- 名词 / 错误码             → data/08-appendix.md
```

### 方式 B：封装为 slash 命令

把规约入口做成一个可复用的 prompt：

```bash
mkdir -p ~/.codex/prompts
cat > ~/.codex/prompts/java-review.md <<'EOF'
请对照《阿里巴巴Java开发手册（黄山版）》审查当前 Java 代码。
按需读取 ~/.codex/alibaba-java-guide/data/ 下对应章节，
逐条指出违反的【强制】/【推荐】规约，并给出正例写法。
EOF
```

之后在 Codex CLI 中输入 `/java-review` 即可触发。

## 六、使用示例

安装完成后，无需手动调用——AI 会在命中场景时自动加载。也可显式触发：

| 你的指令 | Skill 会命中的章节 |
|----------|---------------------|
| "这段 SQL 有没有问题" | `05-mysql-database.md`（索引、分页、ORM） |
| "这个接口要做脱敏吗" | `04-security-standards.md`（敏感数据） |
| "Service 抛异常该怎么处理" | `02-exception-logging.md`（错误码、try-catch） |
| "DTO 和 VO 怎么分层" | `06-project-structure.md`（应用分层） |
| "帮我写这个方法的单测" | `03-unit-testing.md`（AIR、BCDE、Mock） |

## 七、许可证与贡献

- 规约原文版权归 **阿里巴巴集团** 所有，本项目仅做工程封装。
- Skill 封装代码（`SKILL.md`、路由结构、README 等）按 MIT 协议开源，欢迎 PR 补充条文解读、修复转换噪声、增加实战案例。
- 如发现 PDF 转换残留的排版噪声，欢迎提 Issue 和 PR。

---

**码出高效，码出质量。** 让每一次 AI 生成的 Java 代码，都经得起 review。
