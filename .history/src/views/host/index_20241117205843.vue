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
        <el-form-item label="主机名">
          <el-input v-model="searchForm.name" placeholder="请输入主机名" clearable></el-input>
        </el-form-item>
        <el-form-item label="IP地址">
          <el-input v-model="searchForm.ip" placeholder="请输入IP地址" clearable></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="operation-group">
      <el-button type="primary" @click="handleAdd">新增主机</el-button>
      <el-button type="primary" @click="handleBatchTest">批量测试连接</el-button>
      <el-button type="danger" :disabled="!selectedIds.length" @click="handleBatchDelete">批量删除</el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="tableData"
      @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55"></el-table-column>
      <el-table-column prop="name" label="主机名称" min-width="120"></el-table-column>
      <el-table-column prop="envName" label="所属环境" width="120"></el-table-column>
      <el-table-column prop="ip" label="IP地址" width="140"></el-table-column>
      <el-table-column prop="port" label="SSH端口" width="100"></el-table-column>
      <el-table-column prop="username" label="用户名" width="120"></el-table-column>
      <el-table-column prop="authType" label="认证方式" width="100">
        <template slot-scope="scope">
          {{ scope.row.authType === 'password' ? '密码' : '密钥' }}
        </template>
      </el-table-column>
      <el-table-column label="状态" width="100" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
            {{ scope.row.status === 1 ? '在线' : '离线' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160"></el-table-column>
      <el-table-column label="操作" width="280" fixed="right">
        <template slot-scope="scope">
          <el-button type="text" @click="handleTest(scope.row)">测试连接</el-button>
          <el-button type="text" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="text" @click="handleViewInfo(scope.row)">系统信息</el-button>
          <el-button type="text" class="danger" @click="handleDelete(scope.row)">删除</el-button>
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

    <!-- 主机表单弹窗 -->
    <host-form-dialog
      :visible.sync="formDialog.visible"
      :type="formDialog.type"
      :data="formDialog.data"
      :env-options="envOptions"
      @success="handleFormSuccess"
    ></host-form-dialog>

    <!-- 系统信息弹窗 -->
    <el-dialog
      :title="`${currentHost.name} - 系统信息`"
      :visible.sync="infoDialog.visible"
      width="600px"
    >
      <div v-loading="infoDialog.loading">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="操作系统">{{ infoDialog.data.os }}</el-descriptions-item>
          <el-descriptions-item label="内核版本">{{ infoDialog.data.kernel }}</el-descriptions-item>
          <el-descriptions-item label="CPU">{{ infoDialog.data.cpu }}</el-descriptions-item>
          <el-descriptions-item label="内存">{{ infoDialog.data.memory }}</el-descriptions-item>
          <el-descriptions-item label="磁盘">{{ infoDialog.data.disk }}</el-descriptions-item>
          <el-descriptions-item label="运行时间">{{ infoDialog.data.uptime }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { 
  getHostList, 
  deleteHost, 
  batchDeleteHost,
  testHostConnection,
  batchTestConnection,
  getHostSystemInfo
} from '@/api/host'
import { getEnvironmentList } from '@/api/environment'
import HostFormDialog from './components/HostFormDialog.vue'

export default {
  name: 'Host',
  components: {
    HostFormDialog
  },
  data() {
    return {
      loading: false,
      searchForm: {
        envId: '',
        name: '',
        ip: ''
      },
      envOptions: [],
      tableData: [],
      selectedIds: [],
      page: {
        current: 1,
        size: 10,
        total: 0
      },
      formDialog: {
        visible: false,
        type: 'add',
        data: null
      },
      infoDialog: {
        visible: false,
        loading: false,
        data: {}
      },
      currentHost: {}
    }
  },
  created() {
    this.getEnvList()
    this.getList()
  },
  methods: {
    async getEnvList() {
      try {
        const { data } = await getEnvironmentList()
        this.envOptions = data.filter(item => item.status === 1)
      } catch (error) {
        console.error(error)
      }
    },
    async getList() {
      this.loading = true
      try {
        const { data } = await getHostList({
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
    handleSearch() {
      this.page.current = 1
      this.getList()
    },
    resetSearch() {
      this.$refs.searchForm.resetFields()
      this.handleSearch()
    },
    handleSelectionChange(selection) {
      this.selectedIds = selection.map(item => item.id)
    },
    handleAdd() {
      this.formDialog.type = 'add'
      this.formDialog.data = null
      this.formDialog.visible = true
    },
    handleEdit(row) {
      this.formDialog.type = 'edit'
      this.formDialog.data = { ...row }
      this.formDialog.visible = true
    },
    async handleDelete(row) {
      try {
        await this.$confirm('确认删除该主机?', '提示', {
          type: 'warning'
        })
        await deleteHost(row.id)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleBatchDelete() {
      try {
        await this.$confirm(`确认删除选中的 ${this.selectedIds.length} 台主机?`, '提示', {
          type: 'warning'
        })
        await batchDeleteHost(this.selectedIds)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleTest(row) {
      try {
        await testHostConnection(row.id)
        this.$message.success('连接成功')
        this.getList()
      } catch (error) {
        this.$message.error('连接失败')
      }
    },
    async handleBatchTest() {
      const loading = this.$loading({
        text: '正在测试连接...'
      })
      try {
        await batchTestConnection()
        this.$message.success('测试完成')
        this.getList()
      } catch (error) {
        console.error(error)
      }
      loading.close()
    },
    async handleViewInfo(row) {
      this.currentHost = row
      this.infoDialog.visible = true
      this.infoDialog.loading = true
      try {
        const { data } = await getHostSystemInfo(row.id)
        this.infoDialog.data = data
      } catch (error) {
        console.error(error)
      }
      this.infoDialog.loading = false
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
.danger {
  color: $--color-danger;
}
</style> 