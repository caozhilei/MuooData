<template>
  <section class="app-main">
    <transition name="fade-transform" mode="out-in">
      <keep-alive :include="cachedViews">
        <router-view :key="key" />
      </keep-alive>
    </transition>
    <el-backtop :bottom="50" :right="40"><i class="el-icon-caret-top" /></el-backtop>
    <div v-if="$store.state.settings.showFooter" id="el-main-footer">
      <span v-html="$store.state.settings.footerTxt" />
      <span v-if="$store.state.settings.caseNumber"> ⋅ </span>
      <a href="https://beian.miit.gov.cn/#/Integrated/index" target="_blank">{{ $store.state.settings.caseNumber }}</a>
    </div>
  </section>
</template>

<script>
export default {
  name: 'AppMain',
  computed: {
    cachedViews() {
      return this.$store.state.tagsView.cachedViews
    },
    key() {
      return this.$route.path
    }
  }
}
</script>

<style lang="scss" scoped>
.app-main {
  /* 56= navbar  56  */
  min-height: calc(100vh - 56px);
  width: 100%;
  position: relative;
  overflow: hidden;
  background: #f5f7fa;
}

.fixed-header+.app-main {
  padding-top: 56px;
}

.hasTagsView {
  .app-main {
    /* 90 = navbar + tags-view = 56 + 34 */
    min-height: calc(100vh - 90px);
  }

  .fixed-header+.app-main {
    padding-top: 90px;
  }
}

#el-main-footer {
  padding: 20px;
  text-align: center;
  color: #909399;
  font-size: 12px;
  background: #fff;
  border-top: 1px solid #e4e7ed;
  margin-top: 40px;
  
  a {
    color: #606266;
    text-decoration: none;
    
    &:hover {
      color: #4A90E2;
    }
  }
}
</style>

<style lang="scss">
// fix css style bug in open el-dialog
.el-popup-parent--hidden {
  .fixed-header {
    padding-right: 15px;
  }
}
</style>
