<template>
  <div class="page-container">
    <div class="search-form">
      <el-form :inline="true" :model="searchForm" ref="searchForm">
        <el-form-item label="脚本名称">
          <el-input v-model="searchForm.name" placeholder="请输入脚本名称" clearable></el-input>
        </el-form-item>
        <el-form-item label="脚本类型">
          <el-select v-model="searchForm.type" placeholder="请选择脚本类型" clearable>
            <el-option label="Shell" value="shell"></el-option>
            <el-option label="Python" value="python"></el-option>
            <el-option label="Node.js" value="nodejs"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="operation-group">
      <el-button type="primary" @click="handleAdd">新增脚本</el-button>
      <el-button type="danger" :disabled="!selectedIds.length" @click="handleBatchDelete">批量删除</el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="tableData"
      @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55"></el-table-column>
      <el-table-column prop="name" label="脚本名称" min-width="120"></el-table-column>
      <el-table-column prop="type" label="脚本类型" width="100">
        <template slot-scope="scope">
          {{ getScriptType(scope.row.type) }}
        </template>
      </el-table-column>
      <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip></el-table-column>
      <el-table-column prop="params" label="参数" min-width="150" show-overflow-tooltip>
        <template slot-scope="scope">
          {{ scope.row.params ? scope.row.params.join(', ') : '-' }}
        </template>
      </el-table-column>
      <el-table-column prop="creator" label="创建人" width="120"></el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160"></el-table-column>
      <el-table-column label="操作" width="250" fixed="right">
        <template slot-scope="scope">
          <el-button type="text" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="text" @click="handleTest(scope.row)">测试</el-button>
          <el-button type="text" @click="handleCopy(scope.row)">复制</el-button>
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

    <!-- 脚本表单弹窗 -->
    <script-form-dialog
      :visible.sync="formDialog.visible"
      :type="formDialog.type"
      :data="formDialog.data"
      @success="handleFormSuccess"
    ></script-form-dialog>

    <!-- 脚本测试弹窗 -->
    <script-test-dialog
      :visible.sync="testDialog.visible"
      :data="testDialog.data"
    ></script-test-dialog>
  </div>
</template>

<script>
import { 
  getScriptList, 
  deleteScript, 
  batchDeleteScript,
  copyScript 
} from '@/api/script'
import ScriptFormDialog from './components/ScriptFormDialog.vue'
import ScriptTestDialog from './components/ScriptTestDialog.vue'

export default {
  name: 'Script',
  components: {
    ScriptFormDialog,
    ScriptTestDialog
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
      formDialog: {
        visible: false,
        type: 'add',
        data: null
      },
      testDialog: {
        visible: false,
        data: null
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getScriptType(type) {
      const map = {
        shell: 'Shell',
        python: 'Python',
        nodejs: 'Node.js'
      }
      return map[type] || type
    },
    async getList() {
      this.loading = true
      try {
        const { data } = await getScriptList({
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
        await this.$confirm('确认删除该脚本?', '提示', {
          type: 'warning'
        })
        await deleteScript(row.id)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    async handleBatchDelete() {
      try {
        await this.$confirm(`确认删除选中的 ${this.selectedIds.length} 个脚本?`, '提示', {
          type: 'warning'
        })
        await batchDeleteScript(this.selectedIds)
        this.$message.success('删除成功')
        this.getList()
      } catch (error) {
        console.error(error)
      }
    },
    handleTest(row) {
      this.testDialog.data = row
      this.testDialog.visible = true
    },
    async handleCopy(row) {
      try {
        await copyScript(row.id)
        this.$message.success('复制成功')
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
    }
  }
}
</script>

<style lang="scss" scoped>
.danger {
  color: $--color-danger;
}
</style> 