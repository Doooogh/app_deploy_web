<template>
  <div class="app-wrapper">
    <sidebar class="sidebar-container" />
    <div class="main-container">
      <navbar />
      <app-main />
    </div>
  </div>
</template>

<script>
import { Navbar, Sidebar, AppMain } from './components'

export default {
  name: 'Layout',
  components: {
    Navbar,
    Sidebar,
    AppMain
  }
}
</script>

<style lang="scss" scoped>
.app-wrapper {
  position: relative;
  height: 100%;
  width: 100%;
  
  .sidebar-container {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 1001;
    width: $--sidebar-width;
    height: 100%;
    overflow: hidden;
    transition: width 0.28s;
  }
  
  .main-container {
    min-height: 100%;
    margin-left: $--sidebar-width;
    position: relative;
  }
}
</style> 