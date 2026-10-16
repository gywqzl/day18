import urllib.request
import urllib.parse
import http.cookiejar

jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

headers = {
    "User-Agent": "Qzl-Scanner/1.0",
    "Referer": "http://127.0.0.1:9000/login"
}

# 登录
data = urllib.parse.urlencode({
    "username": "qzl",
    "password": "websec123"
}).encode()

req = urllib.request.Request("http://127.0.0.1:9000/login", data=data, headers=headers)
with opener.open(req) as r:
    print("登录状态码:", r.status)
    print("登录返回:", r.read().decode("utf-8", errors="ignore"))

# 访问 admin
req2 = urllib.request.Request("http://127.0.0.1:9000/admin", headers=headers)
with opener.open(req2) as p:
    print("最终URL:", p.geturl())
    print("admin状态码:", p.status)
    print("admin返回:", p.read().decode("utf-8", errors="ignore"))
