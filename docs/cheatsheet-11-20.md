# 📌 Web 安全 · 速查表（Day 11–20）

> 用法：每个命令一行说明「干什么 + 英文全称 + 记忆钩子」，下面列常用选项。
> 记忆钩子帮你把「字母 → 意思」焊死，不用死背英文手册。

---

## Day 11 · HTTP 请求头/响应头 + Cookie

### curl 存 / 带 Cookie

| 命令 | 干什么 | 英文全称 | 记忆钩子 |
|------|--------|---------|---------|
| `curl -c jar.txt 网址` | 把**收到的** Cookie 存进文件 | **c**ookie | `-c` 谐音「**cún 存**」→ 存进罐子 |
| `curl -b jar.txt 网址` | 把文件里的 Cookie **带上**发请求 | **b**ring | `-b` = **bring** 带上 |

> 💡 jar.txt 就是「饼干罐」：`-c` 往里存、`-b` 从里取，全是 curl 自动干，你不用手动编辑 Cookie。

### 常见请求头（`>` 开头 = 客户端发出）

| 头 | 意思 | 记忆钩子 |
|----|------|---------|
| `Host` | 在跟哪个主机（门牌号）说话 | host=门牌号 |
| `User-Agent` | 你派来的「代表」是谁（浏览器/curl） | user=用户，agent=派来的代表 |
| `Accept` | 我能接受啥格式 | accept=接受 |
| `Referer` | 我从**哪一页**来的 | refer=参考，**回头看**来源 |
| `Cookie` | 我带来的凭证（饼干） | 通行证 |

### 常见响应头（`<` 开头 = 服务器回）

| 头 | 意思 | 记忆钩子 |
|----|------|---------|
| `Server` | 服务器是啥软件 | 会**泄露目标软件**（信息泄露点） |
| `Date` | 时间 | date=日期 |
| `Content-Type` | 正文啥格式 | content=内容 type=类型 |
| `Set-Cookie` | 服务器**发你一块新饼干** | set=设置，「发饼干」 |
| `Location` | 请去这个地址（跳转目标） | location=位置，**向前指路** |

> 💡 **Referer 回头看，Location 向前指**：Referer（请求头）= 我从哪来；Location（响应头）= 你去哪。方向相反，别混。

### Cookie 机制（核心概念）

- HTTP 是「**无状态**」的：服务器每次见你都像第一次，记不住你。
- 服务器靠「**发凭证 → 收凭证**」来记住你：
  1. 第一次访问 → 服务器回 `Set-Cookie`（发饼干）
  2. 客户端存下 Cookie
  3. 下次访问 → 客户端带 `Cookie`（还饼干）→ 服务器认出你
- **Cookie = 你手里的凭证；Session = 服务器记的那本账。**

> 🔐 **安全要点**：Cookie、User-Agent、Referer 都是**客户端自己填、能伪造**的。判断标准一句话：**「能改 + 不唯一 = 不能当身份证明」**。Cookie 也能伪造——改成别人的有效值 = 顶替身份，这就是「会话劫持」的老家。

---

## Day 12 · URL 解剖 + 查询参数 + URL 编码

### URL 六段

| 段 | 名称 | 英文 | 干什么 |
|---|---|---|---|
| scheme | 协议 | scheme | 用什么规则通信（http/https） |
| host | 主机/域名 | host | 哪台机器；域名靠 **DNS 翻译成 IP** |
| port | 端口 | port | 机器的哪个「门」 |
| path | 路径 | path | 服务端资源位置（可能对应真实文件，也可能只是程序路由） |
| query | 查询参数 | query string | 传给服务器的数据（`?key=value&key2=value2`） |
| fragment | 锚点/片段 | fragment | 浏览器本地定位用，**不发给服务器** |

### URL 编码（percent-encoding）

| 字符 | 编码 | 记忆钩子 |
|---|---|---|
| 空格 | `%20`（或 `+`） | 空格=0x20 |
| `&` | `%26` | 不然被当参数分隔符 |
| `?` | `%3F` | 不然被当 query 开头 |
| `=` | `%3D` | 不然被当 key=value 的等号 |
| `#` | `%23` | 不然被当锚点 |
| `%` | `%25` | `%` 的 ASCII 是 0x25 |
| `'` 单引号 | `%27` | SQLi 关键 |
| `<` | `%3C` | XSS 关键（0x3C） |
| `>` | `%3E` | XSS 关键 |
| 空字节 null | `%00` | 截断经典 |

> ⚠️ 坑：`%` 编自己 = `%25`（ASCII 0x25）；`%00` = 空字节 null（ASCII 第 0 号），**两码事别混**。
> ⚠️ 坑：URL 里有 `&` 或 `?` 时，整条 URL **必须加双引号**（shell 里 `&`=后台符、`?`=通配符）。

---

---

## Day 13 · HTML 表单（Form）+ 前后端分工

### 表单核心标签

| 标签 / 属性 | 干什么 | 英文 | 记忆钩子 |
|---|---|---|---|
| `<form action="..." method="...">` | 表单；action=数据交给谁，method=GET/POST | form=表单 | action=「找谁办事」 |
| `<input name="..." value="...">` | 输入框；name=参数名，value=值 | input=输入 | name=「这格数据叫啥」 |

### GET vs POST（数据放哪）

| 方法 | 数据位置 | 例子 |
|---|---|---|
| GET | URL 的 `?` 后面 | `/search?keyword=hello` |
| POST | 请求体 body | `-d "keyword=hello"` |

> ⚠️ 坑：GET 和 POST 数据格式**一样**都是 `名字=值`，只是位置不同。POST 只写 `-d "hello"`（漏名字）→ `parse_qs` 解出空字典。

### 数据流（今日核心）

浏览器读 form 的 `action` → **浏览器自己**直接向 action 的地址发请求，**不经过**发网页的服务器。8080=前端（发界面/输入入口），9000=后端（处理数据），`action` 决定数据流向。

### nano 编辑器

| 操作 | 按键 |
|---|---|
| 打开 / 新建 | `nano 文件名` |
| 换行 | Enter |
| 保存（写入） | Ctrl+O（Write Out）|
| 退出 | Ctrl+X（eXit）|

### Linux 连接符（易混）

| 符号 | 干什么 | 记忆 |
|---|---|---|
| `\|` 管道 | 把左边**输出**喂给右边（传数据；两侧各自子进程，`cd` 改不到主进程） | 水管 |
| `&&` 与 | 左边**成功**才执行右边 | 而且 |
| `;` 分号 | 无条件排队 | 排队 |

### 其他小知识点

- **favicon** = favorite icon，浏览器**自动**请求的网站小图标（HTTP 请求不只有你发的）。
- **乱码**：UTF-8 文件被 GBK 读 → 加 `<meta charset=utf-8>` 声明编码。
- `python3 -m http.server 8080`：`-m`=**m**odule（运行模块，**不是**「当前目录」），http.server 服务**当前目录**，8080=端口。
- `localhost`=本机（127.0.0.1），域名不能随便写，只有指向本机的才通。

---

## Day 14 · JavaScript 基础（让网页动起来）

### JS 是什么

- **JavaScript** = 一门**独立的**编程语言，跑在**浏览器**（客户端）里，让网页动起来。跟 Java **无关**（1995 蹭热度改名）。
- `<script> ... </script>` = 写 JS 代码的地方，浏览器一加载就执行（从上到下）。

### 核心概念

| 概念 | 英文 | 是啥 | 记忆钩子 |
|---|---|---|---|
| 变量 | `var 名 = 值` | 起名字的盒子，装一个值 | 盒子贴标签 |
| 函数 | `function 名() { ... }` | 一段有名字的代码，喊名字就执行 | 有名字的流程 |
| 弹窗 | `alert('字')` | 弹小窗 | alert=警报 |
| 打印 | `console.log(x)` | 在控制台打印 | log=日志 |
| 文档 | `document` | 当前网页 | document=文档=页面 |
| 按 id 找元素 | `getElementById('id')` | 找到指定 id 的元素 | get+element+by+id |
| 元素内容 | `.innerHTML` | 元素肚子里的 HTML（改它=改显示） | inner=里面 |
| 输入框值 | `.value` | 输入框当前装着的字（实时读） | value=值 |
| 点击触发 | `onclick="函数()"` | 点了才执行 | on=当…时+click=点击 |

### 读 → 存 → 写（今日核心套路）

```javascript
function show() {
  var t = document.getElementById('txt').value;   // 读：找到输入框，取它的值
  document.getElementById('out').innerHTML = t;   // 写：把值塞进显示区
}
```

### 易混对照表

| 对比 | 区别 |
|---|---|
| `id` vs `name` | id 给 **JS** 用（不提交）；name 给**服务器**用（表单提交才拼 `name=值`） |
| HTML `value="x"` vs JS `.value` | 前者=**默认值**（出厂就填好）；后者=**运行时当前值** |
| `value` vs `placeholder` | value=真填的字（能提交）；placeholder=灰色提示（非真值） |
| JS vs Java | 无关，两种语言 |
| `+` 对数字/字符串 | 数字=加法；字符串=胶水拼接（`"张"+"三"`→`"张三"`） |

### ⚠️ 坑

- `<script>` 里**只能写 JS 代码**，不能塞 HTML 标签（`<button>` 要放 `<body>` 里、`<script>` 外）。
- `head`/`body`/`html` 可省略（浏览器自动补全），但 `<meta charset="utf-8">` **不能省**（否则中文乱码）。
- 控制台空白 → 先 `cat` 文件确认 `console.log` 真的写进去了，再 Ctrl+F5 强刷。

---

## Day 15 · innerHTML 的双重身份 + XSS 入口

### innerHTML vs textContent（今日核心）

| 方法 | 英文 | 行为 | 类比 |
|---|---|---|---|
| `.innerHTML` | inner(内层)+HTML | 把内容当**指令执行**（解析 HTML 标签） | 下命令 |
| `.textContent` | text(文字)+content(内容) | 把内容当**文字打印**（不解析标签） | 复印文字 |

> 💡 核心区别一个字：**执行**。innerHTML 会「执行」标签（触发加载/事件），textContent 从头到尾不执行任何东西——所以同样输入，innerHTML 区会弹窗、textContent 区不会。

### XSS 最小 payload

`<img src=x onerror=alert(1)>`

| 部分 | 英文 | 意思 |
|---|---|---|
| `<img>` | image（图片） | 图片标签 |
| `src=x` | source（来源） | 去加载叫 `x` 的图（不存在） |
| `onerror` | on+error | 加载失败时执行后面代码 |
| `alert(1)` | alert（弹窗） | 弹窗显示 1（可改成 `"名字"`） |

### 弹窗触发链

img 加载 `src=x`（不存在）→ 加载失败 → 触发 `onerror` → 执行 `alert` → 弹窗。

> 💡 为什么故意写不存在的图 `x`？为「**必然失败**」，好触发 onerror——这是 XSS 借「必然失败动作」触发代码的经典思路。⚠️ 只在自家 `localhost` 页面练，别拿去试别人网站。

### 0.0.0.0 vs localhost（监听地址 vs 目标地址）

| 地址 | 角色 | 能当网址进吗 |
|---|---|---|
| `0.0.0.0` | **监听**地址（通配「所有接口都听」） | ❌ 不是具体门牌号 |
| `localhost` / `127.0.0.1` | **目标**地址（「去哪」） | ✅ 能 |

> 服务打印 `Serving HTTP on 0.0.0.0 port 8080` = 「门全开着」，不是地址；浏览器要进用 `localhost:8080/xx.html`。

### ⚠️ 坑

- `!` 在 JS 里是「取反/非」运算符（not），表示「感叹号字符」要写 `"!"`（字符串加引号）。
- `<script>` 里只能写 JS，HTML 标签别塞进去（承接 Day 14）。

---

## Day 16 · JavaScript 事件（Events）+ 改外表

### 事件 = 「当 XX 发生时，自动执行某段 JS」

命名规律：**on + 动作词**（on = 「当……的时候」）

| 事件 | 拆开 | 意思 | 记忆钩子 |
|---|---|---|---|
| `onclick` | on+click（点击） | 当点击时 | click「可利克」=点 |
| `onmouseover` | on+mouse（鼠标）+over（在…上） | 当鼠标移入时 | over「欧文」=悬上面 |
| `onmouseout` | on+mouse+out（出去） | 当鼠标移出时 | out「奥特」=出去 |
| `onload` | on+load（装载） | 当页面加载完时 | load「漏的」=装货 |
| `onerror` | on+error（错误） | 当出错时 | error「艾若」=错误 |
| `oninput` | on+input（输入） | 当输入时 | input「因普特」=输入 |

### 事件的挂法

```javascript
// JS 里挂（推荐，代码集中）
document.getElementById("btn").onclick = function() {
  // 点的时候才执行这里的代码（挂上≠立刻跑，触发才跑）
};
```

```html
<!-- HTML 属性里挂 -->
<button onclick="函数名()">
```

### 改「外表」：style

`element.style.color = "red"` —— style（样式）管外表，color（颜色）是外表一项（red/blue/black…）。

### window.onload

`window.onload = function(){...}` —— window=整个页面，页面加载完**自动执行**，不用点不用移。

### 读→存→写（事件版）

```javascript
document.getElementById("ru").oninput = function() {
  var t = document.getElementById("ru").value;    // 读：每次输入读最新值
  document.getElementById("show").textContent = t; // 写：当文字打印（安全）
};
```

> 💡 「读」必须放进事件函数**里面**，才能每次触发都读最新值；放外面只在页面加载时读一次（那时框还是空的）。

### ⚠️ 坑

- **中文全角括号 `（）` 混进 JS**：函数调用必须用英文半角 `()`；全角「胖」半角「瘦」，写代码切英文输入法。
- **`.value` 只属于 `<input>`**：`.value` 读写「框里用户打的值」；改 `<h1>`/`<p>` 等文字元素要用 `.innerHTML` 或 `.textContent`。
- **显示用户输入用 `.textContent` 不用 `.innerHTML`**：innerHTML 会执行输入里的 HTML/JS（=XSS），textContent 只当文字打印（承接 Day15）。

---

## Day 17 · Python 发 HTTP 请求 + 路径探测脚本

### 三个新词

| 词 | 英文全称 | 中文 | 记忆钩子 |
|---|---|---|---|
| `import` | import | 导入 | 把**工具箱**搬进程序 |
| `urllib` | **URL** **lib**rary | 网址库 | url + lib |
| `urlopen` | url + **open** | 打开网址（**不画页面**） | 像浏览器敲地址 |

（`urllib` 是 **标准库**：装了 Python 就有，**不用 pip install**。）

### 核心代码骨架（探测脚本）

```python
import urllib.request
import urllib.error

paths = ["index.html", "backup.zip"]         # 候选路径清单
count = 0                                     # 计数器：循环【外】初始化
for path in paths:                            # 循环【内】：一个一个试
    url = "http://localhost:8080/" + path     # 拼成完整网址
    try:                                      # 试一试：
        r = urllib.request.urlopen(url)       #   访问（2xx 成功）
        print(r.status, path)                 #   r.status = 数字 200
        count += 1                            #   成功才 +1（+= 是简写）
    except urllib.error.HTTPError as e:       # 4xx/5xx 会【抛异常】
        print(e.code, path, "(没找到)")         #   e.code = 数字 404
print("找到了", count, "个存在的页面")          # 循环【外】：报总数
```

### 三个位置决定成败（同 Day 14「读放函数外只跑一次」）

| 写在哪 | 效果 |
|---|---|
| `count = 0` 循环**外** | 只初始化一次（正确） |
| `count += 1` 循环**内**、成功支 | 每成功一次加一次（正确） |
| `print(...)` 循环**外** | 全部跑完再报总数（正确） |

### try / except（今日核心）

- `try:` = 试一下这段；`except ... as e:` = 出了这种错误就走这段（`e` 是错误对象，`e.code` 取状态码）。
- **有兜网** → 遇到 404 只是换条路走；**没兜网** → 第一个 404 就让脚本**当场死掉**，后面的路径**根本不会被请求**。
- **curl 拿到 404 只打印，Python 拿到 404 会「翻脸报错」** —— 这是两者最大的行为差异。
- 探测时 404 是**常态**，所以兜网是必需品。

### 状态码细分辨（渗透意义）

| 状态码 | 含义 | 探测时意味着什么 |
|---|---|---|
| 200 | 正常 | 页面存在、可访问 |
| 301 / 302 | 跳转 | 存在，可能换了地址 |
| 401 | 需要认证 | 存在，要凭证 |
| **403** | **禁止访问** | **存在但不让看** —— 不是「没找到」！ |
| 404 | 不存在 | 大概率真没有 |
| 500 | 服务器内部错误 | 请求可能**碰到了东西**，值得深挖 |

> 💡 把 403 一律标成「没找到」是新手常见错，写报告会误导人。**403 往往说明「这里有东西，只是被拦住了」**。

### ⚠️ 坑

- **多行脚本别塞进 `python3 -c "..."`**：`-c` 只适合**一行**命令；而且外层双引号里再写双引号会被 shell **提前闭合**（内层 `"index.html"` 的引号一出现就把外层吃断）→ 报出 `url = http://localhost:8080/ + path` 这种莫名语法错（引号凭空消失）。**多行一律 `nano xxx.py` 写文件 → `python3 xxx.py`**。
- 粘贴进 nano 后**瞄一眼缩进**（Python 靠缩进认从属关系）。
- `r.status` / `e.code` 是**数字**，比较用 `==`：`if r.status == 200:`，别加引号。
- 变量名用英文 `count`（别人的代码里计数器都叫 count，认脸熟）。
- **`print` 太长怎么换行**：**括号里面可以随便回车**（括号没闭合，Python 就知道「话没说完」）：
  ```python
  print("一共检查了", total, "个路径",
        "存在", ok, "个", "不存在", bad, "个")
  ```
  不在括号里想续行，得在末尾写反斜杠 `\`（backslash，续行符），但**不推荐**（丑、容易漏）。
- **能拆就拆**：要输出两行内容，就直接写**两条 `print`**，别硬拼一条超长的 —— 可读性 > 炫技。
- **缩进只用空格、每层 4 个，永远别按 Tab 键**。混用会报 `TabError: inconsistent use of tabs and spaces in indentation`（两个字符在屏幕上长得一样，肉眼看不出来，特别阴）。
  - 查：`cat -A 文件` → Tab 显示成 `^I`，空格就是普通空白
  - 救：`expand -t 4 旧.py > 新.py`（把 Tab 展开成 4 个空格）

---

## Day 18 · 字典文件（wordlist）+ 目录爆破雏形

### 核心概念

| 词 | 英文全称 | 中文 | 记忆钩子 |
|---|---|---|---|
| wordlist | word + list | 字典 / 单词表（**一行一个词**） | 一本"候选名字"的清单 |
| dictionary attack | — | 字典攻击 | 靠**规模**枚举，不靠聪明 |
| brute force | — | 暴力破解（蛮力） | 一条条硬试 |

> ⚠️ **字典文件**（txt，一行一词）≠ Python 的 **`dict`**（那个也叫"字典"）——两个东西，别混。

### 读文件（新技能，以后天天用）

| 代码 | 英文 | 干什么 | 记忆钩子 |
|---|---|---|---|
| `open("x.txt")` | open | 打开文件 | 开抽屉 |
| `with open(...) as f:` | with / as | 用完**自动关**文件，起个小名 `f` | 自动关门器 + 起绰号 |
| `f.read()` | read | 一口气读成**一个超长字符串** | 整包倒出来 |
| `.splitlines()` | split + lines | 按行切成**列表**（顺手去掉 `\n`） | 按行裁开 |
| `f.readlines()` | read + lines | 也切列表，但**每行带 `\n`**（要再 `.strip()`） | - |
| `pass` | pass | 什么都不做（**占位**） | 接住了但不说 |

### 骨架（读字典 → 分类 → 计数）

```python
import urllib.request
import urllib.error

count = 0                                  # 计数器：循环【外】清零
with open("wordlist.txt") as f:            # 打开字典
    words = f.read().splitlines()          # 按行切成列表

for w in words:                            # 一条条试
    url = "http://localhost:8080/" + w
    try:
        r = urllib.request.urlopen(url)
        if r.status == 200:                # == 比较；数字【不加引号】
            print("[+]", w)
            count += 1                     # 成功才 +1
    except urllib.error.HTTPError as e:
        pass                               # 404 静默跳过
print("发现", count, "个存在的路径")        # 循环【外】报总数
```

### 比较运算符（必背）

| 符号 | 读法 | 意思 |
|---|---|---|
| `==` | equal | 等于 |
| `!=` | not equal | **不等于** |
| `>` `<` `>=` `<=` | | 大于 / 小于 / 大于等于 / 小于等于 |

### ⚠️ 坑

- **`if` 后面不能空**：`if :` → `SyntaxError`（条件没写完）。要 `if r.status == 200:`。**⚠️ 已复发两次**。
- **`=` 是赋值，比较用 `==`**。
- **"不等于"是 `!=`**：不是 `！==`（那是 **JS** 写法，Python 没有）；且 `!` 必须**半角**（全角 `！` 电脑不认，跟全角括号 `（）` 一家）。
- **`except` 块不能删、也不能空**：删了 = 没兜网，404 又当场崩；空着报 `IndentationError` → 塞 `pass`。
- **必须在 `wordlist.txt` 同目录跑脚本**：否则 `FileNotFoundError`（站错地方了，不是脚本错）。
- **`f.read` 漏括号** = 只拿到"函数本身"，没真读（调用带括号 `.read()`，属性不带 `r.status`）。

---

## Day 18 延伸 · Git / GitHub（把代码传上网）

### 为什么要有 git（一句话）

**git = 本地存档系统**（每次 commit 存一个档）；**GitHub = 网上的公开保管箱**。git 存在你电脑里，`push` 之后才送到 GitHub。

### 一次性配置（只做一次）

| 命令 | 干什么 | 英文 | 记忆钩子 |
|------|--------|------|---------|
| `git config --global user.name "名字"` | 设提交署的名 | **config**=配置 | 配一次，全局生效 |
| `git config --global user.email "邮箱"` | 设提交用的邮箱 | | **必须能关联你的 GitHub 账号** |
| `git config --global init.defaultBranch main` | 新仓库默认分支叫 main | default+Branch | 免得每次都看到 master 那堆提示 |
| `git config --global --list` | 查看全部全局配置 | list=清单 | |

> ⚠️ **邮箱会公开显示在每条提交里**。不想暴露真邮箱，用 GitHub 的匿名地址：`你的用户名@users.noreply.github.com`
> ⚠️ **前缀必须等于你的 GitHub 用户名**（写错 → 提交不算你的，贡献图不亮）。

### 日常四步（记这四个就够用）

| 命令 | 干什么 | 英文 | 记忆钩子 |
|------|--------|------|---------|
| `git init` | 把当前文件夹变成 git 仓库 | **init**ialize=初始化 | 一个文件夹只做一次 |
| `git add 文件` | 把改动放进「待提交区」 | add=添加 | 挑出要存档的 |
| `git commit -m "说明"` | 打包存档 | **commit**=提交 | 存一个档 |
| `git push` | 把本地存档推到 GitHub | push=推 | 上传 |

> ⚠️ **`-m` = message（消息）**：说明直接写在命令里，就不会弹出编辑器来卡你。**提交必须有说明**，不写 git 直接拒绝（报「提交消息为空」）。
> ⚠️ `git add .` = 添加**全部**改动；想只传指定文件就写文件名（能顺手排除垃圾文件）。

### 查看状态

| 命令 | 干什么 | 记忆钩子 |
|------|--------|---------|
| `git status` | 看现在有什么改动 / 谁在待提交区 | 体检报告 |
| `git log --oneline` | 看提交历史（一行一条） | 流水账 |
| `git remote -v` | 看关联的远程仓库地址（**空 = 还没连 GitHub**） | 打电话给谁 |
| `git ls-files` | 看仓库里被跟踪的文件清单 | 点名 |

### 出错后的补救

| 命令 | 干什么 | 记忆钩子 |
|------|--------|---------|
| `git commit --amend --reset-author --no-edit` | **回头改**最后一次提交的作者信息 | **amend**=修正 |
| `git branch -m main` | 把当前分支改名 | **-m**=move |
| `git rm --cached 文件` | 从仓库移除，但**本地文件保留** | `--cached`=只动索引不动文件 |

> ⚠️ 改过提交内容后，**commit 哈希值会变**（那是「内容指纹」，正常现象不是出错）。

### .gitignore（忽略清单）

| 命令 | 干什么 |
|------|--------|
| `echo "*.save" > .gitignore` | 把 `*.save` 写进忽略清单（`>` = **重定向**，把输出写进文件） |

用途：排除密码文件（`.env`）、日志、临时文件、备份文件。

> 🔐 **安全要点**：往公开仓库推东西前，先确认**没有密钥 / Token / 密码**。

### 读 push 输出：只看最后一行

```text
Enumerating objects... / Counting objects... / Compressing objects...
Writing objects: 100% (3/3), 392 bytes
To https://github.com/用户名/仓库名.git
   b3ab76b..4962503  main -> main      ← 只看这行，有它就是成功
```

### hint vs error（关键生存技能）

| 关键词 | 意思 | 你要做什么 |
|--------|------|-----------|
| **`hint:`** | 提示、建议 | **完全不用管**，不影响结果 |
| **`error:` / `fatal:`** | 出错了 | **必须处理**，否则命令没生效 |

---

## 🧩 常用组合拳（跨 Day 复用）

| 场景 | 命令 |
|------|------|
| 看完整请求+响应（含头） | `curl -v http://127.0.0.1:8000/` |
| 存 Cookie | `curl -c jar.txt 网址` |
| 带 Cookie | `curl -b jar.txt 网址` |
| 亲手验证会话机制 | `curl 网址`(空) → `curl -c jar.txt 网址` → `curl -b jar.txt 网址`(uid=xxx) |
| 带 query 参数测 | `curl "http://localhost:9000/hello?id=1&name=test"` |
| 让 `&` 成为值的一部分 | `curl "http://localhost:9000/?a=%26+"`（`%26`=&，`+`=空格） |
| 亲手验证 URL 解码（看 `%26`→`&`、`+`→空格） | `python3 -c "from urllib.parse import unquote_plus; print(unquote_plus('a=%26+%26'))"` → `a=& &` |
| 模拟 GET 表单提交 | `curl "http://localhost:9000/search?keyword=hello"` |
| 模拟 POST 表单提交 | `curl -d "keyword=hello" http://localhost:9000/search` |
| 输入即显示（JS 读→存→写） | `function show(){ var t=document.getElementById('txt').value; document.getElementById('out').innerHTML=t; }` |
| 演示 XSS 雏形（innerHTML 执行用户输入） | 输入框输入 `<img src=x onerror=alert(1)>` → `innerHTML` 写入 → 弹窗（`textContent` 写入则不弹） |
| 输入实时回显（安全写法） | `element.oninput = function(){ var t=element.value; 目标.textContent=t; }` |
| Python 批量探测路径（目录探测雏形） | `try: r=urllib.request.urlopen(url); print(r.status,path)` / `except urllib.error.HTTPError as e: print(e.code,path,"(没找到)")` |
| 起一个本地测试站点 | `cd ~/day17/site && python3 -m http.server 8080` |
| 用字典批量探测路径（目录爆破雏形） | `with open("wordlist.txt") as f: words=f.read().splitlines()` → `for w in words:` → `try: r=urlopen(url)` → `if r.status==200: print("[+]",w); count+=1` → `except ...HTTPError as e: pass` |
| 看文件内容的"原始样子"（暴露隐藏的 `\n`） | `python3 -c "print(repr(open('wordlist.txt').read()))"` |
| 对比 read() vs splitlines() | `python3 -c "print(open('wordlist.txt').read())"`（一大坨） vs 加 `.splitlines()`（列表） |
| **把改动传给 GitHub**（日常三步） | `git add 文件 && git commit -m "说明" && git push` |
| **首次把本地文件夹发布成 GitHub 仓库** | VS Code → 源代码管理（Ctrl+Shift+G）→ 左下角**账户图标先登录 GitHub** → 「发布分支」→ 选 `Publish to GitHub public repository` → 浏览器 Authorize（**全程免 token**） |
| **上传前自查（防泄密）** | `git status` 看要传什么 + `git ls-files` 看已跟踪什么 → 确认无密码/Token/隐私 |
