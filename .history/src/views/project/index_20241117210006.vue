<template>
  <div class="page-container">
    <div class="search-form">
      <el-form :inline="true" :model="searchForm" ref="searchForm">
        <el-form-item label="项目名称">
          <el-input v-model="searchForm.name" placeholder="请输入项目名称" clearable></el-input>
        </el-form-item>
        <el-form-item label="仓库类型">
          <el-select v-model="searchForm.repoType" placeholder="请选择仓库类型" clearable>
            <el-option label="Git" value="git"></el-option>
            <el-option label="SVN" value="svn"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="operation-group">
      <el-button type="primary" @click="handleAdd">新增项目</el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="tableData"
    >
      <el-table-column prop="name" label="项目名称" min-width="120"></el-table-column>
      <el-table-column prop="repoType" label="仓库类型" width="100">
        <template slot-scope="scope">
          {{ scope.row.repoType === 'git' ? 'Git' : 'SVN' }}
        </template>
      </el-table-column>
      <el-table-column prop="repoUrl" label="仓库地址" min-width="200" show-overflow-tooltip></el-table-column>
      <el-table-column prop="branch" label="分支/标签" width="120"></el-table-column>
      <el-table-column prop="versionCount" label="版本数量" width="100" align="center"></el-table-column>
      <el-table-column prop="deployCount" label="部署次数" width="100" align="center"></el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160"></el-table-column>
      <el-table-column label="操作" width="280" fixed="right">
        <template slot-scope="scope">
          <el-button type="text" @click="handleVersion(scope.row)">版本管理</el-button>
          <el-button type="text" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="text" @click="handleDeploy(scope.row)">发布</el-button>
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

    <!-- 项目表单弹窗 -->
    <project-form-dialog
      :visible.sync="formDialog.visible"
      :type="formDialog.type"
      :data="formDialog.data"
      @success="handleFormSuccess"
    ></project-form-dialog>
  </div>
</template>

<script>
import { getProjectList, deleteProject } from '@/api/project'
import ProjectFormDialog from './components/ProjectFormDialog.vue'

export default {
  name: 'Project',
  components: {
    ProjectFormDialog
  },
  data() {
    return {
      loading: false,
      searchForm: {
        name: '',
        repoType: ''
      },
      tableData: [],
      page: {
        current: 1,
        size: 10,
        total: 0
      },
      formDialog: {
        visible: false,
        type: 'add',
        data: null
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    async getList() {
      this.loading = true
      try {
        const { data } = await getProjectList({
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
        await this.$confirm('确认删除该项目?', '提示', {
          type: 'warning'
        })
        await deleteProject(row.id)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    handleVersion(row) {
      this.$router.push(`/project/version/${row.id}`)
    },
    handleDeploy(row) {
      this.$router.push({
        path: '/deploy/create',
        query: {
          projectId: row.id
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
.danger {
  color: $--color-danger;
}
</style> 