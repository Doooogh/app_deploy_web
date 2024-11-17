<template>
  <el-dialog
    title="新增版本"
    :visible.sync="dialogVisible"
    width="600px"
    @close="handleClose"
  >
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="100px"
      v-loading="loading"
    >
      <el-form-item label="版本号" prop="version">
        <el-input v-model="form.version" placeholder="请输入版本号"></el-input>
        <div class="form-tip">建议使用语义化版本号，如：1.0.0</div>
      </el-form-item>
      <el-form-item label="分支/标签" prop="branch">
        <el-select 
          v-model="form.branch"
          placeholder="请选择分支/标签"
          filterable
          :loading="branchLoading"
        >
          <el-option
            v-for="item in branchOptions"
            :key="item.name"
            :label="item.name"
            :value="item.name"
          >
            <span>{{ item.name }}</span>
            <span class="branch-commit">{{ item.commit }}</span>
          </el-option>
        </el-select>
        <div class="form-tip">
          <el-link type="primary" @click="handleRefreshBranch">刷新列表</el-link>
        </div>
      </el-form-item>
      <el-form-item label="备注" prop="remark">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="3"
          placeholder="请输入备注"
        ></el-input>
      </el-form-item>
      <el-form-item label="自动构建">
        <el-switch v-model="form.autoBuild"></el-switch>
      </el-form-item>
    </el-form>
    <div slot="footer">
      <el-button @click="dialogVisible = false">取 消</el-button>
      <el-button type="primary" @click="handleSubmit" :loading="submitting">
        确 定
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
import { addVersion, getBranchList } from '@/api/project'

export default {
  name: 'VersionFormDialog',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    projectId: {
      type: [String, Number],
      required: true
    }
  },
  data() {
    const validateVersion = (rule, value, callback) => {
      if (!/^\d+\.\d+\.\d+(?:-[a-zA-Z0-9]+)?$/.test(value)) {
        callback(new Error('版本号格式不正确'))
      } else {
        callback()
      }
    }
    return {
      dialogVisible: false,
      loading: false,
      submitting: false,
      branchLoading: false,
      form: {
        version: '',
        branch: '',
        remark: '',
        autoBuild: true
      },
      rules: {
        version: [
          { required: true, message: '请输入版本号', trigger: 'blur' },
          { validator: validateVersion, trigger: 'blur' }
        ],
        branch: [
          { required: true, message: '请选择分支/标签', trigger: 'change' }
        ]
      },
      branchOptions: []
    }
  },
  watch: {
    visible(val) {
      this.dialogVisible = val
      if (val) {
        this.getBranchList()
      }
    },
    dialogVisible(val) {
      this.$emit('update:visible', val)
    }
  },
  methods: {
    async getBranchList() {
      this.branchLoading = true
      try {
        const { data } = await getBranchList(this.projectId)
        this.branchOptions = data
      } catch (error) {
        console.error(error)
      }
      this.branchLoading = false
    },
    handleRefreshBranch() {
      this.getBranchList()
    },
    resetForm() {
      this.form = {
        version: '',
        branch: '',
        remark: '',
        autoBuild: true
      }
    },
    async handleSubmit() {
      try {
        await this.$refs.form.validate()
        this.submitting = true
        
        await addVersion({
          ...this.form,
          projectId: this.projectId
        })
        this.$message.success('添加成功')
        this.$emit('success')
      } catch (error) {
        console.error(error)
      }
      this.submitting = false
    },
    handleClose() {
      this.$refs.form.resetFields()
    }
  }
}
</script>

<style lang="scss" scoped>
.form-tip {
  font-size: 12px;
  color: #909399;
  line-height: 1.2;
  padding-top: 4px;
}

.branch-commit {
  float: right;
  color: #909399;
  font-size: 12px;
}
</style> 