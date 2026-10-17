# 📌 Web 安全 · 速查表（Day 21–30）

> 用法：每个命令一行说明「干什么 + 英文全称 + 记忆钩子」，下面列常用选项。
> 记忆钩子帮你把「字母 → 意思」焊死，不用死背英文手册。
> 分册规则：每 10 天一个文件（01–10 / 11–20 / 21–30 …），组合拳表跟在本册末尾。

---

## Day 21 · PortSwigger Web Security Academy 入门 + 第一个官方 lab

### 平台名词卡（不是命令，但天天要用）

| 名词 | 意思 | 记忆钩子 |
|------|------|---------|
| PortSwigger | 做 **Burp Suite** 的英国公司，Web 安全学院是他们的免费靶场 | Burp = 打嗝，渗透测试的标配抓包工具 |
| Web Security Academy | 免费官方靶场，题目叫 **lab**，分难度三档 | academy = 学院 |
| lab 题目页三块 | **background**（坏在哪）/ **objective**（`To solve the lab, ...` 做到啥）/ hints·Solution（折叠框） | objective = 目标，先读它 |
| Apprentice / Practitioner / Expert | 学徒 / 实践者 / 专家 三档难度 | apprentice = 学徒（Day 21 打的就是这档） |
| **context**（上下文） | 你的输入被塞进 HTML 的**哪个位置**：标签之间 / 属性里 / `<script>` 里 | context = 语境；**位置决定 payload 怎么写** |
| **nothing encoded**（未编码） | 服务器把输入**原样**拼进页面，没做任何转义 | encoded = 编码过；「没有」= 原样放行 |
| Solved 横幅 | 右上绿药丸 `LAB Solved` | 平台在页面里 hook `window.alert`，调用才判分；**不刷新可能还显示 Not solved** |

> **靶场工作流（今天立的规矩）**：
> 读题 → 找输入点（`name=xxx`）→ 判上下文 → 自己造 payload → 看现象 → 拿 Solved → 写 writeup

### curl 发带参数的 GET / 取证据

| 命令 | 干什么 | 英文全称 | 记忆钩子 |
|------|--------|---------|---------|
| `curl -s 网址` | **静默**：不打印进度条（只出正文） | **s**ilent | silent = 安静 |
| `curl -s -o 文件 网址` | 把响应**存成文件**（之后随便查） | **o**utput | out = 输出到文件 |
| `grep -o "关键词.\{0,20\}" 文件` | **只打印**匹配到的那一段（前后各 20 字符） | **o**nly matching | only = 只留匹配的 |
| `grep -n "关键词" 文件` | 打印整行 + 行号 | **n**umber | number = 行号 |
| `curl -G -d "search=x" 网址`（选学） | 把数据**拼到 URL 的 query** 上（GET 用） | **G**ET | `-G` 走 GET |
| `curl --data-urlencode "search=<x>"`（选学） | **自动替你做 URL 编码** | — | 「替你做 % 转义」 |

> ⚠️ **同一个字母，两个工具两个意思**：`curl -o` = **output 存文件**；`grep -o` = **only matching 只打印匹配**。别混。

### URL 编码对照（手写 payload 必背）

| 原字符 | 编码 | 说明 |
|--------|------|------|
| `<` | `%3C` | 开标签的钥匙 |
| `>` | `%3E` | ⚠️ 和 `%3D`（`=`）只差一个字母，**ASCII 里 0x3D/0x3E 挨着**（D 在 E 前、`=` 在 `>` 前） |
| `"` | `%22` | 双引号（`alert("Q")` 要它） |
| `'` | `%27` | 单引号 |
| `(` `)` | `%28` `%29` | 函数括号 |
| `=` | `%3D` | 等号（也常用在 `name=value` 里，query 分隔符除外可不编） |
| 空格 | `+` 或 `%20` | query 里 `+` 就是空格（`unquote_plus` 才认它） |
| `%` | `%25` | 百分号自己 |

### 两个自检习惯（Day 21 最大的收获）

| 什么时候 | 敲什么 | 为什么 |
|---------|--------|--------|
| 拼**长命令 / 带特殊字符**的命令前 | `echo "你的那串东西"` | 先看 **shell 解析后真正送出的是什么**（引号、`<` `>` 有没有被吃掉） |
| 手写完 URL 编码后 | `python3 -c "from urllib.parse import unquote_plus; print(unquote_plus('...'))"` | **反解对账**：解出来和你原本想写的是不是同一句 |

> 三层解析要分清：**shell（引号/重定向）→ URL 编码（URL 允许哪些字符）→ JS 语法（要不要引号）**。
> 一个字符之差 = 「能执行」和「报错」之差。

### ⚠️ 坑（Day 21 实录）

- **`"` 直接写在 curl 的双引号里** → 被 **shell** 吃掉 → payload 退化成 `alert(Q)` → `ReferenceError: Q is not defined` → **不弹窗**（与 Day 20 `alert(Qzl)` 同族，只是这次是 shell 干的）。
  → 解药：`"` 编码成 `%22`，URL 里就没有真引号了，外层双引号才安全。
- **`%3D` 当 `%3E` 用** → `<img ...>` 没闭合，浏览器把后面的 `'</h1>` 也吞进属性值 → `onerror=alert("Q")=` → `SyntaxError`。
- **`onerror.("Q")`（把 `=` 打成 `.`）** → 处理函数名不对，事件不触发。
- **弹窗没出现 ≠ 没执行** → `F12` → **Console** 看红字（Day 20 同款）。
- **横幅 Not solved ≠ 没解开** → 钩子已上报，等 5–10 秒或 `F5` 刷新再看。
- **lab 页面的 Solution 折叠框**：做题时别点，自己解出来才算数。
- **curl 看到的 ≠ 浏览器看到的**：curl 拿到的是**服务器原文**（标签未被解析），浏览器给的是**解析后的成品**。写报告时两个视角都要。
- **注册账号只影响"记录进度"**，不影响能不能打 lab（官方原话：access everything for free, track progress by creating an account）。

### 🔎 Day 21 的核心一句话

> **上下文（context）决定 payload 怎么写；`nothing encoded` 决定了「原样放行」——两个条件同时成立，才有 XSS。**
> 防御加在**输出层**：`<` 变 `&lt;` 之后，浏览器只会把 payload「念」给用户看，不执行。

---

## 🧩 常用组合拳（跨 Day 复用）

| 场景 | 命令 |
|------|------|
| 手写一个塞进 URL 的 payload 并验证 | 先写 payload → `unquote_plus` 反解对账 → `echo` 自检 shell → `curl -s -o 文件` → `grep -o` 取证据 |
| 判断一个 lab 的 context | `F12` → Elements 找输入落在哪（标签之间 / 属性里 / `<script>` 里）→ `Ctrl+U` 看服务器原文对照 |
| 分清「编码了没」 | curl 原文里看到 `&lt;` `&quot;` = 已编码；看到 `<` `"` 原字符 = 未编码 |
| 拿 lab 的通关判定 | 先看右上药丸 → 不刷新可能还是 Not solved → `F5` 再看 |
