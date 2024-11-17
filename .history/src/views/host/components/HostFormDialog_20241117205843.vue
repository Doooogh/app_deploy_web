<template>
  <el-dialog
    :title="type === 'add' ? '新增主机' : '编辑主机'"
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
      <el-form-item label="主机名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入主机名称"></el-input>
      </el-form-item>
      <el-form-item label="所属环境" prop="envId">
        <el-select v-model="form.envId" placeholder="请选择环境">
          <el-option
            v-for="item in envOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          ></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="IP地址" prop="ip">
        <el-input v-model="form.ip" placeholder="请输入IP地址"></el-input>
      </el-form-item>
      <el-form-item label="SSH端口" prop="port">
        <el-input-number v-model="form.port" :min="1" :max="65535"></el-input-number>
      </el-form-item>
      <el-form-item label="用户名" prop="username">
        <el-input v-model="form.username" placeholder="请输入用户名"></el-input>
      </el-form-item>
      <el-form-item label="认证方式" prop="authType">
        <el-radio-group v-model="form.authType">
          <el-radio label="password">密码</el-radio>
          <el-radio label="key">密钥</el-radio>
        </el-radio-group>
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
            :disabled="item.type !== form.authType"
          ></el-option>
        </el-select>
        <div class="form-tip">
          <el-link type="primary" @click="handleAddAuth">新增认证信息</el-link>
        </div>
      </el-form-item>
      <el-form-item label="备注" prop="remark">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="3"
          placeholder="请输��备注"
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
import { addHost, updateHost } from '@/api/host'
import { getPasswordList } from '@/api/password'
import PasswordFormDialog from '@/views/password/components/PasswordFormDialog.vue'

export default {
  name: 'HostFormDialog',
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
    },
    envOptions: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      dialogVisible: false,
      loading: false,
      submitting: false,
      form: {
        name: '',
        envId: '',
        ip: '',
        port: 22,
        username: '',
        authType: 'password',
        authId: '',
        remark: ''
      },
      rules: {
        name: [
          { required: true, message: '请输入主机名称', trigger: 'blur' },
          { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
        ],
        envId: [
          { required: true, message: '请选择环境', trigger: 'change' }
        ],
        ip: [
          { required: true, message: '请输入IP地址', trigger: 'blur' },
          { pattern: /^(\d{1,3}\.){3}\d{1,3}$/, message: 'IP地址格式不正确', trigger: 'blur' }
        ],
        port: [
          { required: true, message: '请输入SSH端口', trigger: 'blur' }
        ],
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ],
        authType: [
          { required: true, message: '请选择认证方式', trigger: 'change' }
        ],
        authId: [
          { required: true, message: '请选择认证信息', trigger: 'change' }
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
        envId: '',
        ip: '',
        port: 22,
        username: '',
        authType: 'password',
        authId: '',
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
          await addHost(this.form)
          this.$message.success('添加成功')
        } else {
          await updateHost(this.form)
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
  margin-top: 5px;
}
</style> 