<template>
  <div class="login">
    <!-- 动态背景 -->
    <div class="login-background">
      <div class="data-particles">
        <div v-for="i in 50" :key="i" class="particle" :style="getParticleStyle(i)"></div>
      </div>
      <div class="grid-overlay"></div>
      <div class="glow-effect"></div>
    </div>
    
    <!-- 登录表单 -->
    <div class="login-container">
      <el-form ref="loginForm" :model="loginForm" :rules="loginRules" label-position="left" label-width="0px" class="login-form">
        <div class="logo-section">
          <img :src="allDataIcon" alt="MuooData" class="logo-img">
          <h3 class="title">
            MuooData数据中台
          </h3>
          <p class="subtitle">基于积木方式构建的智能数据平台</p>
        </div>
        <el-form-item prop="username">
          <el-input 
            v-model="loginForm.username" 
            type="text" 
            auto-complete="off" 
            placeholder="请输入账号"
            class="login-input">
            <svg-icon slot="prefix" icon-class="user" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input 
            v-model="loginForm.password" 
            type="password" 
            auto-complete="off" 
            placeholder="请输入密码" 
            @keyup.enter.native="handleLogin"
            class="login-input">
            <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="code">
          <el-input 
            v-model="loginForm.code" 
            auto-complete="off" 
            placeholder="验证码" 
            class="login-input code-input"
            @keyup.enter.native="handleLogin">
            <svg-icon slot="prefix" icon-class="validCode" class="el-input__icon input-icon" />
          </el-input>
          <div class="login-code">
            <img :src="codeUrl" @click="getCode" alt="验证码">
          </div>
        </el-form-item>
        <el-checkbox v-model="loginForm.rememberMe" class="remember-me">
          记住我
        </el-checkbox>
        <el-form-item style="width:100%;margin-top: 20px;">
          <el-button 
            :loading="loading" 
            size="medium" 
            type="primary" 
            class="login-button"
            @click.native.prevent="handleLogin">
            <span v-if="!loading">登 录</span>
            <span v-else>登 录 中...</span>
          </el-button>
        </el-form-item>
      </el-form>
    </div>
    <!--  底部  -->
    <div v-if="$store.state.settings.showFooter" class="login-footer">
      <span v-html="$store.state.settings.footerTxt" />
      <span v-if="$store.state.settings.caseNumber"> ⋅ </span>
      <a href="https://beian.miit.gov.cn/#/Integrated/index" target="_blank">{{ $store.state.settings.caseNumber }}</a>
    </div>
  </div>
</template>

<script>
import { encrypt } from '@/utils/rsaEncrypt'
import Config from '@/settings'
import { getCodeImg } from '@/api/login'
import Cookies from 'js-cookie'
import qs from 'qs'
export default {
  name: 'Login',
  data() {
    return {
      allDataIcon: '/muoo-icon.svg',
      codeUrl: '',
      cookiePass: '',
      loginForm: {
        username: 'admin',
        password: '123456',
        rememberMe: false,
        code: '',
        uuid: ''
      },
      loginRules: {
        username: [{ required: true, trigger: 'blur', message: '用户名不能为空' }],
        password: [{ required: true, trigger: 'blur', message: '密码不能为空' }],
        code: [{ required: true, trigger: 'change', message: '验证码不能为空' }]
      },
      loading: false,
      redirect: undefined
    }
  },
  watch: {
    $route: {
      handler: function(route) {
        const data = route.query
        if (data && data.redirect) {
          this.redirect = data.redirect
          delete data.redirect
          if (JSON.stringify(data) !== '{}') {
            this.redirect = this.redirect + '&' + qs.stringify(data, { indices: false })
          }
        }
      },
      immediate: true
    }
  },
  created() {
    // 获取验证码
    this.getCode()
    // 获取用户名密码等Cookie
    this.getCookie()
    // token 过期提示
    this.point()
  },
  methods: {
    getCode() {
      getCodeImg().then(res => {
        this.codeUrl = res.img
        this.loginForm.uuid = res.uuid
      })
    },
    getCookie() {
      const username = Cookies.get('username')
      let password = Cookies.get('password')
      const rememberMe = Cookies.get('rememberMe')
      // 保存cookie里面的加密后的密码
      this.cookiePass = password === undefined ? '' : password
      password = password === undefined ? this.loginForm.password : password
      this.loginForm = {
        username: username === undefined ? this.loginForm.username : username,
        password: password,
        rememberMe: rememberMe === undefined ? false : Boolean(rememberMe),
        code: ''
      }
    },
    handleLogin() {
      this.$refs.loginForm.validate(valid => {
        const user = {
          username: this.loginForm.username,
          password: this.loginForm.password,
          rememberMe: this.loginForm.rememberMe,
          code: this.loginForm.code,
          uuid: this.loginForm.uuid
        }
        if (user.password !== this.cookiePass) {
          user.password = encrypt(user.password)
        }
        if (valid) {
          this.loading = true
          if (user.rememberMe) {
            Cookies.set('username', user.username, { expires: Config.passCookieExpires })
            Cookies.set('password', user.password, { expires: Config.passCookieExpires })
            Cookies.set('rememberMe', user.rememberMe, { expires: Config.passCookieExpires })
          } else {
            Cookies.remove('username')
            Cookies.remove('password')
            Cookies.remove('rememberMe')
          }
          this.$store.dispatch('Login', user).then(() => {
            this.loading = false
            this.$router.push({ path: this.redirect || '/' })
          }).catch(() => {
            this.loading = false
            this.getCode()
          })
        } else {
          console.log('error submit!!')
          return false
        }
      })
    },
    point() {
      const point = Cookies.get('point') !== undefined
      if (point) {
        this.$notify({
          title: '提示',
          message: '当前登录状态已过期，请重新登录！',
          type: 'warning',
          duration: 5000
        })
        Cookies.remove('point')
      }
    },
    getParticleStyle(index) {
      const size = Math.random() * 3 + 1
      const left = Math.random() * 100
      const animationDelay = Math.random() * 20
      const animationDuration = Math.random() * 10 + 10
      return {
        width: size + 'px',
        height: size + 'px',
        left: left + '%',
        animationDelay: animationDelay + 's',
        animationDuration: animationDuration + 's'
      }
    }
  }
}
</script>

<style rel="stylesheet/scss" lang="scss">
  .login {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    width: 100vw;
    overflow: hidden;
    background: linear-gradient(135deg, #0a0e27 0%, #1a1f3a 50%, #0f1419 100%);
  }

  .login-background {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 0;
    overflow: hidden;
  }

  .data-particles {
    position: absolute;
    width: 100%;
    height: 100%;
  }

  .particle {
    position: absolute;
    background: rgba(74, 144, 226, 0.6);
    border-radius: 50%;
    animation: float linear infinite;
    box-shadow: 0 0 6px rgba(74, 144, 226, 0.8);
  }

  @keyframes float {
    0% {
      transform: translateY(100vh) translateX(0);
      opacity: 0;
    }
    10% {
      opacity: 1;
    }
    90% {
      opacity: 1;
    }
    100% {
      transform: translateY(-100px) translateX(100px);
      opacity: 0;
    }
  }

  .grid-overlay {
    position: absolute;
    width: 100%;
    height: 100%;
    background-image: 
      linear-gradient(rgba(74, 144, 226, 0.1) 1px, transparent 1px),
      linear-gradient(90deg, rgba(74, 144, 226, 0.1) 1px, transparent 1px);
    background-size: 60px 60px;
    opacity: 0.3;
    animation: gridMove 20s linear infinite;
  }

  @keyframes gridMove {
    0% {
      transform: translate(0, 0);
    }
    100% {
      transform: translate(60px, 60px);
    }
  }

  .glow-effect {
    position: absolute;
    width: 600px;
    height: 600px;
    background: radial-gradient(circle, rgba(74, 144, 226, 0.3) 0%, transparent 70%);
    border-radius: 50%;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    animation: pulse 4s ease-in-out infinite;
  }

  @keyframes pulse {
    0%, 100% {
      opacity: 0.3;
      transform: translate(-50%, -50%) scale(1);
    }
    50% {
      opacity: 0.6;
      transform: translate(-50%, -50%) scale(1.2);
    }
  }

  .login-container {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: 450px;
    padding: 0 20px;
  }

  .login-form {
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3), 0 0 40px rgba(74, 144, 226, 0.2);
    width: 100%;
    padding: 50px 40px 40px;
    border: 1px solid rgba(255, 255, 255, 0.2);
  }

  .logo-section {
    text-align: center;
    margin-bottom: 40px;
  }

  .logo-img {
    width: 100px;
    height: 100px;
    margin-bottom: 20px;
    filter: drop-shadow(0 4px 12px rgba(74, 144, 226, 0.3));
    animation: logoFloat 3s ease-in-out infinite;
  }

  @keyframes logoFloat {
    0%, 100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-10px);
    }
  }

  .title {
    margin: 0 0 10px 0;
    text-align: center;
    color: #1a1f3a;
    font-size: 28px;
    font-weight: 700;
    background: linear-gradient(135deg, #4A90E2 0%, #50C878 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .subtitle {
    margin: 0;
    text-align: center;
    color: #7f8c8d;
    font-size: 14px;
    font-weight: 400;
  }

  .login-input {
    margin-bottom: 20px;
    
    ::v-deep .el-input__inner {
      height: 48px;
      border-radius: 8px;
      border: 1px solid #e0e0e0;
      background: #f8f9fa;
      transition: all 0.3s;
      font-size: 14px;
      
      &:focus {
        border-color: #4A90E2;
        background: #fff;
        box-shadow: 0 0 0 2px rgba(74, 144, 226, 0.1);
      }
    }
  }

  .code-input {
    width: calc(65% - 10px);
    margin-right: 10px;
  }

  .input-icon {
    height: 48px;
    width: 16px;
    margin-left: 4px;
    color: #909399;
  }

  .login-code {
    width: 35%;
    display: inline-block;
    height: 48px;
    float: right;
    border-radius: 8px;
    overflow: hidden;
    cursor: pointer;
    border: 1px solid #e0e0e0;
    transition: all 0.3s;
    
    &:hover {
      border-color: #4A90E2;
      box-shadow: 0 0 0 2px rgba(74, 144, 226, 0.1);
    }
    
    img {
      width: 100%;
      height: 100%;
      display: block;
    }
  }

  .remember-me {
    margin: 0 0 25px 0;
    color: #606266;
    font-size: 14px;
  }

  .login-button {
    width: 100%;
    height: 48px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    background: linear-gradient(135deg, #4A90E2 0%, #357ABD 100%);
    border: none;
    box-shadow: 0 4px 12px rgba(74, 144, 226, 0.4);
    transition: all 0.3s;
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(74, 144, 226, 0.5);
    }
    
    &:active {
      transform: translateY(0);
    }
  }

  .login-footer {
    position: absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 1;
    color: rgba(255, 255, 255, 0.6);
    font-size: 12px;
    text-align: center;
    
    a {
      color: rgba(255, 255, 255, 0.8);
      text-decoration: none;
      
      &:hover {
        color: #4A90E2;
      }
    }
  }

  @media (max-width: 768px) {
    .login-form {
      padding: 40px 30px 30px;
    }
    
    .title {
      font-size: 24px;
    }
    
    .logo-img {
      width: 80px;
      height: 80px;
    }
  }
</style>
