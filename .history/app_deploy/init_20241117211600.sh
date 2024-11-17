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

# 移动现有前端文件到web/src目录
# 注意：这里需要根据实际情况调整源目录路径
mv src/* web/src/
mv public/* web/public/

# 创建空的日志目录
touch server/logs/.gitkeep

# 设置权限
chmod +x init.sh 