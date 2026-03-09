INSTALL_DIR="/mnt/workspace/sakura_frp"

echo "================================================="
echo "   Sakura Frp (新版启动器) 魔塔特供安装脚本      "
echo "================================================="

# 1. 安装必要的依赖环境 (魔塔环境通常是基于 Debian/Ubuntu)
echo "[*] 正在安装解压和配置所需的依赖 (zstd, jq)..."
sudo apt-get update && sudo apt-get install -y curl tar zstd jq

# 2. 检查并创建工作目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1

# 3. 收集用户信息
read -p "请输入 Sakura Frp 访问密钥 (Token): " USER_TOKEN
if [ -z "$USER_TOKEN" ]; then
    echo "错误：访问密钥不能为空！"
    exit 1
fi

while true; do
    read -p "请输入远程管理密码 (至少8个字符): " REMOTE_PASS
    if [[ ${#REMOTE_PASS} -ge 8 ]]; then break; fi
    echo "错误：远程管理密码至少需要 8 字符！"
done

# 4. 判断系统架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then 
    FRP_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then 
    FRP_ARCH="arm64"
else
    echo "错误：不支持的系统架构 $ARCH"
    exit 1
fi

# 5. 下载并解压新版客户端压缩包 (.tar.zst)
echo "[*] 正在下载新版启动器包 (架构: $FRP_ARCH)..."
DOWNLOAD_URL="https://nya.globalslb.net/natfrp/client/launcher-unix/latest/natfrp-service_linux_${FRP_ARCH}.tar.zst"

curl -Lo - "$DOWNLOAD_URL" | tar -xI zstd --overwrite
if [ $? -ne 0 ]; then
    echo "错误：下载或解压失败，请检查网络！"
    exit 1
fi

# 赋予执行权限
chmod +x frpc natfrp-service

# 6. 生成新版必需的 config.json 配置文件
echo "[*] 正在生成配置文件..."
if [[ ! -f config.json ]]; then
    echo '{}' > config.json
fi

jq ". + {
    \"token\": $(echo "$USER_TOKEN" | jq -R .),
    \"remote_management\": true,
    \"remote_management_key\": $(./natfrp-service remote-kdf "$REMOTE_PASS" | jq -R .),
    \"log_stdout\": true
}" config.json > config.json.tmp
mv config.json.tmp config.json

# 7. 生成一键启动脚本
echo "[*] 正在生成控制脚本 start.sh..."
cat > start.sh << EOBS
#!/bin/bash
# 声明环境变量指向配置目录
export NATFRP_SERVICE_WD="$INSTALL_DIR"
cd "\$NATFRP_SERVICE_WD"

if pgrep -x "natfrp-service" > /dev/null; then
    echo "Sakura Frp 已经在运行中了！"
else
    echo "正在启动 Sakura Frp 新版守护进程..."
    nohup ./natfrp-service --daemon > frp.log 2>&1 &
    sleep 2
    echo "启动成功！日志文件保存在: $INSTALL_DIR/frp.log"
    echo "现在你可以去 Sakura Frp 官网后台启动你的隧道了！"
fi
EOBS
chmod +x start.sh

# 8. 生成一键停止脚本
echo "[*] 正在生成控制脚本 stop.sh..."
cat > stop.sh << EOBS
#!/bin/bash
if pgrep -x "natfrp-service" > /dev/null; then
    pkill -x natfrp-service
    pkill -x frpc
    echo "已成功停止 Sakura Frp 进程。"
else
    echo "Sakura Frp 当前未运行。"
fi
EOBS
chmod +x stop.sh

echo "================================================="
echo " 🎉 安装完成！所有文件已永久保存在: $INSTALL_DIR"
echo "================================================="
echo " ▶ 启动穿透：bash $INSTALL_DIR/start.sh"
echo " ⏹ 停止穿透：bash $INSTALL_DIR/stop.sh"
echo " 📄 查看日志：tail -f $INSTALL_DIR/frp.log"
echo "================================================="
