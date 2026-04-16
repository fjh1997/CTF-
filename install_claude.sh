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
npm install -g @anthropic-ai/claude-code 2>/dev/null || sudo env "PATH=$PATH" npm install -g @anthropic-ai/claude-code

# 3. 获取 API Key
read -p "请输入您的阿里云百炼 API Key: " API_KEY < /dev/tty
if [ -z "$API_KEY" ]; then
    echo -e "\033[31m[!] API Key 不能为空。\033[0m"
    exit 1
fi

BASE_URL="https://dashscope.aliyuncs.com/apps/anthropic"
MODEL="qwen-plus"

# 4. 写入 Claude Code 配置文件
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
mkdir -p "$CLAUDE_DIR"

echo -e "\033[36m[>] 正在写入 $SETTINGS_FILE...\033[0m"
cat > "$SETTINGS_FILE" <<SETTINGS_EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "$BASE_URL",
    "ANTHROPIC_AUTH_TOKEN": "$API_KEY",
    "ANTHROPIC_MODEL": "$MODEL"
  }
}
SETTINGS_EOF

echo -e "\n\033[32m[v] 安装与配置完成！\033[0m"
echo "-------------------------------------------"
echo "1. 在项目目录下输入 'claude' 即可启动。"
echo "2. 默认模型已设置为: $MODEL"
echo "3. 配置文件: $SETTINGS_FILE"
echo "-------------------------------------------"
