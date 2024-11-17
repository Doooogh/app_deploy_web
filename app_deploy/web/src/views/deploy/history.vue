<template>
  <div class="page-container">
    <div class="search-form">
      <el-form :inline="true" :model="searchForm" ref="searchForm">
        <el-form-item label="环境">
          <el-select v-model="searchForm.envId" placeholder="请选择环境" clearable>
            <el-option
              v-for="item in envOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="项目">
          <el-select v-model="searchForm.projectId" placeholder="请选择项目" clearable>
            <el-option
              v-for="item in projectOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="待发布" value="0"></el-option>
            <el-option label="发布中" value="1"></el-option>
            <el-option label="发布成功" value="2"></el-option>
            <el-option label="发布失败" value="3"></el-option>
            <el-option label="已回滚" value="4"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-tabs v-model="activeTab" @tab-click="handleTabClick">
      <el-tab-pane 
        v-for="item in envOptions" 
        :key="item.id"
        :label="item.name"
        :name="item.id.toString()"
      >
        <el-table
          v-loading="loading"
          :data="tableData"
        >
          <el-table-column prop="projectName" label="项目" min-width="120"></el-table-column>
          <el-table-column prop="version" label="版本" width="120"></el-table-column>
          <el-table-column prop="hostCount" label="主机数" width="100" align="center"></el-table-column>
          <el-table-column prop="status" label="状态" width="100" align="center">
            <template slot-scope="scope">
              <el-tag :type="getStatusType(scope.row.status)">
                {{ getStatusText(scope.row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="creator" label="发布人" width="120"></el-table-column>
          <el-table-column prop="createTime" label="发布时间" width="160"></el-table-column>
          <el-table-column label="操作" width="300" fixed="right">
            <template slot-scope="scope">
              <el-button 
                type="text" 
                @click="handleDetail(scope.row)"
              >详情</el-button>
              <el-button 
                type="text" 
                @click="handleLog(scope.row)"
                v-if="scope.row.status !== 0"
              >日志</el-button>
              <el-button 
                type="text" 
                @click="handleRollback(scope.row)"
                v-if="scope.row.status === 2 && scope.row.isActive"
              >回滚</el-button>
              <el-button 
                type="text" 
                @click="handleRedeploy(scope.row)"
                v-if="scope.row.status === 3"
              >重新发布</el-button>
              <el-button 
                type="text" 
                class="danger" 
                @click="handleCancel(scope.row)"
                v-if="scope.row.status === 0"
              >取消</el-button>
            </template>
          </el-table-column>
        </el-table>

        <el-pagination
          :current-page="page.current"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="page.size"
          :total="page.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </el-tab-pane>
    </el-tabs>

    <!-- 发布详情弹窗 -->
    <el-dialog
      :title="`发布详情 - ${currentDeploy.projectName || ''}`"
      :visible.sync="detailDialog.visible"
      width="800px"
    >
      <el-descriptions title="基本信息" :column="2" border>
        <el-descriptions-item label="环境">{{ currentDeploy.envName }}</el-descriptions-item>
        <el-descriptions-item label="项目">{{ currentDeploy.projectName }}</el-descriptions-item>
        <el-descriptions-item label="版本">{{ currentDeploy.version }}</el-descriptions-item>
        <el-descriptions-item label="部署目录">/{{ currentDeploy.deployPath }}</el-descriptions-item>
        <el-descriptions-item label="发布人">{{ currentDeploy.creator }}</el-descriptions-item>
        <el-descriptions-item label="发布时间">{{ currentDeploy.createTime }}</el-descriptions-item>
      </el-descriptions>

      <el-descriptions title="主机列表" :column="1" border class="mt20">
        <el-descriptions-item>
          <el-table :data="detailDialog.hosts" size="small">
            <el-table-column prop="name" label="主机名称"></el-table-column>
            <el-table-column prop="ip" label="IP地址"></el-table-column>
            <el-table-column prop="status" label="状态" width="100" align="center">
              <template slot-scope="scope">
                <el-tag :type="getHostStatusType(scope.row.status)">
                  {{ getHostStatusText(scope.row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" align="center">
              <template slot-scope="scope">
                <el-button 
                  type="text" 
                  @click="handleHostLog(scope.row)"
                  v-if="scope.row.status !== 0"
                >日志</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-descriptions-item>
      </el-descriptions>

      <el-descriptions title="执行脚本" :column="1" border class="mt20">
        <el-descriptions-item label="前置脚本">
          <template v-if="currentDeploy.beforeScripts?.length">
            <div 
              v-for="(script, index) in currentDeploy.beforeScripts" 
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
          <template v-if="currentDeploy.afterScripts?.length">
            <div 
              v-for="(script, index) in currentDeploy.afterScripts" 
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
    </el-dialog>

    <!-- 日志弹窗 -->
    <el-dialog
      :title="`发布日志 ${currentHost ? `- ${currentHost.name}` : ''}`"
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
import { 
  getEnvironmentList 
} from '@/api/environment'
import { 
  getProjectList 
} from '@/api/project'
import { 
  getDeployList,
  getDeployDetail,
  getDeployLog,
  getHostLog,
  cancelDeploy,
  rollbackDeploy,
  redeployDeploy
} from '@/api/deploy'

export default {
  name: 'DeployHistory',
  data() {
    return {
      loading: false,
      searchForm: {
        envId: '',
        projectId: '',
        status: ''
      },
      envOptions: [],
      projectOptions: [],
      activeTab: '',
      tableData: [],
      page: {
        current: 1,
        size: 10,
        total: 0
      },
      detailDialog: {
        visible: false,
        hosts: []
      },
      logDialog: {
        visible: false,
        loading: false,
        content: ''
      },
      currentDeploy: {},
      currentHost: null,
      logWs: null
    }
  },
  created() {
    this.getEnvList()
    this.getProjectList()
  },
  methods: {
    async getEnvList() {
      try {
        const { data } = await getEnvironmentList()
        this.envOptions = data
        if (data.length) {
          this.activeTab = data[0].id.toString()
          this.searchForm.envId = data[0].id
          this.getList()
        }
      } catch (error) {
        console.error(error)
      }
    },
    async getProjectList() {
      try {
        const { data } = await getProjectList()
        this.projectOptions = data.list
      } catch (error) {
        console.error(error)
      }
    },
    async getList() {
      this.loading = true
      try {
        const { data } = await getDeployList({
          ...this.searchForm,
          page: this.page.current,
          size: this.page.size
        })
        this.tableData = data.list
        this.page.total = data.total
      } catch (error) {
        console.error(error)
      }
      this.loading = false
    },
    getStatusType(status) {
      const map = {
        0: 'info',    // 待发布
        1: '',        // 发布中
        2: 'success', // 发布成功
        3: 'danger',  // 发布失败
        4: 'warning'  // 已回滚
      }
      return map[status]
    },
    getStatusText(status) {
      const map = {
        0: '待发布',
        1: '发布中',
        2: '成功',
        3: '失败',
        4: '已回滚'
      }
      return map[status]
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
    handleSearch() {
      this.page.current = 1
      this.getList()
    },
    resetSearch() {
      this.$refs.searchForm.resetFields()
      this.handleSearch()
    },
    handleTabClick() {
      this.searchForm.envId = Number(this.activeTab)
      this.handleSearch()
    },
    async handleDetail(row) {
      this.currentDeploy = row
      this.detailDialog.visible = true
      try {
        const { data } = await getDeployDetail(row.id)
        this.detailDialog.hosts = data.hosts
        Object.assign(this.currentDeploy, data)
      } catch (error) {
        console.error(error)
      }
    },
    async handleLog(row) {
      this.currentDeploy = row
      this.currentHost = null
      this.logDialog.visible = true
      this.logDialog.loading = true
      try {
        const { data } = await getDeployLog(row.id)
        this.logDialog.content = this.formatLog(data)
        this.connectLogWs(row.id)
      } catch (error) {
        console.error(error)
      }
      this.logDialog.loading = false
    },
    async handleHostLog(host) {
      this.currentHost = host
      this.logDialog.visible = true
      this.logDialog.loading = true
      try {
        const { data } = await getHostLog(this.currentDeploy.id, host.id)
        this.logDialog.content = this.formatLog(data)
        this.connectLogWs(this.currentDeploy.id, host.id)
      } catch (error) {
        console.error(error)
      }
      this.logDialog.loading = false
    },
    async handleCancel(row) {
      try {
        await this.$confirm('确认取消该发布单?', '提示', {
          type: 'warning'
        })
        await cancelDeploy(row.id)
        this.$message.success('取消成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleRollback(row) {
      try {
        await this.$confirm('确认回滚该发布?', '提示', {
          type: 'warning'
        })
        await rollbackDeploy(row.id)
        this.$message.success('开始回滚')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleRedeploy(row) {
      try {
        await this.$confirm('确认重新发布?', '提示', {
          type: 'warning'
        })
        await redeployDeploy(row.id)
        this.$message.success('开始重新发布')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    handleSizeChange(val) {
      this.page.size = val
      this.getList()
    },
    handleCurrentChange(val) {
      this.page.current = val
      this.getList()
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
    connectLogWs(deployId, hostId) {
      if (this.logWs) {
        this.logWs.close()
      }

      const wsUrl = hostId 
        ? `ws://localhost:3000/api/deploy/host/log/${deployId}/${hostId}`
        : `ws://localhost:3000/api/deploy/log/${deployId}`

      this.logWs = new WebSocket(wsUrl)
      
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
    }
  },
  beforeDestroy() {
    if (this.logWs) {
      this.logWs.close()
    }
  },
  watch: {
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
.mt20 {
  margin-top: 20px;
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