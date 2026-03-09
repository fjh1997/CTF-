INSTALL_DIR="/mnt/workspace/sakura_frp"
API_MIRROR="https://nya.globalslb.net/natfrp/client/"

echo "================================================="
echo "   Sakura Frp 魔塔容器特供版安装脚本 (无 systemd)   "
echo "================================================="

# 1. 检查并创建目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1

# 2. 获取用户 Token
read -p "请输入你的 Sakura Frp 访问密钥 (Access Token) 并回车: " USER_TOKEN
if [ -z "$USER_TOKEN" ]; then
    echo "错误：访问密钥不能为空，安装终止！"
    exit 1
fi

# 3. 判断系统架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then 
    FRP_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then 
    FRP_ARCH="arm64"
else
    echo "错误：不支持的系统架构 $ARCH"
    exit 1
fi

# 4. 下载客户端
echo "正在下载客户端 (架构: $FRP_ARCH)..."
wget -O natfrpc "${API_MIRROR}natfrpc_linux_${FRP_ARCH}"

if [ $? -ne 0 ]; then
    echo "错误：下载失败，请检查网络！"
    exit 1
fi
chmod +x natfrpc

# 5. 生成一键启动脚本
echo "正在生成启动脚本 start.sh..."
cat > start.sh << EOBS
#!/bin/bash
cd $INSTALL_DIR

# 检查是否已经运行
if pgrep -x "natfrpc" > /dev/null
then
    echo "Sakura Frp (natfrpc) 已经在运行中了！"
else
    echo "正在启动 Sakura Frp..."
    # 使用 nohup 后台运行，并将日志重定向
    nohup ./natfrpc -f "$USER_TOKEN" > frp.log 2>&1 &
    sleep 2
    echo "启动成功！日志文件已保存在: $INSTALL_DIR/frp.log"
fi
EOBS
chmod +x start.sh

# 6. 生成一键停止脚本
echo "正在生成停止脚本 stop.sh..."
cat > stop.sh << EOBS
#!/bin/bash
if pgrep -x "natfrpc" > /dev/null
then
    pkill -x natfrpc
    echo "已成功停止 Sakura Frp 进程。"
else
    echo "Sakura Frp 当前没有在运行。"
fi
EOBS
chmod +x stop.sh

echo "================================================="
echo " 🎉 安装完成！所有文件已永久保存在: $INSTALL_DIR"
echo "================================================="
echo " 日常使用命令（容器重启后只需运行第一条）："
echo " ▶ 启动穿透：bash $INSTALL_DIR/start.sh"
echo " ⏹ 停止穿透：bash $INSTALL_DIR/stop.sh"
echo " 📄 查看日志：tail -f $INSTALL_DIR/frp.log"
echo "================================================="
