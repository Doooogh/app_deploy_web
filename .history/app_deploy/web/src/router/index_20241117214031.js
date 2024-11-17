import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/components/layout/Layout.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    hidden: true
  },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '仪表盘', icon: 'el-icon-s-home' }
      }
    ]
  },
  {
    path: '/password',
    component: Layout,
    meta: { title: '密码管理', icon: 'el-icon-key' },
    children: [
      {
        path: 'list',
        name: 'PasswordList',
        component: () => import('@/views/password/list.vue'),
        meta: { title: '密码列表' }
      },
      {
        path: 'add',
        name: 'PasswordAdd',
        component: () => import('@/views/password/add.vue'),
        meta: { title: '添加密码' }
      }
    ]
  },
  {
    path: '/environment',
    component: Layout,
    children: [
      {
        path: 'index',
        name: 'Environment',
        component: () => import('@/views/environment/index.vue'),
        meta: { title: '环境管理', icon: 'el-icon-s-operation' }
      }
    ]
  },
  {
    path: '/host',
    component: Layout,
    children: [
      {
        path: 'index',
        name: 'Host',
        component: () => import('@/views/host/index.vue'),
        meta: { title: '主机管理', icon: 'el-icon-monitor' }
      }
    ]
  },
  {
    path: '/project',
    component: Layout,
    children: [
      {
        path: 'index',
        name: 'Project',
        component: () => import('@/views/project/index.vue'),
        meta: { title: '项目管理', icon: 'el-icon-folder' }
      },
      {
        path: 'version/:id',
        name: 'ProjectVersion',
        component: () => import('@/views/project/version.vue'),
        meta: { title: '版本管理' },
        hidden: true
      }
    ]
  },
  {
    path: '/script',
    component: Layout,
    children: [
      {
        path: 'index',
        name: 'Script',
        component: () => import('@/views/script/index.vue'),
        meta: { title: '脚本管理', icon: 'el-icon-document' }
      }
    ]
  },
  {
    path: '/deploy',
    component: Layout,
    meta: { title: '发布管理', icon: 'el-icon-s-promotion' },
    children: [
      {
        path: 'create',
        name: 'DeployCreate',
        component: () => import('@/views/deploy/create.vue'),
        meta: { title: '创建发布单' }
      },
      {
        path: 'history',
        name: 'DeployHistory',
        component: () => import('@/views/deploy/history.vue'),
        meta: { title: '发布历史' }
      },
      {
        path: 'detail/:id',
        name: 'DeployDetail',
        component: () => import('@/views/deploy/detail.vue'),
        meta: { title: '发布详情' },
        hidden: true
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router 