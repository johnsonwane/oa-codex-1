<template>
  <view class="wrap">
    <view class="card">
      <view class="title">培训OA登录</view>
      <input v-model="username" placeholder="用户名" class="ipt" />
      <input v-model="password" placeholder="密码" class="ipt" password />
      <button type="primary" @click="doLogin">登录</button>
      <view class="msg">{{ msg }}</view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      apiBase: 'https://oac.hahahaxinli.com/api',
      username: 'consult_hg',
      password: '123456',
      msg: ''
    }
  },
  methods: {
    doLogin() {
      uni.request({
        url: `${this.apiBase}/login`,
        method: 'POST',
        data: { username: this.username, password: this.password },
        success: (res) => {
          if (res.statusCode >= 200 && res.statusCode < 300 && res.data.token) {
            uni.setStorageSync('oa_token', res.data.token)
            uni.navigateTo({ url: '/pages/dashboard/dashboard' })
            this.msg = '登录成功'
          } else {
            this.msg = res.data.message || '登录失败'
          }
        },
        fail: () => {
          this.msg = '网络错误'
        }
      })
    }
  }
}
</script>

<style>
.wrap { padding: 30rpx; }
.card { background: #fff; padding: 24rpx; border-radius: 16rpx; }
.title { font-size: 34rpx; font-weight: 600; margin-bottom: 20rpx; }
.ipt { border: 1px solid #ddd; border-radius: 10rpx; padding: 16rpx; margin-bottom: 16rpx; }
.msg { margin-top: 12rpx; color: #666; }
</style>
