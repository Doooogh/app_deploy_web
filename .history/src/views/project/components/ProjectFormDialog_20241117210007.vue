<template>
  <el-dialog
    :title="type === 'add' ? '新增项目' : '编辑项目'"
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
      <el-form-item label="项目名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入项目名称"></el-input>
      </el-form-item>
      <el-form-item label="仓库类型" prop="repoType">
        <el-radio-group v-model="form.repoType">
          <el-radio label="git">Git</el-radio>
          <el-radio label="svn">SVN</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="仓库地址" prop="repoUrl">
        <el-input v-model="form.repoUrl" placeholder="请输入仓库地址"></el-input>
      </el-form-item>
      <el-form-item label="认证信息" prop="authId">
        <el-select 
          v-model="form.authId" 
          placeholder="请选择认证信息"
          filterable
        >
          <el-option
            v-for="item in authOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          ></el-option>
        </el-select>
        <div class="form-tip">
          <el-link type="primary" @click="handleAddAuth">新增认证信息</el-link>
        </div>
      </el-form-item>
      <el-form-item label="默认分支" prop="branch">
        <el-input v-model="form.branch" placeholder="请输入默认分支">
          <template slot="prepend">{{ form.repoType === 'git' ? 'refs/heads/' : 'trunk/' }}</template>
        </el-input>
        <div class="form-tip">Git项目填写分支名称，SVN项目填写标签路径</div>
      </el-form-item>
      <el-form-item label="构建命令" prop="buildCommand">
        <el-input
          v-model="form.buildCommand"
          type="textarea"
          :rows="3"
          placeholder="请输入构建命令"
        ></el-input>
        <div class="form-tip">多条命令使用换行分隔</div>
      </el-form-item>
      <el-form-item label="制品目录" prop="artifactPath">
        <el-input v-model="form.artifactPath" placeholder="请输入制品目录">
          <template slot="prepend">/</template>
        </el-input>
        <div class="form-tip">构建产物的目录，相对于项目根目录</div>
      </el-form-item>
      <el-form-item label="排除文件" prop="excludes">
        <el-input
          v-model="form.excludes"
          type="textarea"
          :rows="3"
          placeholder="请输入要排除的文件"
        ></el-input>
        <div class="form-tip">使用.gitignore语法，每行一个规则</div>
      </el-form-item>
      <el-form-item label="备注" prop="remark">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="3"
          placeholder="请输入备注"
        ></el-input>
      </el-form-item>
    </el-form>
    <div slot="footer">
      <el-button @click="dialogVisible = false">取 消</el-button>
      <el-button type="primary" @click="handleSubmit" :loading="submitting">
        确 定
      </el-button>
    </div>

    <!-- 新增认证信息弹窗 -->
    <password-form-dialog
      :visible.sync="passwordDialog.visible"
      type="add"
      @success="handleAuthSuccess"
    ></password-form-dialog>
  </el-dialog>
</template>

<script>
import { addProject, updateProject } from '@/api/project'
import { getPasswordList } from '@/api/password'
import PasswordFormDialog from '@/views/password/components/PasswordFormDialog.vue'

export default {
  name: 'ProjectFormDialog',
  components: {
    PasswordFormDialog
  },
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    type: {
      type: String,
      default: 'add'
    },
    data: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      dialogVisible: false,
      loading: false,
      submitting: false,
      form: {
        name: '',
        repoType: 'git',
        repoUrl: '',
        authId: '',
        branch: '',
        buildCommand: '',
        artifactPath: '',
        excludes: '',
        remark: ''
      },
      rules: {
        name: [
          { required: true, message: '请输入项目名称', trigger: 'blur' },
          { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
        ],
        repoType: [
          { required: true, message: '请选择仓库类型', trigger: 'change' }
        ],
        repoUrl: [
          { required: true, message: '请输入仓库地址', trigger: 'blur' }
        ],
        authId: [
          { required: true, message: '请选择认证信息', trigger: 'change' }
        ],
        branch: [
          { required: true, message: '请输入默认分支', trigger: 'blur' }
        ],
        buildCommand: [
          { required: true, message: '请输入构建命令', trigger: 'blur' }
        ],
        artifactPath: [
          { required: true, message: '请输入制品目录', trigger: 'blur' }
        ]
      },
      authOptions: [],
      passwordDialog: {
        visible: false
      }
    }
  },
  watch: {
    visible(val) {
      this.dialogVisible = val
      if (val) {
        this.getAuthList()
      }
    },
    dialogVisible(val) {
      this.$emit('update:visible', val)
    },
    data: {
      handler(val) {
        if (val) {
          this.form = { ...val }
        } else {
          this.resetForm()
        }
      },
      immediate: true
    }
  },
  methods: {
    async getAuthList() {
      try {
        const { data } = await getPasswordList()
        this.authOptions = data.list
      } catch (error) {
        console.error(error)
      }
    },
    resetForm() {
      this.form = {
        name: '',
        repoType: 'git',
        repoUrl: '',
        authId: '',
        branch: '',
        buildCommand: '',
        artifactPath: '',
        excludes: '',
        remark: ''
      }
    },
    handleAddAuth() {
      this.passwordDialog.visible = true
    },
    async handleAuthSuccess() {
      this.passwordDialog.visible = false
      await this.getAuthList()
      this.$message.success('添加成功')
    },
    async handleSubmit() {
      try {
        await this.$refs.form.validate()
        this.submitting = true
        
        if (this.type === 'add') {
          await addProject(this.form)
          this.$message.success('添加成功')
        } else {
          await updateProject(this.form)
          this.$message.success('更新成功')
        }
        
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
</style> 