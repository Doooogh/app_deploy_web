#!/bin/bash

echo "开始初始化项目结构..."

# 检查是否存在源文件目录
if [ ! -d "src" ]; then
    echo "错误: 源文件目录 'src' 不存在"
    exit 1
fi

# 创建主目录结构
echo "创建目录结构..."

# 前端目录结构
mkdir -p web/src/{api,assets,components,router,store,styles,utils,views}
mkdir -p web/src/views/{password,environment,host,project,script,deploy,dashboard}
mkdir -p web/src/components/{common,layout/components}
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

# 定义一个函数来复制文件并检查
copy_and_check() {
    local src=$1
    local dest=$2
    if [ -e "$src" ]; then
        cp -r "$src" "$dest"
        echo "✓ 已复制: $src -> $dest"
    else
        echo "! 警告: 未找到源文件: $src"
    fi
}

# 复制组件文件
echo "复制组件文件..."
copy_and_check "src/components/common" "web/src/components/"
copy_and_check "src/components/layout" "web/src/components/"
copy_and_check "src/components/layout/components" "web/src/components/layout/"

# 复制视图文件
echo "复制视图文件..."
for dir in password environment host project script deploy dashboard; do
    copy_and_check "src/views/$dir" "web/src/views/"
done

# 复制其他文件
echo "复制其他文件..."
copy_and_check "src/api" "web/src/"
copy_and_check "src/store" "web/src/"
copy_and_check "src/utils" "web/src/"
copy_and_check "src/styles" "web/src/"
copy_and_check "src/assets" "web/src/"
copy_and_check "src/App.vue" "web/src/"
copy_and_check "src/main.js" "web/src/"
copy_and_check "src/router/index.js" "web/src/router/"

# 复制配置文件
echo "复制配置文件..."
copy_and_check "package.json" "web/"
copy_and_check "vite.config.js" "web/"
copy_and_check "vue.config.js" "web/"
copy_and_check ".env" "web/"
copy_and_check "public" "web/"

# 检查必要的文件是否存在
echo "检查关键文件..."
REQUIRED_FILES=(
    "web/src/components/layout/Layout.vue"
    "web/src/components/layout/Navbar.vue"
    "web/src/components/layout/Sidebar.vue"
    "web/src/components/layout/components/AppMain.vue"
    "web/src/components/layout/components/index.js"
    "web/src/router/index.js"
    "web/src/store/index.js"
    "web/src/styles/index.scss"
    "web/src/App.vue"
    "web/src/main.js"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "! 错误: 缺少关键文件: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

# 创建空的日志目录
touch server/logs/.gitkeep

# 清理原始文件
if [ $MISSING_FILES -eq 0 ]; then
    echo "清理原始文件..."
    rm -rf src public package.json vite.config.js vue.config.js .env* 2>/dev/null || true
    echo "✓ 清理完成"
else
    echo "! 警告: 由于缺少关键文件，跳过清理步骤"
fi

# 设置权限
chmod +x init.sh

echo "初始化完成！"
if [ $MISSING_FILES -eq 0 ]; then
    echo "✓ 所有文件已成功移动"
else
    echo "! 警告: 有 $MISSING_FILES 个关键文件缺失，请检查"
fi

# 打印下一步操作指南
echo "
下一步操作：
1. cd web
2. npm install
3. npm run dev
"