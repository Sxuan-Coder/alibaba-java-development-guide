# Alibaba Java Development Guide Skill

> 《阿里巴巴 Java 开发手册（黄山版）》的 Claude Code / Codex 的Skill —— 让 Coding Agent 在写 Java 代码时自动遵循阿里Java开发规约。

`码出高效，码出质量。`

---
![version](https://img.shields.io/badge/version-1.1.1-blue) ![license](https://img.shields.io/badge/license-MIT-green) ![Alibaba](https://img.shields.io/badge/Alibaba-黄山版-orange)

[🚀 一键安装](#五安装)
---

## 一、为什么需要这个 Skill

大模型写 Java 代码时，常见三类问题：

| 问题 | 表现 | 后果 |
|------|------|------|
| **命名随意** | `List<Map<String,Object>>` 满天飞、布尔值叫 `flag`、常量不全大写 | 可读性差、团队风格不统一 |
| **隐患代码** | `Date` 而非 `LocalDateTime`、`==` 比字符串、`try-catch` 吞异常、SQL 字符串拼接 | 线上故障、SQL 注入、NPE |
| **架构混乱** | DAO 直接返回给前端、Service 越层调用、缺少 DTO/VO 分层 | 难维护、难扩展 |

**根因**：模型缺少一份**权威、结构化、可按需检索**的工程化开发手册。但是把整本手册塞进 prompt 会爆上下文窗口；让模型"凭记忆"遵循阿里规约又会丢失条文细节。

**本 Skill 的优势**：

- 📚 **完整收录**黄山版 7 大维度（编程规约 / 异常日志 / 单元测试 / 安全规约 / MySQL / 工程结构 / 设计规约）共 2000+ 行条文
- 🧭 **按需路由，省Token**——`SKILL.md` 只做导航，命中场景时才读取对应 `data/*.md`，节省 token
- 🎯 **触发词精准定位**——18 条精确关键词映射，AI 无需推理即可直达对应章节
- 🏷️ **保留分级**——每条规约标注【强制】/【推荐】/【参考】，AI 能区分优先级
- ✅ **正例 + 反例**——条文附带提倡写法与真实故障雷区，AI 修复时有的放矢
- ⚖️ **冲突解决策略**——安全优先 > 强制优先 > 业务豁免 > 渐进改进，规约冲突时有据可依
- 👁️ **视角区分**——编写视角（即时决策）与审查视角（全局判断）分流，按任务类型推荐阅读路径
- 🎛️ **个性化配置**——通过 `memory.md` 覆盖手册规约或补充团队自有规范

## 二、效果验证

> 通过 **with_skill vs without_skill** 基准对比评测：同一批 Java 编写任务，分别在有/无本 Skill 的情况下运行，逐条核对是否符合阿里规约。

### 关键指标

| 指标 | 用本 Skill | 不用 Skill | 提升 |
|------|-----------|-----------|------|
| **平均规约通过率** | **95.8%** | 82.5% | **+13.1pp** |
| **日期时间规约用例** | **100%** | **20%** | **+80pp** |
| **最差用例通过率** | 75% | **20%** | 消除短板 |

### 实测对比：日期时间 API（最典型案例）

同一句需求「写一个 DateUtils 工具类」，是否使用本 Skill，产出完全不同：

**❌ 不用 Skill** —— 用了手册明令禁止的写法（违反【强制】规约）：
```java
import java.text.SimpleDateFormat;
import java.util.Date;

public String format(Date date, String pattern) {
    return new SimpleDateFormat(pattern).format(date); // 非线程安全，违反【强制】
}
```

**✅ 用本 Skill** —— 正确采用线程安全的 `java.time` API：
```java
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

private static final DateTimeFormatter FORMATTER =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"); // 线程安全，可全局复用

public String now() {
    return LocalDateTime.now().format(FORMATTER);
}
```

> `SimpleDateFormat` 非线程安全、`java.util.Date` 已过时——这是阿里手册明确写入的【强制】规约，也是 AI 最容易遗忘、而本 Skill 能稳定纠正的细节。上述用例在多个模型上反复验证：**不用 Skill 时 AI 大概率退回旧写法，用了 Skill 则稳定采用正确 API**。

### 评测可复现

评测用例与评分脚本已随仓库收录在 `evals/` 目录，可本地一键复跑、回归验证。

## 三、规约来源

本 Skill 内容**完整来源于**：

> **《Java 开发手册（黄山版）》** v1.7.1，2022.02.03 发布

黄山版是阿里 Java 开发手册的最新公开版本，在其前身（嵩山版、泰山版等）基础上修订而成，是**中文 Java 社区影响力最大、被广泛采纳的工程规约**之一。手册以 Java 开发者视角划分为七个维度，并附三张参考表（版本历史、专有名词解释、错误码全量列表）。

## 四、仓库结构

```
alibaba-java-development-guide/
├── SKILL.md                          # 路由入口 + 增强导航（触发词映射/冲突策略/视角区分/场景推荐）
├── memory.md                         # 个人编码偏好配置（跨项目）
├── README.md                         # 本文件
├── project/
│   ├── README.md                     # project/ 使用说明
│   ├── _template.md                  # 新建项目规范模板
│   └── <项目名>.md                    # 按项目名隔离的规范文件
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

## 五、安装

一条命令安装任意技能：

```bash
npx skills add Sxuan-Coder/alibaba-java-development-guide
```

自动识别，勾选使用的 Agent 即可自动安装。

### 还有两种方式

**① Git 手动操作**（Claude Code，macOS / Linux / Git Bash）：

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/Sxuan-Coder/alibaba-java-development-guide.git ~/.claude/skills/alibaba-java-development-guide
```

Windows (PowerShell)：

```powershell
mkdir "$env:USERPROFILE\.claude\skills" -Force
git clone https://github.com/Sxuan-Coder/alibaba-java-development-guide.git "$env:USERPROFILE\.claude\skills\alibaba-java-development-guide"
```

**② 让 Agent 帮你安装**：把下面这句话原样发给你的 AI 助手，它会按 README 指引自动完成安装：

> 请帮用户读取仓库下的 README 然后根据指引安装到 agent 工具的全局目录：https://github.com/Sxuan-Coder/alibaba-java-development-guide

---

#### 验证安装

在任意 Java 项目里提问，例如：

> "帮我 review 这个 Service 类，对照阿里规约"

Claude 会自动加载本 Skill，按需读取 `data/02-exception-logging.md`、`data/06-project-structure.md` 等章节并给出条文级反馈。


## 六、使用示例

安装完成后，无需手动调用——AI 会在命中场景时自动加载。也可显式触发：

| 你的指令 | Skill 会命中的章节 |
|----------|---------------------|
| "这段 SQL 有没有问题" | `05-mysql-database.md`（索引、分页、ORM） |
| "这个接口要做脱敏吗" | `04-security-standards.md`（敏感数据） |
| "Service 抛异常该怎么处理" | `02-exception-logging.md`（错误码、try-catch） |
| "DTO 和 VO 怎么分层" | `06-project-structure.md`（应用分层） |
| "帮我写这个方法的单测" | `03-unit-testing.md`（AIR、BCDE、Mock） |
| "金额字段要不要用 BigDecimal" | 触发 `memory.md` + `01-coding-standards.md`（优先读团队偏好覆盖） |
| "这个 JWT Token 设计安全吗" | 触发词 `JWT/Token` → `04-security-standards.md` |
| "方法超 80 行了但单一职责拆不动" | 触发 `SKILL.md` 冲突策略 → 安全豁免 + 加注释说明 |

### 个性化配置

本 skill 提供两层个性化配置，按优先级合并生效：

```
memory.md （个人偏好）→ project/<项目名>.md （项目规范）→ 手册原文
```

- **`memory.md`** — 你的个人编码习惯（金额类型、Lombok 偏好等），跨项目通用
- **`project/<项目名>.md`** — 项目团队规范（技术栈、命名约定、规约覆盖等），按项目隔离

**初始化**：首次使用时 AI 自动扫描项目 + 提问，生成对应文件
**持续更新**：日常编码中 AI 发现新规范时询问是否加入

## 七、许可证与贡献

- 规约原文版权归 **阿里巴巴集团** 所有，本项目仅做工程封装。
- Skill 封装代码（`SKILL.md`、路由结构、README 等）按 MIT 协议开源，欢迎 PR 补充条文解读、修复转换噪声、增加实战案例。
- 如发现 PDF 转换残留的排版噪声，欢迎提 Issue 和 PR。

## 八、致谢

- **[《Java 开发手册（黄山版）》](https://github.com/alibaba/p3c)** —— 本 Skill 的规约内容来源，阿里巴巴 Java 社区工程规约的集大成者。
- **[skill-up](https://github.com/alibaba/skill-up)** —— 本 Skill 的评测工具，支撑 `evals/` 基准对比与持续回归。

---

**码出高效，码出质量。** 让每一次 AI 生成的 Java 代码，都经得起 review。
