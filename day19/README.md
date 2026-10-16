# Day 19 · Python 发「带数据」的请求 + 会话（CookieJar）

日期：2026-10-15 ~ 10-16

## 今天做了什么

用 Python 模拟了一次完整登录：先 POST 提交账号密码，服务器发回一张 Cookie（会话票），
之后带着这张票访问只有登录用户才能看的 `/admin`，拿到页面里的内部暗号。
全程没有手写任何 session 值 —— 票是脚本自动保存、自动携带的。

## 关键代码

```python
import urllib.request
import urllib.parse
import http.cookiejar

# 饼干罐 + "自己会揣着罐子"的发送器（自动存 Cookie / 自动带 Cookie）
jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

headers = {
    "User-Agent": "Qzl-Scanner/1.0",
    "Referer": "http://127.0.0.1:9000/login"      # 请求头：我是从哪个页面来的
}

# 登录：字典 → "username=qzl&password=..." → 再变成字节（data= 只收 bytes）
data = urllib.parse.urlencode({
    "username": "qzl",
    "password": "websec123"
}).encode()

req = urllib.request.Request("http://127.0.0.1:9000/login", data=data, headers=headers)
with opener.open(req) as r:                       # 必须用 opener 发，票才会进罐子
    print("登录状态码:", r.status)
    print("登录返回:", r.read().decode("utf-8"))

# 带票访问受保护页面（同一个 opener，会自动把票塞进请求头）
req2 = urllib.request.Request("http://127.0.0.1:9000/admin", headers=headers)
with opener.open(req2) as p:
    print("最终URL:", p.geturl())                 # 实际访问到的最终 URL
    print("admin状态码:", p.status)
    print("admin返回:", p.read().decode("utf-8"))
```

## 怎么跑

```bash
cd ~/day19
python3 login_server.py     # 终端 A：起本地练习靶场（127.0.0.1:9000，Ctrl+C 停）
python3 login19.py          # 终端 B：跑脚本
```

预期输出：

```
登录状态码: 200
登录返回: <h1>登录成功</h1><p>你的会话令牌是 session=xxxxxxxx</p>   ← 令牌每次不同
最终URL: http://127.0.0.1:9000/admin
admin状态码: 200
admin返回: ... <p>内部暗号：FLAG-Cookie-2026</p>
```

## 踩的坑 / 学到什么

1. `urlopen(url)` 只能给一个网址，**装不下**请求头和数据 → 要先用 `Request` 把「去哪 + 怎么去 + 带什么」打包成一个完整请求。
2. `urlencode` 出来的是 **str（文字）**，而 `data=` 只收 **bytes（字节）** → 后面必须接 `.encode()`。
3. Cookie 是**请求头**，不是请求体 → GET 和 POST **都会**自动带票，不是"用 POST 把票交上去"。
4. 票是**登录成功**之后才发的（本地靶场 `GET /` 的响应头里没有 `Set-Cookie`）。
5. 401 = 服务器回话了但说「我不认识你」；403 = 认得你但不让你进；405 = 地址存在但不收这种请求方式。
6. `r.headers["不存在的头"]` **不报错**，会静默返回 `None` —— 比报错更危险，容易"跑通了但结果全错"。
7. 暗号在**正文（body）**里，不在响应头里 → 要从 `r.read().decode("utf-8")` 的结果里找。
8. **我实际卡住的**：`data=post` 一开始漏写了，脚本还在发 GET，服务器当然不认；
   后来又写成 `urllib.request.opener(...)` 报 `AttributeError`（`opener` 是我自己造的变量，应该用 `opener.open(...)`）；
   还把暗号写成 `p.headers["内部暗号"]`，拿到 `None` 才反应过来读错地方了。
9. 提交时才发现：**文件必须放进仓库目录**（`~/websec-journey/`）里，git 才看得见 ——
   放在学习工作区 `~/day19/` 的话，`git add .` 根本抓不到它。

## 环境说明

`login_server.py` 是本地练习靶场，只监听 `127.0.0.1`，账号密码均为练习用假数据，不对外提供服务。
