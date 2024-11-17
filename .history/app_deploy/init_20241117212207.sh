#!/bin/bash

echo "开始初始化项目结构..."

# 创建主目录结构
echo "创建目录结构..."

# 前端目录结构
mkdir -p web/src/{api,assets,components,router,store,styles,utils,views}
mkdir -p web/src/views/{password,environment,host,project,script,deploy,dashboard}
mkdir -p web/src/components/{common,layout}
mkdir -p web/public

# 后端目录结构
mkdir -p server/app/{api,models,services,utils}
mkdir -p server/logs
mkdir -p server/scripts
mkdir -p server/tests

# 创建后端Python包所需的__init__.py文件
echo "创建Python包文件..."
touch server/app/__init__.py
touch server/app/api/__init__.py
touch server/app/models/__init__.py
touch server/app/services/__init__.py
touch server/app/utils/__init__.py

# 移动前端文件
echo "移动前端文件..."

# 移动src下的文件到对应目录
if [ -d "src" ]; then
  # 创建必要的目录（如果不存在）
  for dir in api assets components router store styles utils views; do
    mkdir -p web/src/$dir
  done
  
  # API文件
  cp -r src/api/* web/src/api/ 2>/dev/null || true
  
  # 组件文件
  cp -r src/components/common/* web/src/components/common/ 2>/dev/null || true
  cp -r src/components/layout/* web/src/components/layout/ 2>/dev/null || true
  
  # 路由和状态管理
  cp -r src/router/* web/src/router/ 2>/dev/null || true
  cp -r src/store/* web/src/store/ 2>/dev/null || true
  
  # 工具和样式
  cp -r src/utils/* web/src/utils/ 2>/dev/null || true
  cp -r src/styles/* web/src/styles/ 2>/dev/null || true
  cp -r src/assets/* web/src/assets/ 2>/dev/null || true
  
  # 视图文件
  cp -r src/views/password/* web/src/views/password/ 2>/dev/null || true
  cp -r src/views/environment/* web/src/views/environment/ 2>/dev/null || true
  cp -r src/views/host/* web/src/views/host/ 2>/dev/null || true
  cp -r src/views/project/* web/src/views/project/ 2>/dev/null || true
  cp -r src/views/script/* web/src/views/script/ 2>/dev/null || true
  cp -r src/views/deploy/* web/src/views/deploy/ 2>/dev/null || true
  cp -r src/views/dashboard/* web/src/views/dashboard/ 2>/dev/null || true
  
  # 移动主文件
  cp src/App.vue web/src/ 2>/dev/null || true
  cp src/main.js web/src/ 2>/dev/null || true
fi

# 移动Vue配置文件
echo "移动Vue配置文件..."
cp package.json web/ 2>/dev/null || true
cp vite.config.js web/ 2>/dev/null || true
cp vue.config.js web/ 2>/dev/null || true
cp .env* web/ 2>/dev/null || true
cp index.html web/ 2>/dev/null || true
cp -r public/* web/public/ 2>/dev/null || true

# 创建前端配置文件
echo "创建前端配置文件..."
if [ ! -f "web/vite.config.js" ]; then
  echo "import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      },
      '/ws': {
        target: 'ws://localhost:3000',
        ws: true
      }
    }
  }
})" > web/vite.config.js
fi

# 创建前端入口文件
if [ ! -f "web/index.html" ]; then
  echo "<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"UTF-8\" />
    <link rel=\"icon\" type=\"image/svg+xml\" href=\"/vite.svg\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
    <title>App Deploy</title>
  </head>
  <body>
    <div id=\"app\"></div>
    <script type=\"module\" src=\"/src/main.js\"></script>
  </body>
</html>" > web/index.html
fi

# 创建空的日志目录
touch server/logs/.gitkeep

# 清理原始文件
echo "清理原始文件..."
rm -rf src public package.json vite.config.js vue.config.js .env* 2>/dev/null || true

# 设置权限
chmod +x init.sh

echo "初始化完成！"
echo "请检查web和server目录下的文件是否已正确移动。"