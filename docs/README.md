# Timestamp Converter Pro Chrome Extension

一个功能强大的Chrome浏览器扩展，用于时间戳转换、日期计算和时区管理。

## 主要功能

1. **实时时间显示**
   - 显示当前时间
   - 支持一键复制当前时间
   - 自动更新，精确到秒

2. **时区管理**
   - 支持全球所有时区
   - 自动检测用户当前时区
   - 可随时切换不同时区

3. **时间戳转换**
   - 时间戳转日期时间
     - 输入：UNIX时间戳（毫秒）
     - 输出：yyyy-MM-dd HH:mm:ss 格式的日期时间
     - 显示相对时间（如：3天前）
     - 支持一键复制结果
   
   - 日期时间转时间戳
     - 支持多种常见日期格式输入
     - 输出：UNIX时间戳（毫秒）
     - 支持一键复制结果

4. **日期计算器**
   - 计算两个日期之间的差值
   - 精确显示年、月、日、时、分、秒的差异
   - 支持跨时区计算

5. **历史记录**
   - 保存最近10条转换记录
   - 显示输入值和转换结果
   - 支持一键清除历史记录

## 使用方法

1. **基本操作**
   - 点击Chrome浏览器工具栏中的扩展图标
   - 在弹出窗口中选择需要使用的功能
   - 所有操作结果都支持一键复制

2. **时区设置**
   - 在顶部时区选择器中选择所需时区
   - 默认使用用户本地时区
   - 切换时区后所有功能会自动适应新时区

3. **格式说明**
   - 时间戳：13位数字（毫秒级）
   - 日期时间：支持多种常见格式，如：
     - yyyy-MM-dd HH:mm:ss
     - MM/dd/yyyy HH:mm:ss
     - yyyy年MM月dd日 HH时mm分ss秒

## 安装方法

1. 下载本项目所有文件
2. 打开Chrome浏览器，进入扩展程序管理页面（chrome://extensions/）
3. 开启右上角的"开发者模式"
4. 点击"加载已解压的扩展程序"
5. 选择本项目所在的文件夹

## 项目结构

```
.
├── assets/            # 静态资源
│   └── icons/         # 图标文件
├── dist/              # 发布包
├── docs/              # 文档
├── lib/               # 第三方库
├── src/               # 插件源代码
│   ├── lib/           # 插件使用的库文件
│   ├── manifest.json  # 扩展配置文件
│   ├── popup.html     # 弹出窗口HTML
│   ├── popup.js       # 主要JavaScript代码
│   └── style.css      # 样式表
└── tools/             # 工具脚本
    ├── icons/         # 图标生成工具
    └── scripts/       # 构建和发布脚本
```

## 开发指南

### 构建扩展
要构建扩展，请运行以下命令：
```bash
./tools/scripts/build.sh [版本号]
```
例如：
```bash
./tools/scripts/build.sh 1.2
```

构建完成后，生成的ZIP文件将保存在`dist`目录中。

### 发布扩展
要发布扩展到Chrome Web Store，请先在`tools/scripts/publish.sh`文件中配置您的OAuth凭据，然后运行：
```bash
./tools/scripts/publish.sh [版本号]
```
例如：
```bash
./tools/scripts/publish.sh 1.2
```

## 文件说明

- `src/manifest.json`: 扩展程序的配置文件
- `src/popup.html`: 扩展程序的用户界面
- `src/popup.js`: 实现转换功能的JavaScript代码
- `src/style.css`: 界面样式表
- `assets/icons/icon16.png`, `assets/icons/icon48.png`, `assets/icons/icon128.png`: 扩展程序图标
- `tools/scripts/build.sh`: 构建脚本
- `tools/scripts/publish.sh`: 发布脚本

## 注意事项

- 时间戳必须是有效的13位UNIX时间戳（毫秒）
- 日期时间输入支持多种格式，但需要是有效的日期时间
- 历史记录保存在本地，清除浏览器数据会导致记录丢失
- 时区切换会影响所有转换结果

## 更新日志

### v1.1
- 添加时区支持
- 添加当前时间显示
- 添加一键复制功能
- 添加相对时间显示
- 添加日期计算器
- 添加历史记录功能
- 优化用户界面
- 支持更多日期格式

### v1.0
- 基本的时间戳转换功能 