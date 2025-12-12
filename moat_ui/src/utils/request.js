import axios from 'axios'
import router from '@/router/routers'
import { Notification } from 'element-ui'
import store from '../store'
import { getToken } from '@/utils/auth'
import Config from '@/settings'
import Cookies from 'js-cookie'

// 创建axios实例
const service = axios.create({
  baseURL: process.env.NODE_ENV === 'production' ? process.env.VUE_APP_BASE_API : '/', // api 的 base_url
  timeout: Config.timeout // 请求超时时间
})

// request拦截器
service.interceptors.request.use(
  config => {
    // #region agent log
    fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:18',message:'API请求开始',data:{url:config.url,baseURL:config.baseURL,method:config.method,hasToken:!!getToken(),target:process.env.VUE_APP_BASE_API},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'B'})}).catch(()=>{});
    // #endregion
    if (getToken()) {
      config.headers['Authorization'] = getToken() // 让每个请求携带自定义token 请根据实际情况自行修改
    }
    config.headers['Content-Type'] = 'application/json'
    return config
  },
  error => {
    // #region agent log
    fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:25',message:'请求拦截器错误',data:{error:error.toString()},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
    // #endregion
    Promise.reject(error)
  }
)

// response 拦截器
service.interceptors.response.use(
  response => {
    // #region agent log
    fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:32',message:'API响应成功',data:{status:response.status,url:response.config && response.config.url,hasData:!!response.data,responseSuccess:response.data && response.data.success},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'A'})}).catch(()=>{});
    // #endregion
    // 检查响应体中的success字段，如果为false则视为错误
    if (response.data && response.data.success === false) {
      // #region agent log
      fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:42',message:'响应体success为false，视为错误',data:{code:response.data.code,msg:response.data.msg,url:response.config && response.config.url},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
      // #endregion
      // 构造一个错误对象，使其能被错误处理逻辑识别
      const error = new Error(response.data.msg || '接口请求失败')
      error.response = {
        status: response.data.code || 500,
        data: {
          code: response.data.code || 500, // 添加code字段，方便错误处理逻辑读取
          status: response.data.code || 500,
          msg: response.data.msg || '接口请求失败', // 添加msg字段，方便错误处理逻辑读取
          message: response.data.msg || '接口请求失败'
        }
      }
      error.config = response.config
      // #region agent log
      fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:56',message:'构造错误对象完成',data:{code:error.response.data.code,msg:error.response.data.msg,message:error.response.data.message,url:response.config && response.config.url},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
      // #endregion
      return Promise.reject(error)
    }
    return response.data
  },
  error => {
    // #region agent log
    const errorInfo = {
      hasResponse: !!error.response,
      responseStatus: error.response && error.response.status,
      responseData: error.response && error.response.data,
      message: error.message,
      code: error.code,
      configUrl: error.config && error.config.url,
      configBaseURL: error.config && error.config.baseURL,
      toString: error.toString()
    };
    fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:35',message:'API响应错误',data:errorInfo,timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'A,B,C,D'})}).catch(()=>{});
    // #endregion
    let code = 0
    try {
      // 优先读取code字段（后端返回格式），如果没有则读取status字段
      code = error.response.data.code || error.response.data.status
      // #region agent log
      fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:77',message:'读取错误代码',data:{code:code,hasResponseData:!!error.response.data,responseDataKeys:error.response.data?Object.keys(error.response.data):[],url:error.config&&error.config.url},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
      // #endregion
    } catch (e) {
      if (error.toString().indexOf('Error: timeout') !== -1) {
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:40',message:'请求超时',data:{error:error.toString()},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'C'})}).catch(()=>{});
        // #endregion
        Notification.error({
          title: '网络请求超时',
          duration: 5000
        })
        return Promise.reject(error)
      }
    }
    console.log(code)
    if (code) {
      if (code === 401) {
        store.dispatch('LogOut').then(() => {
          // 用户登录界面提示
          Cookies.set('point', 401)
          location.reload()
        })
      } else if (code === 403) {
        router.push({ path: '/401' })
      } else {
        // 优先读取msg字段（后端返回格式），如果没有则读取message字段
        const errorMsg = error.response.data.msg || error.response.data.message
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:100',message:'显示具体错误信息',data:{code:code,errorMsg:errorMsg,hasErrorMsg:errorMsg!==undefined},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
        // #endregion
        if (errorMsg !== undefined) {
          Notification.error({
            title: errorMsg,
            duration: 5000
          })
        }
      }
    } else {
      // #region agent log
      fetch('http://127.0.0.1:7242/ingest/476bd62a-d512-4107-927d-b7b015f6e9db',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'request.js:67',message:'显示接口请求失败提示',data:{code:code,hasResponse:!!error.response},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
      // #endregion
      Notification.error({
        title: '接口请求失败',
        duration: 5000
      })
    }

    return Promise.reject(error)
  }
)
export default service
