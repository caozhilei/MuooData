<template>
  <div class="navbar">
    <hamburger id="hamburger-container" :is-active="sidebar.opened" class="hamburger-container" @toggleClick="toggleSideBar" />

    <breadcrumb id="breadcrumb-container" class="breadcrumb-container" />

    <div class="right-menu">
      <template v-if="device!=='mobile'">
        <search id="header-search" class="right-menu-item" />

        <el-tooltip content="项目文档" effect="dark" placement="bottom">
          <Doc class="right-menu-item hover-effect" />
        </el-tooltip>

        <el-tooltip content="全屏缩放" effect="dark" placement="bottom">
          <screenfull id="screenfull" class="right-menu-item hover-effect" />
        </el-tooltip>

        <el-tooltip content="布局设置" effect="dark" placement="bottom">
          <size-select id="size-select" class="right-menu-item hover-effect" />
        </el-tooltip>

      </template>

      <el-dropdown class="avatar-container right-menu-item hover-effect" trigger="click">
        <div class="avatar-wrapper">
          <img :src="user.avatarName ? baseApi + '/system/avatar/' + user.avatarName : Avatar" class="user-avatar">
          <i class="el-icon-caret-bottom" />
        </div>
        <el-dropdown-menu slot="dropdown">
          <span style="display:block;" @click="show = true">
            <el-dropdown-item>
              布局设置
            </el-dropdown-item>
          </span>
          <router-link to="/user/center">
            <el-dropdown-item>
              个人中心
            </el-dropdown-item>
          </router-link>
          <span style="display:block;" @click="open">
            <el-dropdown-item divided>
              退出登录
            </el-dropdown-item>
          </span>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import Breadcrumb from '@/components/Breadcrumb'
import Hamburger from '@/components/Hamburger'
import Doc from '@/components/Doc'
import Screenfull from '@/components/Screenfull'
import SizeSelect from '@/components/SizeSelect'
import Search from '@/components/HeaderSearch'
import Avatar from '@/assets/images/avatar.png'

export default {
  components: {
    Breadcrumb,
    Hamburger,
    Screenfull,
    SizeSelect,
    Search,
    Doc
  },
  data() {
    return {
      Avatar: Avatar,
      dialogVisible: false
    }
  },
  computed: {
    ...mapGetters([
      'sidebar',
      'device',
      'user',
      'baseApi'
    ]),
    show: {
      get() {
        return this.$store.state.settings.showSettings
      },
      set(val) {
        this.$store.dispatch('settings/changeSetting', {
          key: 'showSettings',
          value: val
        })
      }
    }
  },
  methods: {
    toggleSideBar() {
      this.$store.dispatch('app/toggleSideBar')
    },
    open() {
      this.$confirm('确定注销并退出系统吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.logout()
      })
    },
    logout() {
      this.$store.dispatch('LogOut').then(() => {
        location.reload()
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.navbar {
  height: 56px;
  overflow: hidden;
  position: relative;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  backdrop-filter: blur(10px);

  .hamburger-container {
    line-height: 56px;
    height: 100%;
    float: left;
    cursor: pointer;
    transition: all .3s;
    padding: 0 16px;
    -webkit-tap-highlight-color:transparent;
    color: #606266;

    &:hover {
      background: rgba(74, 144, 226, 0.08);
      color: #4A90E2;
    }
  }

  .breadcrumb-container {
    float: left;
    line-height: 56px;
  }

  .errLog-container {
    display: inline-block;
    vertical-align: top;
  }

  .right-menu {
    float: right;
    height: 100%;
    line-height: 56px;
    padding-right: 16px;

    &:focus {
      outline: none;
    }

    .right-menu-item {
      display: inline-block;
      padding: 0 12px;
      height: 100%;
      font-size: 18px;
      color: #606266;
      vertical-align: text-bottom;
      transition: all 0.3s;

      &.hover-effect {
        cursor: pointer;
        border-radius: 6px;
        margin: 0 4px;

        &:hover {
          background: rgba(74, 144, 226, 0.1);
          color: #4A90E2;
          transform: translateY(-2px);
        }
      }
    }

    .avatar-container {
      margin-right: 8px;
      margin-left: 8px;

      .avatar-wrapper {
        margin-top: 8px;
        position: relative;
        padding: 4px;
        border-radius: 8px;
        transition: all 0.3s;

        &:hover {
          background: rgba(74, 144, 226, 0.1);
        }

        .user-avatar {
          cursor: pointer;
          width: 40px;
          height: 40px;
          border-radius: 8px;
          border: 2px solid rgba(74, 144, 226, 0.2);
          transition: all 0.3s;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

          &:hover {
            border-color: #4A90E2;
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(74, 144, 226, 0.3);
          }
        }

        .el-icon-caret-bottom {
          cursor: pointer;
          position: absolute;
          right: -16px;
          top: 28px;
          font-size: 12px;
          color: #909399;
          transition: all 0.3s;
        }

        &:hover .el-icon-caret-bottom {
          color: #4A90E2;
        }
      }
    }
  }
}
</style>
