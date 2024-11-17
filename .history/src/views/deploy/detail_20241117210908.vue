<template>
  <div class="page-container">
    <!-- 基本信息 -->
    <div class="info-card">
      <div class="info-card__title">发布信息</div>
      <el-descriptions :column="3" border>
        <el-descriptions-item label="环境">{{ deploy.envName }}</el-descriptions-item>
        <el-descriptions-item label="项目">{{ deploy.projectName }}</el-descriptions-item>
        <el-descriptions-item label="版本">{{ deploy.version }}</el-descriptions-item>
        <el-descriptions-item label="部署目录">/{{ deploy.deployPath }}</el-descriptions-item>
        <el-descriptions-item label="发布人">{{ deploy.creator }}</el-descriptions-item>
        <el-descriptions-item label="发布时间">{{ deploy.createTime }}</el-descriptions-item>
      </el-descriptions>
    </div>

    <!-- 发布进度 -->
    <div class="info-card">
      <div class="info-card__title">发布进度</div>
      <el-steps :active="deploy.step" align-center finish-status="success">
        <el-step title="准备" description="准备发布环境"></el-step>
        <el-step title="前置脚本" description="执行前置脚本"></el-step>
        <el-step title="部署" description="部署项目文件"></el-step>
        <el-step title="后置脚本" description="执行后置脚本"></el-step>
        <el-step title="完成" description="发布完成"></el-step>
      </el-steps>
    </div>

    <!-- 主机列表 -->
    <div class="info-card">
      <div class="info-card__title">主机列表</div>
      <el-table :data="deploy.hosts" v-loading="loading">
        <el-table-column prop="name" label="主机名称"></el-table-column>
        <el-table-column prop="ip" label="IP地址"></el-table-column>
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template slot-scope="scope">
            <el-tag :type="getHostStatusType(scope.row.status)">
              {{ getHostStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="progress" label="进度" width="200">
          <template slot-scope="scope">
            <el-progress 
              :percentage="scope.row.progress" 
              :status="getProgressStatus(scope.row)"
            ></el-progress>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center">
          <template slot-scope="scope">
            <el-button 
              type="text" 
              @click="handleViewLog(scope.row)"
              v-if="scope.row.status !== 0"
            >查看日志</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 脚本配置 -->
    <div class="info-card">
      <div class="info-card__title">脚本配置</div>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="前置脚本">
          <template v-if="deploy.beforeScripts?.length">
            <div 
              v-for="(script, index) in deploy.beforeScripts" 
              :key="index"
              class="script-info"
            >
              {{ index + 1 }}. {{ script.name }}
              <span v-if="script.params" class="script-params">
                参数：{{ script.params }}
              </span>
            </div>
          </template>
          <span v-else>无</span>
        </el-descriptions-item>
        <el-descriptions-item label="后置脚本">
          <template v-if="deploy.afterScripts?.length">
            <div 
              v-for="(script, index) in deploy.afterScripts" 
              :key="index"
              class="script-info"
            >
              {{ index + 1 }}. {{ script.name }}
              <span v-if="script.params" class="script-params">
                参数：{{ script.params }}
              </span>
            </div>
          </template>
          <span v-else>无</span>
        </el-descriptions-item>
      </el-descriptions>
    </div>

    <!-- 日志弹窗 -->
    <el-dialog
      :title="`部署日志 - ${currentHost?.name || ''}`"
      :visible.sync="logDialog.visible"
      width="800px"
      :close-on-click-modal="false"
      custom-class="log-dialog"
    >
      <div class="log-content" v-loading="logDialog.loading">
        <pre ref="logContent" v-html="logDialog.content"></pre>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getDeployDetail, getHostLog } from '@/api/deploy'

export default {
  name: 'DeployDetail',
  data() {
    return {
      loading: false,
      deploy: {},
      logDialog: {
        visible: false,
        loading: false,
        content: ''
      },
      currentHost: null,
      logWs: null,
      timer: null
    }
  },
  created() {
    this.getDetail()
    // 如果发布未完成，定时刷新
    this.startRefresh()
  },
  beforeDestroy() {
    this.stopRefresh()
    if (this.logWs) {
      this.logWs.close()
    }
  },
  methods: {
    async getDetail() {
      this.loading = true
      try {
        const { data } = await getDeployDetail(this.$route.params.id)
        this.deploy = data
      } catch (error) {
        console.error(error)
      }
      this.loading = false
    },
    getHostStatusType(status) {
      const map = {
        0: 'info',    // 待发布
        1: '',        // 发布中
        2: 'success', // 发布成功
        3: 'danger'   // 发布失败
      }
      return map[status]
    },
    getHostStatusText(status) {
      const map = {
        0: '待发布',
        1: '发布中',
        2: '成功',
        3: '失败'
      }
      return map[status]
    },
    getProgressStatus(host) {
      if (host.status === 2) return 'success'
      if (host.status === 3) return 'exception'
      return ''
    },
    async handleViewLog(host) {
      this.currentHost = host
      this.logDialog.visible = true
      this.logDialog.loading = true
      try {
        const { data } = await getHostLog(this.deploy.id, host.id)
        this.logDialog.content = this.formatLog(data)
        this.connectLogWs(host.id)
      } catch (error) {
        console.error(error)
      }
      this.logDialog.loading = false
    },
    formatLog(text) {
      const colorMap = {
        info: '#fff',
        error: '#f56c6c',
        success: '#67c23a'
      }
      return text.split('\n').map(line => {
        if (line.includes('[ERROR]')) {
          return `<span style="color: ${colorMap.error}">${line}</span>`
        } else if (line.includes('[SUCCESS]')) {
          return `<span style="color: ${colorMap.success}">${line}</span>`
        }
        return `<span style="color: ${colorMap.info}">${line}</span>`
      }).join('\n')
    },
    connectLogWs(hostId) {
      if (this.logWs) {
        this.logWs.close()
      }

      this.logWs = new WebSocket(`ws://localhost:3000/api/deploy/host/log/${this.deploy.id}/${hostId}`)
      
      this.logWs.onmessage = (event) => {
        const data = JSON.parse(event.data)
        if (data.type === 'log') {
          this.logDialog.content += this.formatLog(data.content)
          this.$nextTick(() => {
            if (this.$refs.logContent) {
              this.$refs.logContent.scrollTop = this.$refs.logContent.scrollHeight
            }
          })
        }
      }
      
      this.logWs.onerror = () => {
        console.error('WebSocket连接失败')
      }
    },
    startRefresh() {
      if ([0, 1].includes(this.deploy.status)) {
        this.timer = setInterval(() => {
          this.getDetail()
        }, 3000)
      }
    },
    stopRefresh() {
      if (this.timer) {
        clearInterval(this.timer)
        this.timer = null
      }
    }
  },
  watch: {
    'deploy.status'(val) {
      if (![0, 1].includes(val)) {
        this.stopRefresh()
      }
    },
    'logDialog.visible'(val) {
      if (!val && this.logWs) {
        this.logWs.close()
        this.logWs = null
        this.logDialog.content = ''
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.info-card {
  background: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
  
  &__title {
    font-size: 16px;
    color: #303133;
    margin-bottom: 20px;
    font-weight: 500;
  }
}

.script-info {
  line-height: 1.8;

  .script-params {
    color: #909399;
    margin-left: 10px;
  }
}

.log-dialog {
  :deep(.el-dialog__body) {
    padding: 0;
  }
}

.log-content {
  height: 500px;
  padding: 10px;
  background-color: #1e1e1e;
  font-family: Consolas, Monaco, monospace;
  overflow: auto;

  pre {
    margin: 0;
    white-space: pre-wrap;
    word-wrap: break-word;
  }
}
</style> 