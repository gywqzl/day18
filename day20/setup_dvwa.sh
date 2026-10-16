#!/bin/bash
# ==============================================================
# Day 20 · 本地靶场搭建脚本（LAMP + DVWA）
# 作用：装 Apache + PHP + MariaDB，把 DVWA 放到网站根目录，建好数据库和账号
# 用法：bash ~/day20/setup_dvwa.sh        （中途会让你输 WSL 密码）
# 重复跑：安全，会覆盖重建（数据库会被清空重来）
# ==============================================================
set -e

echo "==[1/7] 更新软件清单（apt update）=="
sudo apt update

echo "==[2/7] 安装 Apache + PHP + MariaDB =="
sudo DEBIAN_FRONTEND=noninteractive apt install -y apache2 mariadb-server php libapache2-mod-php php-mysql php-mbstring php-gd php-curl

echo "==[3/7] 启动 apache2 / mariadb，并设为开机自启 =="
sudo systemctl enable --now apache2 mariadb
echo -n "apache2 状态："; systemctl is-active apache2 || true
echo -n "mariadb 状态："; systemctl is-active mariadb || true

echo "==[4/7] 下载 DVWA 源码 =="
mkdir -p "$HOME/day20"
cd "$HOME/day20"
curl -L -o dvwa.tar.gz https://codeload.github.com/digininja/DVWA/tar.gz/refs/heads/master
tar xzf dvwa.tar.gz

echo "==[5/7] 搬到网站根目录 /var/www/html/dvwa =="
sudo rm -rf /var/www/html/dvwa
sudo mv DVWA-master /var/www/html/dvwa
sudo cp /var/www/html/dvwa/config/config.inc.php.dist /var/www/html/dvwa/config/config.inc.php

echo "==[6/7] 建数据库 dvwa，建专用账号 dvwa（密码 p@ssw0rd）=="
sudo mariadb <<'SQL'
DROP DATABASE IF EXISTS dvwa;
CREATE DATABASE dvwa;
CREATE USER IF NOT EXISTS 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';
CREATE USER IF NOT EXISTS 'dvwa'@'127.0.0.1' IDENTIFIED BY 'p@ssw0rd';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

echo "==[7/7] 修属主 + 放开上传目录 =="
sudo chown -R www-data:www-data /var/www/html/dvwa
sudo chmod -R 775 /var/www/html/dvwa/hackable/uploads

# ---- 以下是可选项，失败也不影响靶场使用 ----
set +e
echo "==[附加] 打开 allow_url_include（给以后的「文件包含」模块铺路）=="
PHPINI=$(ls /etc/php/*/apache2/php.ini 2>/dev/null | head -1)
if [ -n "$PHPINI" ]; then
  sudo sed -i 's/^allow_url_include *= *Off/allow_url_include = On/' "$PHPINI"
  sudo systemctl reload apache2
  echo "改的是：$PHPINI"
  grep -n '^allow_url_include' "$PHPINI"
fi

echo
echo "================= 搭建结束 ==================="
echo "浏览器（Windows 侧）打开： http://localhost/dvwa/setup.php"
echo "DVWA 默认账号：admin / password"
echo "（注意：这个练习站故意漏洞百出，只在自己机器上打）"
