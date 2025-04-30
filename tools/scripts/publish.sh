#!/bin/bash

# ====================================================================
# Chrome Web Store Extension Publisher
# ====================================================================
# 此脚本用于上传和发布Chrome扩展到Chrome Web Store
# 使用方法: ./tools/scripts/publish.sh [版本号]
# 例如: ./tools/scripts/publish.sh 1.2
# ====================================================================

# ==================== 配置区域(请填写) ====================

# OAuth凭据(从Google Cloud Console获取)
CLIENT_ID="填写您的客户端ID"
CLIENT_SECRET="填写您的客户端密钥"
REFRESH_TOKEN="填写您的刷新令牌"

# 扩展信息
VERSION=${1:-"1.1"}
EXTENSION_ZIP_PATH="dist/TimeConverterPro_v${VERSION}.zip"
EXTENSION_ID="如果是更新现有扩展，填写扩展ID；如果是新扩展，留空"

# 发布选项 (可选值: public 或 trusted_testers)
PUBLISH_TARGET="public"

# 是否是更新现有扩展 (true 或 false)
IS_UPDATE="false"

# ==================== 脚本逻辑(无需修改) ====================

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 检查构建
if [ ! -f "$EXTENSION_ZIP_PATH" ]; then
  echo -e "${YELLOW}[警告]${NC} 未找到构建文件: $EXTENSION_ZIP_PATH"
  echo -e "${BLUE}[INFO]${NC} 正在运行构建脚本..."
  
  if [ -f "tools/scripts/build.sh" ]; then
    ./tools/scripts/build.sh "$VERSION"
  else
    echo -e "${RED}[错误]${NC} 构建脚本不存在: tools/scripts/build.sh"
    exit 1
  fi
  
  if [ ! -f "$EXTENSION_ZIP_PATH" ]; then
    echo -e "${RED}[错误]${NC} 构建失败，无法找到ZIP文件: $EXTENSION_ZIP_PATH"
    exit 1
  fi
fi

# 检查配置
function check_config() {
  echo -e "${BLUE}[INFO]${NC} 检查配置..."
  
  if [[ -z "$CLIENT_ID" || "$CLIENT_ID" == "填写您的客户端ID" ]]; then
    echo -e "${RED}[错误]${NC} 请提供有效的CLIENT_ID"
    exit 1
  fi
  
  if [[ -z "$CLIENT_SECRET" || "$CLIENT_SECRET" == "填写您的客户端密钥" ]]; then
    echo -e "${RED}[错误]${NC} 请提供有效的CLIENT_SECRET"
    exit 1
  fi
  
  if [[ -z "$REFRESH_TOKEN" || "$REFRESH_TOKEN" == "填写您的刷新令牌" ]]; then
    echo -e "${RED}[错误]${NC} 请提供有效的REFRESH_TOKEN"
    exit 1
  fi
  
  if [[ -z "$EXTENSION_ZIP_PATH" || "$EXTENSION_ZIP_PATH" == "填写您的扩展zip文件路径，例如: ./TimeConverterPro.zip" ]]; then
    echo -e "${RED}[错误]${NC} 请提供有效的扩展ZIP文件路径"
    exit 1
  fi
  
  if [[ ! -f "$EXTENSION_ZIP_PATH" ]]; then
    echo -e "${RED}[错误]${NC} 扩展ZIP文件不存在: $EXTENSION_ZIP_PATH"
    exit 1
  fi
  
  if [[ "$IS_UPDATE" == "true" && (-z "$EXTENSION_ID" || "$EXTENSION_ID" == "如果是更新现有扩展，填写扩展ID；如果是新扩展，留空") ]]; then
    echo -e "${RED}[错误]${NC} 更新扩展模式下必须提供有效的EXTENSION_ID"
    exit 1
  fi
  
  echo -e "${GREEN}[成功]${NC} 配置检查通过"
}

# 获取访问令牌
function get_access_token() {
  echo -e "${BLUE}[INFO]${NC} 获取访问令牌..."
  
  RESPONSE=$(curl -s "https://oauth2.googleapis.com/token" \
    -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&refresh_token=$REFRESH_TOKEN&grant_type=refresh_token")
  
  ACCESS_TOKEN=$(echo $RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
  
  if [[ -z "$ACCESS_TOKEN" ]]; then
    echo -e "${RED}[错误]${NC} 无法获取访问令牌。响应: $RESPONSE"
    exit 1
  fi
  
  echo -e "${GREEN}[成功]${NC} 已获取访问令牌"
}

# 上传扩展
function upload_extension() {
  echo -e "${BLUE}[INFO]${NC} 正在上传扩展..."
  
  if [[ "$IS_UPDATE" == "true" ]]; then
    echo -e "${YELLOW}[更新]${NC} 正在更新现有扩展 ID: $EXTENSION_ID"
    RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "x-goog-api-version: 2" \
      -X PUT \
      -T "$EXTENSION_ZIP_PATH" \
      "https://www.googleapis.com/upload/chromewebstore/v1.1/items/$EXTENSION_ID")
  else
    echo -e "${YELLOW}[新建]${NC} 正在上传新扩展"
    RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "x-goog-api-version: 2" \
      -X POST \
      -T "$EXTENSION_ZIP_PATH" \
      "https://www.googleapis.com/upload/chromewebstore/v1.1/items")
  fi
  
  # 检查响应
  UPLOAD_SUCCESS=$(echo $RESPONSE | grep -o '"uploadState":"SUCCESS"')
  ERROR_MSG=$(echo $RESPONSE | grep -o '"error":{[^}]*}')
  
  if [[ -n "$ERROR_MSG" ]]; then
    echo -e "${RED}[错误]${NC} 上传失败。错误信息: $ERROR_MSG"
    exit 1
  fi
  
  if [[ -z "$UPLOAD_SUCCESS" ]]; then
    echo -e "${RED}[错误]${NC} 上传可能失败。响应: $RESPONSE"
    read -p "要继续吗? (y/n): " CONTINUE
    if [[ "$CONTINUE" != "y" ]]; then
      exit 1
    fi
  else
    echo -e "${GREEN}[成功]${NC} 扩展上传成功"
  fi
  
  # 如果是新扩展，获取扩展ID
  if [[ "$IS_UPDATE" == "false" ]]; then
    EXTENSION_ID=$(echo $RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)
    if [[ -n "$EXTENSION_ID" ]]; then
      echo -e "${GREEN}[信息]${NC} 新扩展ID: $EXTENSION_ID"
    else
      echo -e "${YELLOW}[警告]${NC} 无法从响应中获取扩展ID。如需发布，请手动从响应中提取ID。"
      echo "响应: $RESPONSE"
      read -p "手动输入扩展ID以继续发布，或按Enter键退出: " MANUAL_ID
      if [[ -n "$MANUAL_ID" ]]; then
        EXTENSION_ID=$MANUAL_ID
      else
        echo -e "${YELLOW}[信息]${NC} 退出脚本。请在完成Chrome Web Store的信息填写后手动发布。"
        exit 0
      fi
    fi
  fi
}

# 发布扩展
function publish_extension() {
  echo -e "${BLUE}[INFO]${NC} 正在发布扩展..."
  
  # 设置发布目标
  if [[ "$PUBLISH_TARGET" == "trusted_testers" ]]; then
    PUBLISH_URL="https://www.googleapis.com/chromewebstore/v1.1/items/$EXTENSION_ID/publish?publishTarget=trustedTesters"
    echo -e "${YELLOW}[发布]${NC} 发布目标: 受信任的测试者"
  else
    PUBLISH_URL="https://www.googleapis.com/chromewebstore/v1.1/items/$EXTENSION_ID/publish"
    echo -e "${YELLOW}[发布]${NC} 发布目标: 所有用户"
  fi
  
  RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "x-goog-api-version: 2" \
    -H "Content-Length: 0" \
    -X POST \
    "$PUBLISH_URL")
  
  # 检查响应
  PUBLISH_SUCCESS=$(echo $RESPONSE | grep -o '"status":\["OK"\]')
  PUBLISH_PENDING=$(echo $RESPONSE | grep -o '"status":\["PENDING"\]')
  ERROR_MSG=$(echo $RESPONSE | grep -o '"error":{[^}]*}')
  
  if [[ -n "$ERROR_MSG" ]]; then
    echo -e "${RED}[错误]${NC} 发布失败。错误信息: $ERROR_MSG"
    exit 1
  fi
  
  if [[ -n "$PUBLISH_SUCCESS" ]]; then
    echo -e "${GREEN}[成功]${NC} 扩展发布成功"
  elif [[ -n "$PUBLISH_PENDING" ]]; then
    echo -e "${YELLOW}[待审核]${NC} 扩展已提交并等待审核"
  else
    echo -e "${YELLOW}[警告]${NC} 发布状态不明确。响应: $RESPONSE"
  fi
}

# 提供额外信息
function show_next_steps() {
  echo -e "\n${BLUE}============================================${NC}"
  echo -e "${GREEN}发布过程完成!${NC}"
  echo -e "${BLUE}============================================${NC}"
  
  if [[ "$IS_UPDATE" == "false" ]]; then
    echo -e "${YELLOW}[重要]${NC} 您需要在Chrome Web Store开发者控制台完成以下步骤:"
    echo "1. 登录 https://chrome.google.com/webstore/devconsole/"
    echo "2. 在您的扩展(ID: $EXTENSION_ID)中填写:"
    echo "   - 商店列表信息(标题、描述等)"
    echo "   - 上传截图(1280x800或640x400,至少1张)"
    echo "   - 填写隐私政策"
    echo "   - 完成权限说明"
    echo -e "${YELLOW}[注意]${NC} 在完成上述信息前，您的扩展将不会被审核或发布"
  else
    echo -e "${YELLOW}[注意]${NC} 您的更新已提交，将会进入审核队列"
    echo "您可以在Chrome Web Store开发者控制台查看审核状态"
  fi
  
  echo -e "\n${YELLOW}[提示]${NC} 扩展ID: $EXTENSION_ID"
  echo -e "${YELLOW}[提示]${NC} 在Chrome Web Store中查看扩展: https://chrome.google.com/webstore/detail/$EXTENSION_ID"
  echo -e "${BLUE}============================================${NC}\n"
}

# 主函数
function main() {
  echo -e "${BLUE}====== Chrome Web Store 扩展发布工具 ======${NC}\n"
  
  check_config
  get_access_token
  upload_extension
  
  # 询问是否要发布
  read -p "是否要立即发布扩展?(y/n): " SHOULD_PUBLISH
  if [[ "$SHOULD_PUBLISH" == "y" ]]; then
    publish_extension
    show_next_steps
  else
    echo -e "${YELLOW}[信息]${NC} 跳过发布步骤"
    echo -e "${YELLOW}[提示]${NC} 您可以在稍后手动发布，或再次运行此脚本进行发布"
    if [[ -n "$EXTENSION_ID" ]]; then
      echo -e "${YELLOW}[提示]${NC} 扩展ID: $EXTENSION_ID"
    fi
  fi
  
  echo -e "${GREEN}[完成]${NC} 脚本执行结束"
}

# 运行主函数
main