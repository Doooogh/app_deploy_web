#!/bin/bash

# 创建主目录结构
mkdir -p web/src
mkdir -p web/public

mkdir -p server/app/{api,models,services,utils}
mkdir -p server/logs
mkdir -p server/scripts
mkdir -p server/tests

# 创建后端Python包所需的__init__.py文件
touch server/app/__init__.py
touch server/app/api/__init__.py
touch server/app/models/__init__.py
touch server/app/services/__init__.py
touch server/app/utils/__init__.py

# 创建后端基础文件
touch server/app/config.py
touch server/main.py

# 移动前端文件到web目录
# 移动src目录下的所有内容
mv src/* web/src/ 2>/dev/null || true

# 移动其他前端配置文件
mv package.json web/ 2>/dev/null || true
mv vite.config.js web/ 2>/dev/null || true
mv *.html web/ 2>/dev/null || true
mv .env* web/ 2>/dev/null || true

# 创建空的日志目录
touch server/logs/.gitkeep

# 创建前端目录结构
mkdir -p web/src/{api,assets,components,router,store,styles,utils,views}
mkdir -p web/src/views/{password,environment,host,project,script,deploy,dashboard}
mkdir -p web/src/components/{common,layout}

# 设置权限
chmod +x init.sh