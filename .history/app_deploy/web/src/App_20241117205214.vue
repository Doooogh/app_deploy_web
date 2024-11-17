<template>
  <div id="app">
    <el-container class="app-wrapper">
      <el-aside width="200px" class="sidebar-container">
        <sidebar />
      </el-aside>
      <el-container>
        <el-header height="50px" class="app-header">
          <navbar />
        </el-header>
        <el-main class="app-main">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
import Sidebar from '@/components/layout/Sidebar.vue'
import Navbar from '@/components/layout/Navbar.vue'

export default {
  name: 'App',
  components: {
    Sidebar,
    Navbar
  }
}
</script>

<style lang="scss">
#app {
  height: 100vh;
  .app-wrapper {
    height: 100%;
    .sidebar-container {
      background-color: #304156;
      height: 100%;
    }
    .app-header {
      background-color: #fff;
      box-shadow: 0 1px 4px rgba(0,21,41,.08);
    }
    .app-main {
      padding: 20px;
      background-color: #f0f2f5;
    }
  }
}
</style>
