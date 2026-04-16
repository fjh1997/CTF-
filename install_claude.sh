#!/bin/bash
# Claude Code 一键安装与阿里云配置脚本 (Linux/macOS)

set -e

echo -e "\033[36m=== Claude Code 一键安装工具 (阿里云百炼版) ===\033[0m"

# 1. 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "\033[31m[!] 未检测到 Node.js。请先安装 Node.js (建议 v18+)。\033[0m"
    exit 1
fi

# 2. 安装 Claude Code
echo -e "\033[36m[>] 正在全局安装 @anthropic-ai/claude-code...\033[0m"
if command -v sudo &> /dev/null; then
    sudo npm install -g @anthropic-ai/claude-code
else
    npm install -g @anthropic-ai/claude-code
fi

# 3. 获取 API Key
read -p "请输入您的阿里云百炼 API Key: " API_KEY
if [ -z "$API_KEY" ]; then
    echo -e "\033[31m[!] API Key 不能为空。\033[0m"
    exit 1
fi

BASE_URL="https://dashscope.aliyuncs.com/apps/anthropic"
MODEL="qwen-plus"

# 4. 写入配置文件
SHELL_PROFILE=""
if [[ "$SHELL" == */zsh ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
else
    SHELL_PROFILE="$HOME/.profile"
fi

echo -e "\033[36m[>] 正在更新 $SHELL_PROFILE...\033[0m"
# 删除旧配置并添加新配置
sed -i'' -e '/ANTHROPIC_BASE_URL/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i'' -e '/ANTHROPIC_API_KEY/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i'' -e '/ANTHROPIC_MODEL/d' "$SHELL_PROFILE" 2>/dev/null || true

echo "export ANTHROPIC_BASE_URL=\"$BASE_URL\"" >> "$SHELL_PROFILE"
echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$SHELL_PROFILE"
echo "export ANTHROPIC_MODEL=\"$MODEL\"" >> "$SHELL_PROFILE"

echo -e "
\033[32m[v] 安装与配置完成！\033[0m"
echo "-------------------------------------------"
echo "1. 请执行 'source $SHELL_PROFILE' 或重启终端。"
echo "2. 在项目目录下输入 'claude' 即可启动。"
echo "3. 默认模型已设置为: $MODEL"
echo "-------------------------------------------"
