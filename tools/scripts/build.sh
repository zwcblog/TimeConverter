#!/bin/bash

# ====================================================================
# Timestamp Converter Pro Chrome Extension Build Script
# ====================================================================
# 此脚本用于构建Chrome扩展的发布包
# 使用方法: ./tools/scripts/build.sh [版本号]
# 例如: ./tools/scripts/build.sh 1.2
# ====================================================================

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# 设置版本号
VERSION=${1:-"1.1"}
echo -e "${BLUE}[INFO]${NC} 准备构建版本 ${VERSION}"

# 创建临时目录
TEMP_DIR="./tmp_build"
echo -e "${BLUE}[INFO]${NC} 创建临时目录..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 复制必要文件
echo -e "${BLUE}[INFO]${NC} 复制扩展文件..."
cp -r src/popup.html src/popup.js src/style.css src/manifest.json src/lib "$TEMP_DIR/"
cp -r assets/icons/icon16.png assets/icons/icon48.png assets/icons/icon128.png "$TEMP_DIR/"

# 修复manifest.json中的图标路径
echo -e "${BLUE}[INFO]${NC} 修复图标路径..."
sed -i.bak 's/"16": "..\/assets\/icons\/icon16.png"/"16": "icon16.png"/g' "$TEMP_DIR/manifest.json"
sed -i.bak 's/"48": "..\/assets\/icons\/icon48.png"/"48": "icon48.png"/g' "$TEMP_DIR/manifest.json"
sed -i.bak 's/"128": "..\/assets\/icons\/icon128.png"/"128": "icon128.png"/g' "$TEMP_DIR/manifest.json"
rm "$TEMP_DIR/manifest.json.bak"

# 更新版本号
echo -e "${BLUE}[INFO]${NC} 更新版本号为 ${VERSION}..."
sed -i.bak "s/\"version\": \"[0-9.]*\"/\"version\": \"$VERSION\"/g" "$TEMP_DIR/manifest.json"
rm "$TEMP_DIR/manifest.json.bak"

# 创建ZIP文件
echo -e "${BLUE}[INFO]${NC} 创建ZIP文件..."
ZIPFILE="dist/TimeConverterPro_v${VERSION}.zip"
cd "$TEMP_DIR"
zip -r "../$ZIPFILE" ./*
cd "$PROJECT_ROOT"

# 清理临时文件
echo -e "${BLUE}[INFO]${NC} 清理临时文件..."
rm -rf "$TEMP_DIR"

# 完成
echo -e "${GREEN}[成功]${NC} 构建完成: $ZIPFILE"
echo -e "${YELLOW}[提示]${NC} 你可以使用以下命令来发布扩展:"
echo -e "${YELLOW}[提示]${NC} ./tools/scripts/publish.sh"
echo -e "${BLUE}=====================================${NC}" 