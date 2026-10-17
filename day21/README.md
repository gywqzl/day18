# Day 21 · PortSwigger 第一个官方 lab

**Lab**：Reflected XSS into HTML context with nothing encoded
（反射型 XSS，落在 HTML 上下文里，服务器没有做任何编码）
**难度**：Apprentice（学徒）
**题面**：https://portswigger.net/web-security/cross-site-scripting/reflected/lab-html-context-nothing-encoded

## 题目要求

- 背景：搜索功能里有一个简单的反射型（reflected）跨站脚本漏洞。
- 目标：执行一次跨站脚本攻击，调用 `alert` 函数。

## 输入点与上下文

- **入口**：首页搜索框。表单字段 `name=search`，所以提交后 URL 上是 `?search=...`。
- **出口**：`<h1>0 search results for ' 你的输入 '</h1>` —— 服务器把输入拼在这两个单引号之间。
- **上下文（context）**：**标签之间的文字位置**（题目名里的 "HTML context"）。

## payload 与为什么能生效

```html
<img src=x onerror=alert("Q")>
```

1. 输入从 URL 参数 `search` 进来；
2. 服务器把输入**原样**拼进 HTML（nothing encoded，没有任何转义）；
3. 浏览器读到 `<img ...>` 时把它当**真标签**解析 → 去加载 `x` 失败 → 自动触发 `onerror` → 里面的 JS 执行 → 弹窗。

一句话：**服务器把我的输入当成了网页代码的一部分交给浏览器，浏览器照做。**

## 证据

**① lab 判分**：lab 页显示 `✓ 已解决`。
（平台会在 lab 页面里注入脚本，把 `window.alert` 换成自己的版本；payload 一调用 `alert` 就上报服务器，绿色药丸轮询后变 Solved。）

**② curl 拿到服务器原文**（未编码的物证）：

```bash
curl -s -o /tmp/xss.html "https://0a0c007c046cc90680330306000800c9.web-security-academy.net/?search=%3Cimg+src%3Dx+onerror%3Dalert(%22Q%22)%3E"
grep -o "onerror.\{0,20\}" /tmp/xss.html
```

输出：

```
onerror=alert("Q")>'</h1>
```

`>` 和 `"` 都还是原字符，没有变成 `&gt;` / `&quot;` → 证明服务器**没有编码**。
结尾的 `'` 和 `</h1>` 是模板外壳，说明 payload 正好落在**标签之间的文字区**。

## 我实际卡住的

（本人原话）

一开始忘了 `<` `>` 和引号也需要做 `%` 编码，并且在写 payload 的时候犯了个低级错误，写成了 `onerror.("Q")`，导致折腾了一会儿才弄好。

另外两次踩坑（都是"一个字符 / 一层解析"的问题）：

- `"` 直接写在 curl 的双引号里会被 **shell** 吃掉，发出去的 payload 退化成 `alert(Q)` → JS 报 `ReferenceError`、不弹窗。
- 末尾把 `%3E`（`>`）手滑写成 `%3D`（`=`）→ `<img>` 标签没闭合，把后面的 `'</h1>` 也吞进属性值，`onerror` 里变成 `alert("Q")=` → `SyntaxError`。

教训：**拼长命令先 `echo` 一遍**（看 shell 真正送出什么）；**写完编码先 `unquote_plus` 反解一遍**（看和自己想的对不对得上）。

## 我学到了什么（费曼）

1. **上下文（context）**：输出去的位置不同，payload 就得换。我这次输入落在 `<h1>` 和 `</h1>` 之间的**文字位置**，所以我自己写的 `<img ...>` 会被浏览器当成**真标签**去解析；要是输入落在属性（`value="..."`）里面，标签就开不出来，得换别的写法。
2. **nothing encoded**：服务器把输入**原样**拼进页面，`<` 和 `"` 一个都没改，所以浏览器把它当代码执行。如果服务器做了转义（`<` → `&lt;`），它在源码里就是一堆实体（`&lt;img … &gt;`），浏览器只会把这段**当文字显示**，不执行。
3. **读题 = 先确定三件事**：输入在哪进（`name=search`）、从哪出（`<h1>` 里）、出来以后是什么位置。这三步定了，剩下的就是选 payload。
