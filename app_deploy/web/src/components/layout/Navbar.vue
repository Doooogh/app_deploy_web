<template>
  <div class="navbar">
    <div class="left-menu">
      <hamburger :is-active="!sidebar.collapsed" @click="toggleSidebar" />
      <breadcrumb />
    </div>
    <div class="right-menu">
      <el-dropdown trigger="click">
        <div class="avatar-wrapper">
          <el-avatar :size="30" icon="el-icon-user-solid"></el-avatar>
          <i class="el-icon-caret-bottom"></i>
        </div>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item>个人信息</el-dropdown-item>
          <el-dropdown-item divided>退出登录</el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import Breadcrumb from '@/components/common/Breadcrumb'
import Hamburger from '@/components/common/Hamburger'

export default {
  name: 'Navbar',
  components: {
    Breadcrumb,
    Hamburger
  },
  computed: {
    sidebar() {
      return this.$store.state.app.sidebar
    }
  },
  methods: {
    toggleSidebar() {
      this.$store.dispatch('app/toggleSidebar')
    }
  }
}
</script>

<style lang="scss" scoped>
.navbar {
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 15px;

  .left-menu {
    display: flex;
    align-items: center;
  }

  .right-menu {
    .avatar-wrapper {
      cursor: pointer;
      display: flex;
      align-items: center;
      .el-icon-caret-bottom {
        margin-left: 5px;
      }
    }
  }
}
</style> 