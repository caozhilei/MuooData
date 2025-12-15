<template>
  <div class="dashboard-container">
    <div class="dashboard-editor-container">
      <!-- 顶部标题区域 -->
      <div class="dashboard-header">
        <div class="header-content">
          <h1 class="dashboard-title">
            <span class="title-icon">📊</span>
            MuooData 数据中台
          </h1>
          <p class="dashboard-subtitle">实时数据监控与分析平台</p>
        </div>
        <div class="header-stats">
          <div class="stat-item">
            <div class="stat-value">{{ currentTime }}</div>
            <div class="stat-label">当前时间</div>
          </div>
        </div>
      </div>

      <!-- 数据卡片组 -->
      <panel-group @handleSetLineChartData="handleSetLineChartData" />

      <!-- 主要图表区域 -->
      <el-row :gutter="24" class="main-charts">
        <el-col :xs="24" :sm="24" :lg="24">
          <div class="chart-wrapper main-chart">
            <div class="chart-header">
              <h3 class="chart-title">数据趋势分析</h3>
              <div class="chart-legend">
                <span class="legend-item">
                  <span class="legend-dot" style="background: #4A90E2;"></span>
                  预期数据
                </span>
                <span class="legend-item">
                  <span class="legend-dot" style="background: #50C878;"></span>
                  实际数据
                </span>
              </div>
            </div>
            <line-chart :chart-data="lineChartData" />
          </div>
        </el-col>
      </el-row>

      <!-- 次要图表区域 -->
      <el-row :gutter="24" class="secondary-charts">
        <el-col :xs="24" :sm="24" :lg="8">
          <div class="chart-wrapper">
            <div class="chart-header">
              <h3 class="chart-title">雷达分析</h3>
            </div>
            <radar-chart />
          </div>
        </el-col>
        <el-col :xs="24" :sm="24" :lg="8">
          <div class="chart-wrapper">
            <div class="chart-header">
              <h3 class="chart-title">占比分析</h3>
            </div>
            <pie-chart />
          </div>
        </el-col>
        <el-col :xs="24" :sm="24" :lg="8">
          <div class="chart-wrapper">
            <div class="chart-header">
              <h3 class="chart-title">柱状对比</h3>
            </div>
            <bar-chart />
          </div>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
import GithubCorner from '@/components/GithubCorner'
import PanelGroup from './dashboard/PanelGroup'
import LineChart from './dashboard/LineChart'
import RadarChart from '@/components/Echarts/RadarChart'
import PieChart from '@/components/Echarts/PieChart'
import BarChart from '@/components/Echarts/BarChart'

const lineChartData = {
  newVisitis: {
    expectedData: [100, 120, 161, 134, 105, 160, 165],
    actualData: [120, 82, 91, 154, 162, 140, 145]
  },
  messages: {
    expectedData: [200, 192, 120, 144, 160, 130, 140],
    actualData: [180, 160, 151, 106, 145, 150, 130]
  },
  purchases: {
    expectedData: [80, 100, 121, 104, 105, 90, 100],
    actualData: [120, 90, 100, 138, 142, 130, 130]
  },
  shoppings: {
    expectedData: [130, 140, 141, 142, 145, 150, 160],
    actualData: [120, 82, 91, 154, 162, 140, 130]
  }
}

export default {
  name: 'Dashboard',
  components: {
    GithubCorner,
    PanelGroup,
    LineChart,
    RadarChart,
    PieChart,
    BarChart
  },
  data() {
    return {
      lineChartData: lineChartData.newVisitis,
      currentTime: ''
    }
  },
  mounted() {
    this.updateTime()
    this.timer = setInterval(() => {
      this.updateTime()
    }, 1000)
  },
  beforeDestroy() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  },
  methods: {
    handleSetLineChartData(type) {
      this.lineChartData = lineChartData[type]
    },
    updateTime() {
      const now = new Date()
      const year = now.getFullYear()
      const month = String(now.getMonth() + 1).padStart(2, '0')
      const day = String(now.getDate()).padStart(2, '0')
      const hours = String(now.getHours()).padStart(2, '0')
      const minutes = String(now.getMinutes()).padStart(2, '0')
      const seconds = String(now.getSeconds()).padStart(2, '0')
      this.currentTime = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
    }
  }
}
</script>

<style rel="stylesheet/scss" lang="scss" scoped>
  .dashboard-container {
    min-height: 100vh;
    background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
  }

  .dashboard-editor-container {
    padding: 24px;
    position: relative;
    min-height: calc(100vh - 50px);
  }

  .dashboard-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    padding: 24px 32px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 12px;
    box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
    color: white;
    position: relative;
    overflow: hidden;

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse"><path d="M 10 0 L 0 0 0 10" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="0.5"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)"/></svg>');
      opacity: 0.3;
    }

    .header-content {
      position: relative;
      z-index: 1;
    }

    .dashboard-title {
      margin: 0 0 8px 0;
      font-size: 32px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 12px;

      .title-icon {
        font-size: 36px;
        animation: bounce 2s ease-in-out infinite;
      }
    }

    @keyframes bounce {
      0%, 100% {
        transform: translateY(0);
      }
      50% {
        transform: translateY(-10px);
      }
    }

    .dashboard-subtitle {
      margin: 0;
      font-size: 16px;
      opacity: 0.9;
      font-weight: 400;
    }

    .header-stats {
      position: relative;
      z-index: 1;
    }

    .stat-item {
      text-align: right;
    }

    .stat-value {
      font-size: 18px;
      font-weight: 600;
      margin-bottom: 4px;
      font-family: 'Courier New', monospace;
    }

    .stat-label {
      font-size: 12px;
      opacity: 0.8;
    }
  }

  .main-charts {
    margin-bottom: 24px;
  }

  .secondary-charts {
    margin-bottom: 24px;
  }

  .chart-wrapper {
    background: #fff;
    border-radius: 12px;
    padding: 24px;
    margin-bottom: 24px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
    transition: all 0.3s ease;
    border: 1px solid rgba(0, 0, 0, 0.06);
    position: relative;
    overflow: hidden;

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: linear-gradient(90deg, #4A90E2 0%, #50C878 100%);
    }

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
    }

    &.main-chart {
      padding: 32px;
    }
  }

  .chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 16px;
    border-bottom: 2px solid #f0f2f5;
  }

  .chart-title {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: #1a1f3a;
    display: flex;
    align-items: center;
    gap: 8px;

    &::before {
      content: '';
      width: 4px;
      height: 18px;
      background: linear-gradient(135deg, #4A90E2 0%, #50C878 100%);
      border-radius: 2px;
    }
  }

  .chart-legend {
    display: flex;
    gap: 20px;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: #606266;
  }

  .legend-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    display: inline-block;
  }

  @media (max-width: 1024px) {
    .dashboard-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 16px;
      padding: 20px;

      .dashboard-title {
        font-size: 24px;
      }

      .header-stats {
        width: 100%;
      }

      .stat-item {
        text-align: left;
      }
    }

    .chart-wrapper {
      padding: 16px;
    }

    .chart-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 12px;
    }
  }

  @media (max-width: 768px) {
    .dashboard-editor-container {
      padding: 16px;
    }

    .chart-wrapper {
      padding: 12px;
    }
  }
</style>
