# Day 20 · 在本地搭一个靶场（LAMP + DVWA）

## 今天做了什么

1. 在 WSL Ubuntu 里装起一套真网站：**Apache（接送请求）+ PHP（干活）+ MariaDB（存数据）**，也就是常说的 **LAMP**。
2. 把 **DVWA**（Damn Vulnerable Web Application，故意做得到处是漏洞的练习站）放到网站根目录跑起来，登录后把安全级别设成 **Low**。
3. 第一次在**真实网站**上打出 XSS：在 `XSS (Reflected)` 模块里让页面弹出我自己的名字，并把它和 Impossible 级别做了对比。
4. 用 `curl -I` / `sudo ss -tlnp` / `tail access.log` 自己验收了这套环境，并在 Apache 日志里看到**自己刚才打的 payload** —— 第一次见到"攻击痕迹"长什么样。

## 环境长什么样

| 组件 | 版本 | 端口 | 角色（人话） |
|---|---|---|---|
| Ubuntu (WSL2) | 26.04.1 LTS | — | 操作系统 |
| Apache | 2.4.66 | 80 | 收 HTTP 请求、送文件、把 `.php` 交给 PHP |
| PHP | 8.5 | — | 动态生成 HTML（在服务器上跑） |
| MariaDB | 11.8.6 | 3306 | 数据库，存数据 |
| DVWA | master | 80 (`/dvwa/`) | 练习靶场（**故意**漏洞百出） |

> Apache 和 PHP 是"两家"：Apache 只会读文件发文件，看不懂 `<?php ?>`；两者之间的桥是 `libapache2-mod-php`。

## 关键命令

```bash
# 1) 装环境（脚本 ~/day20/setup_dvwa.sh 里做的就是这个）
sudo apt install -y apache2 mariadb-server php libapache2-mod-php php-mysql

# 2) 启动服务 + 设为开机自启
sudo systemctl enable --now apache2 mariadb

# 3) 验收：服务活着吗 / 谁在听 80 和 3306
systemctl is-active apache2 mariadb
sudo ss -tlnp | grep -E ':80|:3306'

# 4) 验收：Web 服务真的在回话吗
curl -I http://localhost/
curl -I http://localhost/dvwa/login.php

# 5) 看日志（先认准是哪本账本）
ls -l /var/log/apache2/
tail -n 3 /var/log/apache2/access.log
```

## 怎么跑起来 + 预期看到什么

1. `bash ~/day20/setup_dvwa.sh`（中途要输 WSL 密码）
2. Windows 浏览器打开 `http://localhost/dvwa/setup.php` → 点 **Create / Reset Database**
3. 登录 `admin` / `password` → 左侧 **DVWA Security** 设成 **Low**
4. 左侧 **XSS (Reflected)** → 输入框里填 payload：

```html
<img src=x onerror="alert('Qzl')">
```

预期：页面弹出 `Qzl`（用的是 Day 15 学的那个最小 payload，只是把 `1` 换成了带引号的名字）。

## 我实际卡住的
 payload 写了 alert(Qzl) 弹窗不出来，因为其中的Qzl没加引号被当成变量名了，后来开 F12 Console 看到 ReferenceErro，加了引号就可以正常弹窗了
 以为 ss -tlnp 会直接列出程序名的，结果 80/3306 一片空白，我才想起来看别人的进程需要sudo权限才行

## 学到的东西

- **LAMP 四件套分工**：Apache 是"门口收发"、PHP 是"后厨干活"、MariaDB 是"仓库"；用 `python3 -m http.server` / `echo_server.py` / `SESSIONS = {}` 这三个"迷你版"对照着理解。
- **XSS（Cross-Site Scripting，跨站脚本）**：把攻击者的代码塞进网页，让**受害者的浏览器**去执行 —— 代码不在服务器上跑，是在别人机器上跑，所以能借用别人的身份和 Cookie。今天打的是 **Reflected（反射型）**。
- **弹窗没出现 ≠ 代码没执行**：真相在 **F12 → Console**（`alert(Qzl)` 不带引号会让 JS 找变量 `Qzl` → `ReferenceError`）。
- **Apache 访问日志一行 = 9 段**（combined 格式）：IP / 时间 / 请求行 / 状态码 / 字节数 / **Referer** / **User-Agent**。日志是防守方唯一的现场——我今天就在里面看到了自己刚发出去的 payload（URL 编码后的样子）。
- **静默失败**：`r.headers["打错的头名"]` 和 `r.headers["本来就没有的头"]` 都返回 `None`，长得一模一样，单看分不出哪种——比报错危险。

## 环境说明

- 靶场**只跑在本机**（`localhost` / `127.0.0.1`），DVWA 是**故意**做成有漏洞的练习站，**只在自己机器上打**。
- 合法授权环境：自己的实验环境 / CTF / PortSwigger Web Security Academy。不对任何未授权目标使用这里学到的手法。
