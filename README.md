# Day 18 - 目录扫描脚本（字典爆破雏形）

## 这是什么

我学习 Web 安全时写的第一个目录扫描工具。
从字典文件逐行读取路径名，对目标站逐个发 HTTP 请求，
把返回 200（存在）的路径打印出来。

## 怎么用

```bash
python3 dirscan.py
```

改 `wordlist.txt` 换扫描清单，改 `dirscan.py` 里的 `url` 换目标。

## 输出示例

```
[+] index.html
[+] secret.txt
一共发现了 7 个存在的路径
```

## 学到什么

- 用 Python 发 HTTP 请求（urllib）
- 用 `with open()` 读文件、`splitlines()` 切行
- 用 `try/except` 处理 HTTP 错误
- 把「手写在代码里的清单」改成「从文件读清单」—— 这就是字典攻击的雏形

## 合规声明

仅用于个人实验环境和已获授权的靶场（脚本默认指向本地 `localhost`）。
未经授权扫描他人系统是违法行为。
