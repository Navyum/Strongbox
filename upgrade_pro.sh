#!/bin/bash

# Mac端 Strongbox Pro 激活脚本
# 使用方法：在终端中运行 ./upgrade_pro.sh

# 定义 plist 文件路径
PLIST_PATH="$HOME/Library/Group Containers/group.strongbox.mac.mcguill/Library/Preferences/group.strongbox.mac.mcguill.plist"

echo "开始设置 Strongbox Pro..."

# 1. 删除现有的 plist 文件
echo "删除现有的配置文件..."
rm -f "$PLIST_PATH"

# 2. 创建新的 plist 文件并设置必要的值
echo "创建新的配置文件..."
plutil -create xml1 "$PLIST_PATH" && \
plutil -insert isPro -bool true "$PLIST_PATH" && \
plutil -insert fullVersion -bool true "$PLIST_PATH" && \
plutil -insert appHasBeenDowngradedToFreeEdition -bool false "$PLIST_PATH"

# 3. 验证设置
echo "验证设置..."
plutil -p "$PLIST_PATH"

echo "设置完成！请完全退出 Strongbox 应用（包括菜单栏图标），然后重新启动应用。" 
