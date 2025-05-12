# Timestamp Converter Pro Chrome Extension

一个功能强大的Chrome浏览器扩展，用于时间戳转换、日期计算和时区管理。

## 项目简介

Timestamp Converter Pro是一个强大的Chrome扩展，帮助用户快速进行时间戳转换、时区管理和日期计算。无论是开发人员还是日常用户，都能从这个工具中获益。

## 快速开始

### 构建和安装

1. 克隆项目
   ```bash
   git clone https://github.com/yourusername/TimeConverter.git
   cd TimeConverter
   ```

2. 构建项目
   ```bash
   ./tools/scripts/build.sh
   ```

3. 在Chrome中安装
   - 打开Chrome浏览器，访问 `chrome://extensions/`
   - 开启"开发者模式"
   - 点击"加载已解压的扩展程序"
   - 选择`dist`目录中的最新构建

### 发布扩展

要发布扩展到Chrome Web Store，请参阅[详细文档](docs/README.md)。

## 主要功能

- 时间戳与日期之间的实时转换
- 支持全球所有时区
- 日期计算器功能
- 转换历史记录
- 一键复制结果

## 项目结构

```
.
├── assets/            # 静态资源
├── dist/              # 发布包
├── docs/              # 文档
├── lib/               # 第三方库
├── src/               # 插件源代码
└── tools/             # 工具脚本
```

## 详细文档

有关更详细的信息，请查看[完整文档](docs/README.md)。

## 推广资料

我们提供了一篇详细的[推广文章](docs/promotion.md)，描述了插件的主要特点和优势，可用于向潜在用户介绍本产品。

## 许可证

MIT 