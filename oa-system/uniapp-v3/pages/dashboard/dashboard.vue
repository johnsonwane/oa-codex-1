<template>
  <view class="wrap">
    <view class="card">
      <view class="title">OA总览</view>
      <view class="grid">
        <view class="item">学员：{{ summary.student }}</view>
        <view class="item">订单：{{ summary.order }}</view>
        <view class="item">收入：{{ finance.total_income }}</view>
        <view class="item">支出：{{ finance.total_expense }}</view>
      </view>
      <button @click="loadSummary">刷新</button>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      apiBase: 'http://localhost/api',
      summary: {},
      finance: {}
    }
  },
  onShow() {
    this.loadSummary()
  },
  methods: {
    loadSummary() {
      const token = uni.getStorageSync('oa_token')
      uni.request({
        url: `${this.apiBase}/dashboard/summary`,
        method: 'GET',
        header: {
          Authorization: `Bearer ${token}`
        },
        success: (res) => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            this.summary = res.data.counts || {}
            this.finance = res.data.finance || {}
          }
        }
      })
    }
  }
}
</script>

<style>
.wrap { padding: 30rpx; }
.card { background: #fff; border-radius: 16rpx; padding: 24rpx; }
.title { font-size: 32rpx; margin-bottom: 12rpx; font-weight: 600; }
.grid { display: flex; flex-wrap: wrap; gap: 12rpx; margin-bottom: 16rpx; }
.item { width: 48%; background: #eef2ff; border-radius: 10rpx; padding: 12rpx; box-sizing: border-box; }
</style>
