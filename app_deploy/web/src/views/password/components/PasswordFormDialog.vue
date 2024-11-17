<template>
  <el-dialog
    :title="type === 'add' ? '新增密码' : '编辑密码'"
    :visible.sync="dialogVisible"
    width="500px"
    @close="handleClose"
  >
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="80px"
      v-loading="loading"
    >
      <el-form-item label="名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入名称"></el-input>
      </el-form-item>
      <el-form-item label="类型" prop="type">
        <el-select v-model="form.type" placeholder="请选择类型" @change="handleTypeChange">
          <el-option label="用户名密码" value="password"></el-option>
          <el-option label="SSH密钥" value="ssh"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="用户名" prop="username">
        <el-input v-model="form.username" placeholder="请输入用户名"></el-input>
      </el-form-item>
      <template v-if="form.type === 'password'">
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            show-password
          ></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            v-model="form.confirmPassword"
            type="password"
            placeholder="请再次输入密码"
            show-password
          ></el-input>
        </el-form-item>
      </template>
      <template v-else>
        <el-form-item label="私钥" prop="privateKey">
          <el-input
            v-model="form.privateKey"
            type="textarea"
            :rows="4"
            placeholder="请输入私钥"
          ></el-input>
        </el-form-item>
        <el-form-item label="公钥" prop="publicKey">
          <el-input
            v-model="form.publicKey"
            type="textarea"
            :rows="4"
            placeholder="请输入公钥"
          ></el-input>
        </el-form-item>
      </template>
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
  </el-dialog>
</template>

<script>
import { addPassword, updatePassword } from '@/api/password'

export default {
  name: 'PasswordFormDialog',
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
    const validateConfirmPassword = (rule, value, callback) => {
      if (value !== this.form.password) {
        callback(new Error('两次输入密码不一致'))
      } else {
        callback()
      }
    }
    return {
      dialogVisible: false,
      loading: false,
      submitting: false,
      form: {
        name: '',
        type: 'password',
        username: '',
        password: '',
        confirmPassword: '',
        privateKey: '',
        publicKey: '',
        remark: ''
      },
      rules: {
        name: [
          { required: true, message: '请输入名称', trigger: 'blur' },
          { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
        ],
        type: [
          { required: true, message: '请选择类型', trigger: 'change' }
        ],
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请再次输入密码', trigger: 'blur' },
          { validator: validateConfirmPassword, trigger: 'blur' }
        ],
        privateKey: [
          { required: true, message: '请输入私钥', trigger: 'blur' }
        ],
        publicKey: [
          { required: true, message: '请输入公钥', trigger: 'blur' }
        ]
      }
    }
  },
  watch: {
    visible(val) {
      this.dialogVisible = val
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
    resetForm() {
      this.form = {
        name: '',
        type: 'password',
        username: '',
        password: '',
        confirmPassword: '',
        privateKey: '',
        publicKey: '',
        remark: ''
      }
    },
    handleTypeChange() {
      this.$refs.form.clearValidate()
    },
    async handleSubmit() {
      try {
        await this.$refs.form.validate()
        this.submitting = true
        
        const params = { ...this.form }
        delete params.confirmPassword
        
        if (this.type === 'add') {
          await addPassword(params)
          this.$message.success('添加成功')
        } else {
          await updatePassword(params)
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