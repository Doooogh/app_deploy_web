# 在init.sh中添加
# 创建.env文件
echo "VITE_BASE_API=/api
VITE_WS_URL=ws://localhost:3000/ws" > web/.env

# 更新main.js
echo "import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import App from './App.vue'
import router from './router'
import store from './store'
import './styles/index.scss'

const app = createApp(App)

// 注册所有图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(ElementPlus)
app.use(router)
app.use(store)

app.mount('#app')" > web/src/main.js