<template>
  <el-dialog
    :title="type === 'add' ? '新增环境' : '编辑环境'"
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
      <el-form-item label="环境名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入环境名称"></el-input>
      </el-form-item>
      <el-form-item label="环境标识" prop="code">
        <el-input 
          v-model="form.code" 
          placeholder="请输入环境标识"
          :disabled="type === 'edit'"
        ></el-input>
        <div class="form-tip">环境标识一旦创建不可修改，将用于系统内部标识环境</div>
      </el-form-item>
      <el-form-item label="描述" prop="description">
        <el-input
          v-model="form.description"
          type="textarea"
          :rows="3"
          placeholder="请输入环境描述"
        ></el-input>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-radio-group v-model="form.status">
          <el-radio :label="1">启用</el-radio>
          <el-radio :label="0">禁用</el-radio>
        </el-radio-group>
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
import { addEnvironment, updateEnvironment } from '@/api/environment'

export default {
  name: 'EnvironmentFormDialog',
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
    const validateCode = (rule, value, callback) => {
      if (!/^[a-z][a-z0-9_]*$/.test(value)) {
        callback(new Error('环境标识只能包含小写字母、数字和下划线，且必须以字母开头'))
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
        code: '',
        description: '',
        status: 1
      },
      rules: {
        name: [
          { required: true, message: '请输入环境名称', trigger: 'blur' },
          { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
        ],
        code: [
          { required: true, message: '请输入环境标识', trigger: 'blur' },
          { validator: validateCode, trigger: 'blur' }
        ],
        description: [
          { max: 200, message: '长度不能超过 200 个字符', trigger: 'blur' }
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
        code: '',
        description: '',
        status: 1
      }
    },
    async handleSubmit() {
      try {
        await this.$refs.form.validate()
        this.submitting = true
        
        if (this.type === 'add') {
          await addEnvironment(this.form)
          this.$message.success('添加成功')
        } else {
          await updateEnvironment(this.form)
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