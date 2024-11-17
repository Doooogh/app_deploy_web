<template>
  <div class="page-container">
    <div class="search-form">
      <el-form :inline="true" :model="searchForm" ref="searchForm">
        <el-form-item label="名称">
          <el-input v-model="searchForm.name" placeholder="请输入名称" clearable></el-input>
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="searchForm.type" placeholder="请选择类型" clearable>
            <el-option label="用户名密码" value="password"></el-option>
            <el-option label="SSH密钥" value="ssh"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="operation-group">
      <el-button type="primary" @click="handleAdd">新增密码</el-button>
      <el-button type="danger" :disabled="!selectedIds.length" @click="handleBatchDelete">批量删除</el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="tableData"
      @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55"></el-table-column>
      <el-table-column prop="name" label="名称" min-width="120"></el-table-column>
      <el-table-column prop="type" label="类型" width="120">
        <template slot-scope="scope">
          {{ scope.row.type === 'password' ? '用户名密码' : 'SSH密钥' }}
        </template>
      </el-table-column>
      <el-table-column prop="username" label="用户名" min-width="120"></el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160"></el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template slot-scope="scope">
          <el-button type="text" @click="handleView(scope.row)">查看</el-button>
          <el-button type="text" @click="handleEdit(scope.row)">编辑</el-button>
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

    <!-- 查看密码弹窗 -->
    <el-dialog title="查看密码" :visible.sync="viewDialog.visible" width="500px">
      <el-form label-width="80px">
        <el-form-item label="名称">
          <span>{{ viewDialog.data.name }}</span>
        </el-form-item>
        <el-form-item label="类型">
          <span>{{ viewDialog.data.type === 'password' ? '用户名密码' : 'SSH密钥' }}</span>
        </el-form-item>
        <el-form-item label="用户名">
          <span>{{ viewDialog.data.username }}</span>
        </el-form-item>
        <el-form-item label="密码" v-if="viewDialog.data.type === 'password'">
          <el-input v-model="viewDialog.data.password" type="password" readonly>
            <el-button slot="append" @click="togglePasswordVisible">
              <i :class="passwordVisible ? 'el-icon-view' : 'el-icon-hide'"></i>
            </el-button>
          </el-input>
        </el-form-item>
        <el-form-item label="私钥" v-else>
          <el-input
            v-model="viewDialog.data.privateKey"
            type="textarea"
            :rows="4"
            readonly
          ></el-input>
        </el-form-item>
      </el-form>
    </el-dialog>

    <!-- 编辑密码弹窗 -->
    <password-form-dialog
      :visible.sync="formDialog.visible"
      :type="formDialog.type"
      :data="formDialog.data"
      @success="handleFormSuccess"
    ></password-form-dialog>
  </div>
</template>

<script>
import { getPasswordList, deletePassword, batchDeletePassword } from '@/api/password'
import PasswordFormDialog from './components/PasswordFormDialog.vue'

export default {
  name: 'PasswordList',
  components: {
    PasswordFormDialog
  },
  data() {
    return {
      loading: false,
      searchForm: {
        name: '',
        type: ''
      },
      tableData: [],
      selectedIds: [],
      page: {
        current: 1,
        size: 10,
        total: 0
      },
      viewDialog: {
        visible: false,
        data: {}
      },
      formDialog: {
        visible: false,
        type: 'add',
        data: null
      },
      passwordVisible: false
    }
  },
  created() {
    this.getList()
  },
  methods: {
    async getList() {
      this.loading = true
      try {
        const { data } = await getPasswordList({
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
    handleView(row) {
      this.viewDialog.data = { ...row }
      this.viewDialog.visible = true
    },
    handleEdit(row) {
      this.formDialog.type = 'edit'
      this.formDialog.data = { ...row }
      this.formDialog.visible = true
    },
    async handleDelete(row) {
      try {
        await this.$confirm('确认删除该密码?', '提示', {
          type: 'warning'
        })
        await deletePassword(row.id)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleBatchDelete() {
      try {
        await this.$confirm(`确认删除选中的 ${this.selectedIds.length} 条数据?`, '提示', {
          type: 'warning'
        })
        await batchDeletePassword(this.selectedIds)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
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
    },
    togglePasswordVisible() {
      this.passwordVisible = !this.passwordVisible
    }
  }
}
</script>

<style lang="scss" scoped>
.danger {
  color: $--color-danger;
}
</style> 