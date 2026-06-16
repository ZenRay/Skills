#!/usr/bin/env bash
# Skills 项目环境激活脚本
# 使用方法: source .env.sh

set -e

echo "🚀 激活 Skills 开发环境..."
echo ""

# 1. 激活 Python 虚拟环境
echo "1️⃣  激活 Python 虚拟环境..."
if [ -d ".venv" ]; then
    source .venv/bin/activate
    echo "   ✅ Python $(python --version)"
    echo "   📍 路径: $(which python)"
else
    echo "   ❌ .venv 目录不存在"
    echo "   💡 请先执行: uv venv .venv --python 3.10 && source .venv/bin/activate && uv pip install -e .[dev]"
    return 1
fi

echo ""

# 2. 切换 Node.js 版本
echo "2️⃣  切换 Node.js 版本..."
if [ -f ".nvmrc" ]; then
    # 检查 nvm 是否可用
    if command -v nvm &> /dev/null; then
        nvm use 2>/dev/null || {
            echo "   ⚠️  Node.js $(cat .nvmrc) 未安装，正在安装..."
            nvm install $(cat .nvmrc)
        }
        echo "   ✅ Node.js $(node --version)"
        echo "   📍 路径: $(which node)"
    else
        echo "   ⚠️  nvm 未安装，跳过 Node.js 切换"
        echo "   💡 如需 Node.js，请先安装 nvm: https://github.com/nvm-sh/nvm"
    fi
else
    echo "   ⏭️  未找到 .nvmrc，跳过 Node.js"
fi

echo ""

# 3. 环境验证
echo "3️⃣  环境验证..."
python check_env.py

echo ""
echo "✨ 环境激活完成！"
echo ""
echo "📝 常用命令:"
echo "   python your_script.py     # 运行 Python 脚本"
echo "   pytest tests/             # 运行测试"
echo "   black your_script.py      # 格式化代码"
echo "   flake8 your_script.py     # 代码检查"
echo ""
echo "💡 退出环境: deactivate"
