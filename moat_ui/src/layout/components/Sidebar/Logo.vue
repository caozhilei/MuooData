<template>
  <div class="sidebar-logo-container" :class="{'collapse':collapse}">
    <transition name="sidebarLogoFade">
      <router-link v-if="collapse" key="collapse" class="sidebar-logo-link" to="/">
        <img v-if="logo" :src="logo" class="sidebar-logo">
        <h1 v-else class="sidebar-title">{{ title }} </h1>
      </router-link>
      <router-link v-else key="expand" class="sidebar-logo-link" to="/">
        <img v-if="logo" :src="logo" class="sidebar-logo">
        <h1 class="sidebar-title">{{ title }} </h1>
      </router-link>
    </transition>
  </div>
</template>

<script>
export default {
  name: 'SidebarLogo',
  props: {
    collapse: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      title: 'MuooData数据中台',
      logo: '/muoo-icon.svg'
    }
  }
}
</script>

<style lang="scss" scoped>
.sidebarLogoFade-enter-active {
  transition: opacity 1.5s;
}

.sidebarLogoFade-enter,
.sidebarLogoFade-leave-to {
  opacity: 0;
}

.sidebar-logo-container {
  position: relative;
  width: 100%;
  height: 56px;
  line-height: 56px;
  text-align: center;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(74, 144, 226, 0.1) 0%, rgba(80, 200, 120, 0.1) 100%);
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(10px);

  & .sidebar-logo-link {
    height: 100%;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 16px;
    transition: all 0.3s;

    &:hover {
      background: rgba(74, 144, 226, 0.15);
    }

    & .sidebar-logo {
      width: 36px;
      height: 36px;
      vertical-align: middle;
      margin-right: 8px;
      filter: drop-shadow(0 2px 8px rgba(74, 144, 226, 0.3));
      transition: all 0.3s;
    }

    & .sidebar-title {
      display: inline-block;
      margin: 0;
      color: #fff;
      font-weight: 700;
      line-height: 56px;
      font-size: 16px;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
      vertical-align: middle;
      background: linear-gradient(135deg, #4A90E2 0%, #50C878 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      transition: all 0.3s;
    }
  }

  &.collapse {
    .sidebar-logo {
      margin-right: 0px;
    }

    .sidebar-title {
      display: none;
    }
  }
}
</style>
