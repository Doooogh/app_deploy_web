<template>
  <el-dialog
    :title="`脚本测试 - ${data ? data.name : ''}`"
    :visible.sync="dialogVisible"
    width="800px"
    :close-on-click-modal="false"
    custom-class="script-test-dialog"
  >
    <div v-if="data" v-loading="loading">
      <el-form ref="form" :model="form" label-width="100px">
        <el-form-item 
          v-for="(param, index) in data.params"
          :key="index"
          :label="`${param}`"
          :prop="`params.${index}`"
          :rules="{ required: true, message: '请输入参数值', trigger: 'blur' }"
        >
          <el-input v-model="form.params[index]" placeholder="请输入参数值"></el-input>
        </el-form-item>
        <el-form-item label="测试主机" prop="hostId">
          <el-select 
            v-model="form.hostId" 
            placeholder="请选择测试主机"
            filterable
          >
            <el-option
              v-for="item in hostOptions"
              :key="item.id"
              :label="`${item.name}(${item.ip})`"
              :value="item.id"
              :disabled="item.status !== 1"
            ></el-option>
          </el-select>
        </el-form-item>
      </el-form>

      <div class="log-content" v-show="logVisible">
        <div class="log-header">
          <span>执行日志</span>
          <el-button type="text" @click="handleClearLog">清空日志</el-button>
        </div>
        <pre ref="logContent" class="log-body" v-html="logContent"></pre>
      </div>
    </div>
    <div slot="footer">
      <el-button @click="dialogVisible = false">关 闭</el-button>
      <el-button type="primary" @click="handleTest" :loading="testing">
        开始测试
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
import { getHostList } from '@/api/host'
import { testScript } from '@/api/script'

export default {
  name: 'ScriptTestDialog',
  props: {
    visible: {
      type: Boolean,
      default: false
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
      testing: false,
      form: {
        params: [],
        hostId: ''
      },
      hostOptions: [],
      logVisible: false,
      logContent: ''
    }
  },
  watch: {
    visible(val) {
      this.dialogVisible = val
      if (val && this.data) {
        this.getHostList()
        this.resetForm()
      }
    },
    dialogVisible(val) {
      this.$emit('update:visible', val)
      if (!val) {
        this.logVisible = false
        this.logContent = ''
      }
    },
    logContent() {
      this.$nextTick(() => {
        if (this.$refs.logContent) {
          this.$refs.logContent.scrollTop = this.$refs.logContent.scrollHeight
        }
      })
    }
  },
  methods: {
    async getHostList() {
      this.loading = true
      try {
        const { data } = await getHostList()
        this.hostOptions = data.list
      } catch (error) {
        console.error(error)
      }
      this.loading = false
    },
    resetForm() {
      this.form = {
        params: Array(this.data.params.length).fill(''),
        hostId: ''
      }
    },
    handleClearLog() {
      this.logContent = ''
    },
    appendLog(text, type = 'info') {
      const colorMap = {
        info: '#fff',
        error: '#f56c6c',
        success: '#67c23a'
      }
      this.logContent += `<span style="color: ${colorMap[type]}">${text}\n</span>`
    },
    async handleTest() {
      try {
        await this.$refs.form.validate()
        this.testing = true
        this.logVisible = true
        this.logContent = ''
        
        this.appendLog('开始执行脚本...')
        
        const ws = new WebSocket(`ws://localhost:3000/api/script/test/${this.data.id}`)
        
        ws.onmessage = (event) => {
          const data = JSON.parse(event.data)
          if (data.type === 'log') {
            this.appendLog(data.content)
          } else if (data.type === 'error') {
            this.appendLog(data.content, 'error')
          } else if (data.type === 'end') {
            this.appendLog('脚本执行完成', data.success ? 'success' : 'error')
            ws.close()
          }
        }
        
        ws.onopen = () => {
          ws.send(JSON.stringify({
            hostId: this.form.hostId,
            params: this.form.params
          }))
        }
        
        ws.onerror = () => {
          this.appendLog('WebSocket连接失败', 'error')
        }
        
        ws.onclose = () => {
          this.testing = false
        }
      } catch (error) {
        console.error(error)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.script-test-dialog {
  :deep(.el-dialog__body) {
    padding-bottom: 0;
  }
}

.log-content {
  margin-top: 20px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;

  .log-header {
    padding: 8px 15px;
    border-bottom: 1px solid #dcdfe6;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: #f5f7fa;
  }

  .log-body {
    height: 300px;
    margin: 0;
    padding: 10px;
    background-color: #1e1e1e;
    color: #fff;
    font-family: Consolas, Monaco, monospace;
    overflow: auto;
    white-space: pre-wrap;
    word-wrap: break-word;
  }
}
</style> 