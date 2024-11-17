<template>
  <div class="page-container">
    <div class="project-info info-card">
      <div class="info-card__title">项目信息</div>
      <el-descriptions :column="3" border>
        <el-descriptions-item label="项目名称">{{ project.name }}</el-descriptions-item>
        <el-descriptions-item label="仓库类型">{{ project.repoType === 'git' ? 'Git' : 'SVN' }}</el-descriptions-item>
        <el-descriptions-item label="默认分支">{{ project.branch }}</el-descriptions-item>
        <el-descriptions-item label="仓库地址">{{ project.repoUrl }}</el-descriptions-item>
        <el-descriptions-item label="版本数量">{{ project.versionCount }}</el-descriptions-item>
        <el-descriptions-item label="部署次数">{{ project.deployCount }}</el-descriptions-item>
      </el-descriptions>
    </div>

    <div class="operation-group">
      <el-button type="primary" @click="handleAdd">新增版本</el-button>
      <el-button type="danger" :disabled="!selectedIds.length" @click="handleBatchDelete">批量删除</el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="tableData"
      @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55"></el-table-column>
      <el-table-column prop="version" label="版本号" min-width="120"></el-table-column>
      <el-table-column prop="branch" label="分支/标签" width="120"></el-table-column>
      <el-table-column prop="commit" label="Commit ID" width="100" show-overflow-tooltip></el-table-column>
      <el-table-column prop="buildStatus" label="构建状态" width="100" align="center">
        <template slot-scope="scope">
          <el-tag :type="getBuildStatusType(scope.row.buildStatus)">
            {{ getBuildStatusText(scope.row.buildStatus) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="buildTime" label="构建时间" width="100" align="center"></el-table-column>
      <el-table-column prop="artifactSize" label="制品大小" width="100" align="center"></el-table-column>
      <el-table-column prop="creator" label="创建人" width="120"></el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160"></el-table-column>
      <el-table-column label="操作" width="300" fixed="right">
        <template slot-scope="scope">
          <el-button 
            type="text" 
            @click="handleBuild(scope.row)"
            :disabled="scope.row.buildStatus === 1"
          >构建</el-button>
          <el-button 
            type="text" 
            @click="handleLog(scope.row)"
            v-if="scope.row.buildStatus !== 0"
          >构建日志</el-button>
          <el-button 
            type="text" 
            @click="handleDownload(scope.row)"
            :disabled="scope.row.buildStatus !== 2"
          >下载制品</el-button>
          <el-button type="text" @click="handleDeploy(scope.row)">发布</el-button>
          <el-button 
            type="text" 
            class="danger" 
            @click="handleDelete(scope.row)"
            :disabled="scope.row.buildStatus === 1"
          >删除</el-button>
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

    <!-- 新增版本弹窗 -->
    <version-form-dialog
      :visible.sync="formDialog.visible"
      :project-id="projectId"
      @success="handleFormSuccess"
    ></version-form-dialog>

    <!-- 构建日志弹窗 -->
    <el-dialog
      :title="`构建日志 - ${currentVersion.version}`"
      :visible.sync="logDialog.visible"
      width="800px"
      :close-on-click-modal="false"
      custom-class="log-dialog"
    >
      <div class="log-content" v-loading="logDialog.loading">
        <pre>{{ logDialog.content }}</pre>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { 
  getProject,
  getVersionList, 
  deleteVersion,
  batchDeleteVersion,
  buildVersion,
  getBuildLog,
  downloadArtifact
} from '@/api/project'
import VersionFormDialog from './components/VersionFormDialog.vue'

export default {
  name: 'ProjectVersion',
  components: {
    VersionFormDialog
  },
  data() {
    return {
      projectId: this.$route.params.id,
      project: {},
      loading: false,
      tableData: [],
      selectedIds: [],
      page: {
        current: 1,
        size: 10,
        total: 0
      },
      formDialog: {
        visible: false
      },
      logDialog: {
        visible: false,
        loading: false,
        content: '',
      },
      currentVersion: {}
    }
  },
  created() {
    this.getProjectInfo()
    this.getList()
  },
  methods: {
    async getProjectInfo() {
      try {
        const { data } = await getProject(this.projectId)
        this.project = data
      } catch (error) {
        console.error(error)
      }
    },
    async getList() {
      this.loading = true
      try {
        const { data } = await getVersionList({
          projectId: this.projectId,
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
    getBuildStatusType(status) {
      const map = {
        0: 'info',    // 未构建
        1: '',        // 构建中
        2: 'success', // 构建成功
        3: 'danger'   // 构建失败
      }
      return map[status]
    },
    getBuildStatusText(status) {
      const map = {
        0: '未构建',
        1: '构建中',
        2: '成功',
        3: '失败'
      }
      return map[status]
    },
    handleSelectionChange(selection) {
      this.selectedIds = selection.map(item => item.id)
    },
    handleAdd() {
      this.formDialog.visible = true
    },
    async handleDelete(row) {
      try {
        await this.$confirm('确认删除该版本?', '提示', {
          type: 'warning'
        })
        await deleteVersion(row.id)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleBatchDelete() {
      try {
        await this.$confirm(`确认删除选中的 ${this.selectedIds.length} 个版本?`, '提示', {
          type: 'warning'
        })
        await batchDeleteVersion(this.selectedIds)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleBuild(row) {
      try {
        await this.$confirm('确认开始构建?', '提示', {
          type: 'warning'
        })
        await buildVersion(row.id)
        this.$message.success('开始构建')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleLog(row) {
      this.currentVersion = row
      this.logDialog.visible = true
      this.logDialog.loading = true
      try {
        const { data } = await getBuildLog(row.id)
        this.logDialog.content = data
      } catch (error) {
        console.error(error)
      }
      this.logDialog.loading = false
    },
    handleDownload(row) {
      downloadArtifact(row.id)
    },
    handleDeploy(row) {
      this.$router.push({
        path: '/deploy/create',
        query: {
          projectId: this.projectId,
          versionId: row.id
        }
      })
    },
    handleFormSuccess() {
      this.formDialog.visible = false
      this.getList()
    },
    handleSizeChange(val) {
      this.page.size = val
      this.getList()
    },
    handleCurrentChange(val) {
      this.page.current = val
      this.getList()
    }
  }
}
</script>

<style lang="scss" scoped>
.project-info {
  margin-bottom: 20px;
}

.danger {
  color: $--color-danger;
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
  color: #fff;
  font-family: Consolas, Monaco, monospace;
  overflow: auto;

  pre {
    margin: 0;
    white-space: pre-wrap;
    word-wrap: break-word;
  }
}
</style> 