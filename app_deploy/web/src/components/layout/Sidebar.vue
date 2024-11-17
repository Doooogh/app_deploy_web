<template>
  <div class="sidebar">
    <el-menu
      :default-active="activeMenu"
      class="el-menu-vertical"
      background-color="#304156"
      text-color="#bfcbd9"
      active-text-color="#409EFF"
      :collapse="isCollapse"
      router
    >
      <el-menu-item index="/dashboard">
        <i class="el-icon-s-home"></i>
        <span slot="title">仪表盘</span>
      </el-menu-item>
      
      <el-submenu index="1">
        <template slot="title">
          <i class="el-icon-key"></i>
          <span>密码管理</span>
        </template>
        <el-menu-item index="/password/list">密码列表</el-menu-item>
        <el-menu-item index="/password/add">添加密码</el-menu-item>
      </el-submenu>

      <el-menu-item index="/environment">
        <i class="el-icon-s-operation"></i>
        <span slot="title">环境管理</span>
      </el-menu-item>

      <el-menu-item index="/host">
        <i class="el-icon-monitor"></i>
        <span slot="title">主机管理</span>
      </el-menu-item>

      <el-menu-item index="/project">
        <i class="el-icon-folder"></i>
        <span slot="title">项目管理</span>
      </el-menu-item>

      <el-menu-item index="/script">
        <i class="el-icon-document"></i>
        <span slot="title">脚本管理</span>
      </el-menu-item>

      <el-submenu index="2">
        <template slot="title">
          <i class="el-icon-s-promotion"></i>
          <span>发布管理</span>
        </template>
        <el-menu-item index="/deploy/create">创建发布单</el-menu-item>
        <el-menu-item index="/deploy/history">发布历史</el-menu-item>
      </el-submenu>
    </el-menu>
  </div>
</template>

<script>
export default {
  name: 'Sidebar',
  data() {
    return {
      isCollapse: false
    }
  },
  computed: {
    activeMenu() {
      return this.$route.path
    }
  }
}
</script>

<style lang="scss" scoped>
.sidebar {
  height: 100%;
  .el-menu {
    height: 100%;
    border: none;
  }
  .el-menu-vertical:not(.el-menu--collapse) {
    width: 200px;
  }
}
</style> 