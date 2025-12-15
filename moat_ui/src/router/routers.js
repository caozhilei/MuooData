import Vue from 'vue'
import Router from 'vue-router'
import Layout from '../layout/index'

Vue.use(Router)

export const constantRouterMap = [
  { path: '/login',
    meta: { title: '登录', noCache: true },
    component: (resolve) => require(['@/views/login'], resolve),
    hidden: true
  },
  {
    path: '/404',
    component: (resolve) => require(['@/views/features/404'], resolve),
    hidden: true
  },
  {
    path: '/401',
    component: (resolve) => require(['@/views/features/401'], resolve),
    hidden: true
  },
  {
    path: '/redirect',
    component: Layout,
    hidden: true,
    children: [
      {
        path: '/redirect/:path*',
        component: (resolve) => require(['@/views/features/redirect'], resolve)
      }
    ]
  },
  {
    path: '/visual/chart/build/:id',
    component: () => import('@/views/visual/datachart/DataChartBuild'),
    hidden: true
  },

  {
    path: '/visual/board/build/:id',
    component: () => import('@/views/visual/databoard/DataBoardBuild'),
    hidden: true
  },

  {
    path: '/visual/board/view/:id',
    component: () => import('@/views/visual/databoard/DataBoardView'),
    hidden: true
  },

  {
    path: '/visual/screen/build/:id',
    component: () => import('@/views/visual/datascreen/DataScreenBuild'),
    hidden: true
  },

  {
    path: '/visual/screen/view/:id',
    component: () => import('@/views/visual/datascreen/DataScreenView'),
    hidden: true
  },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        component: (resolve) => require(['@/views/home'], resolve),
        name: 'Dashboard',
        meta: { title: '首页', icon: 'index', affix: true, noCache: true }
      }
    ]
  },
  {
    path: '/user',
    component: Layout,
    hidden: true,
    redirect: 'noredirect',
    children: [
      {
        path: 'center',
        component: (resolve) => require(['@/views/system/user/center'], resolve),
        name: '个人中心',
        meta: { title: '个人中心' }
      }
    ]
  },
  {
    path: '/sys-tools',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'generator/preview/:tableName',
        component: (resolve) => require(['@/views/generator/preview'], resolve),
        name: 'Preview',
        meta: { title: '生成预览', activeMenu: '/sys-tools/generator' },
        hidden: true
      },
      {
        path: 'generator/config/:tableName',
        component: (resolve) => require(['@/views/generator/config'], resolve),
        name: 'GeneratorConfig',
        meta: { title: '生成配置', activeMenu: '/sys-tools/generator' },
        hidden: true
      }
    ]
  }
]

export default new Router({
  scrollBehavior: () => ({ y: 0 }),
  routes: constantRouterMap
})
