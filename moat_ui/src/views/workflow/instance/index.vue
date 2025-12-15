<template>
  <div class="app-container">
    <!-- 优先显示子路由，如果没有子路由则显示默认内容 -->
    <router-view v-if="hasChildRoute" />
    <transition v-else name="el-zoom-in-center">
      <running-instance-list v-if="options.showList" @showCard="showCard" />
    </transition>
  </div>
</template>

<script>
import RunningInstanceList from './running/RunningInstanceList'

export default {
  name: 'Instance',
  components: { RunningInstanceList },
  data() {
    return {
      hasChildRoute: false,
      options: {
        data: {},
        showList: true
      }
    }
  },
  created() {
    console.log('Instance组件已创建，当前路由:', this.$route.path, 'matched:', this.$route.matched)
    // 检查是否有子路由（matched长度大于1表示有子路由）
    this.hasChildRoute = this.$route.matched.length > 1 && this.$route.path !== '/workflow/instance'
  },
  mounted() {
    console.log('Instance组件已挂载，hasChildRoute:', this.hasChildRoute)
  },
  watch: {
    '$route'(to, from) {
      this.hasChildRoute = to.matched.length > 1 && to.path !== '/workflow/instance'
      console.log('路由变化，hasChildRoute:', this.hasChildRoute, 'path:', to.path)
    }
  },
  methods: {
    showCard(data) {
      Object.assign(this.options, data)
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
