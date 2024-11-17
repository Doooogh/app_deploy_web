<template>
  <div class="page-container">
    <div class="operation-group">
      <el-button type="primary" @click="handleAdd">新增环境</el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="tableData"
      row-key="id"
    >
      <el-table-column prop="name" label="环境名称" min-width="120"></el-table-column>
      <el-table-column prop="code" label="环境标识" width="120"></el-table-column>
      <el-table-column prop="description" label="描述" min-width="200"></el-table-column>
      <el-table-column prop="hostCount" label="主机数量" width="100" align="center"></el-table-column>
      <el-table-column prop="projectCount" label="项目数量" width="100" align="center"></el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160"></el-table-column>
      <el-table-column label="状态" width="100" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">
            {{ scope.row.status === 1 ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="250" fixed="right">
        <template slot-scope="scope">
          <el-button 
            type="text" 
            @click="handleToggleStatus(scope.row)"
          >{{ scope.row.status === 1 ? '禁用' : '启用' }}</el-button>
          <el-button type="text" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="text" @click="handleViewHosts(scope.row)">查看主机</el-button>
          <el-button 
            type="text" 
            class="danger" 
            @click="handleDelete(scope.row)"
            :disabled="scope.row.hostCount > 0"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 环境表单弹窗 -->
    <environment-form-dialog
      :visible.sync="formDialog.visible"
      :type="formDialog.type"
      :data="formDialog.data"
      @success="handleFormSuccess"
    ></environment-form-dialog>

    <!-- 主机列表弹窗 -->
    <el-dialog
      :title="`${currentEnv.name} - 主机列表`"
      :visible.sync="hostDialog.visible"
      width="800px"
    >
      <el-table
        v-loading="hostDialog.loading"
        :data="hostDialog.list"
      >
        <el-table-column prop="name" label="主机名称"></el-table-column>
        <el-table-column prop="ip" label="IP地址"></el-table-column>
        <el-table-column prop="port" label="SSH端口"></el-table-column>
        <el-table-column prop="username" label="用户名"></el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template slot-scope="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '在线' : '离线' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script>
import { 
  getEnvironmentList, 
  deleteEnvironment, 
  toggleEnvironmentStatus,
  getEnvironmentHosts 
} from '@/api/environment'
import EnvironmentFormDialog from './components/EnvironmentFormDialog.vue'

export default {
  name: 'Environment',
  components: {
    EnvironmentFormDialog
  },
  data() {
    return {
      loading: false,
      tableData: [],
      formDialog: {
        visible: false,
        type: 'add',
        data: null
      },
      hostDialog: {
        visible: false,
        loading: false,
        list: []
      },
      currentEnv: {}
    }
  },
  created() {
    this.getList()
  },
  methods: {
    async getList() {
      this.loading = true
      try {
        const { data } = await getEnvironmentList()
        this.tableData = data
      } catch (error) {
        console.error(error)
      }
      this.loading = false
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
        await this.$confirm('确认删除该环境?', '提示', {
          type: 'warning'
        })
        await deleteEnvironment(row.id)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleToggleStatus(row) {
      try {
        const tipText = row.status === 1 ? '禁用' : '启用'
        await this.$confirm(`确认${tipText}该环境?`, '提示', {
          type: 'warning'
        })
        await toggleEnvironmentStatus(row.id)
        this.$message.success(`${tipText}成功`)
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleViewHosts(row) {
      this.currentEnv = row
      this.hostDialog.visible = true
      this.hostDialog.loading = true
      try {
        const { data } = await getEnvironmentHosts(row.id)
        this.hostDialog.list = data
      } catch (error) {
        console.error(error)
      }
      this.hostDialog.loading = false
    },
    handleFormSuccess() {
      this.formDialog.visible = false
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