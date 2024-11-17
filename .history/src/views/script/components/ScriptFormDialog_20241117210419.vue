<template>
  <el-dialog
    :title="type === 'add' ? '新增脚本' : '编辑脚本'"
    :visible.sync="dialogVisible"
    width="800px"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="100px"
      v-loading="loading"
    >
      <el-form-item label="脚本名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入脚本名称"></el-input>
      </el-form-item>
      <el-form-item label="脚本类型" prop="type">
        <el-select v-model="form.type" placeholder="请选择脚本类型">
          <el-option label="Shell" value="shell"></el-option>
          <el-option label="Python" value="python"></el-option>
          <el-option label="Node.js" value="nodejs"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="脚本内容" prop="content">
        <monaco-editor
          v-model="form.content"
          :language="getEditorLanguage"
          :height="400"
          theme="vs-dark"
        ></monaco-editor>
      </el-form-item>
      <el-form-item label="参数配置">
        <div class="param-list">
          <div 
            v-for="(param, index) in form.params" 
            :key="index" 
            class="param-item"
          >
            <el-input v-model="form.params[index]" placeholder="请输入参数名称">
              <template slot="prepend">${{ index + 1 }}</template>
              <el-button 
                slot="append" 
                icon="el-icon-delete"
                @click="handleDeleteParam(index)"
              ></el-button>
            </el-input>
          </div>
          <el-button 
            type="dashed" 
            class="add-param" 
            @click="handleAddParam"
          >
            <i class="el-icon-plus"></i>
            添加参数
          </el-button>
        </div>
        <div class="form-tip">参数使用${1}、${2}的形式在脚本中引用</div>
      </el-form-item>
      <el-form-item label="描述" prop="description">
        <el-input
          v-model="form.description"
          type="textarea"
          :rows="3"
          placeholder="请输入描述"
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
import { addScript, updateScript } from '@/api/script'
import MonacoEditor from '@/components/MonacoEditor'

export default {
  name: 'ScriptFormDialog',
  components: {
    MonacoEditor
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
        type: 'shell',
        content: '',
        params: [],
        description: ''
      },
      rules: {
        name: [
          { required: true, message: '请输入脚本名称', trigger: 'blur' },
          { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
        ],
        type: [
          { required: true, message: '请选择脚本类型', trigger: 'change' }
        ],
        content: [
          { required: true, message: '请输入脚本内容', trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    getEditorLanguage() {
      const map = {
        shell: 'shell',
        python: 'python',
        nodejs: 'javascript'
      }
      return map[this.form.type] || 'plaintext'
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
        type: 'shell',
        content: '',
        params: [],
        description: ''
      }
    },
    handleAddParam() {
      this.form.params.push('')
    },
    handleDeleteParam(index) {
      this.form.params.splice(index, 1)
    },
    async handleSubmit() {
      try {
        await this.$refs.form.validate()
        this.submitting = true
        
        // 过滤空参数
        this.form.params = this.form.params.filter(item => item)
        
        if (this.type === 'add') {
          await addScript(this.form)
          this.$message.success('添加成功')
        } else {
          await updateScript(this.form)
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
.param-list {
  .param-item {
    margin-bottom: 10px;
  }
}

.add-param {
  width: 100%;
  border-style: dashed;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  line-height: 1.2;
  padding-top: 4px;
}
</style> 