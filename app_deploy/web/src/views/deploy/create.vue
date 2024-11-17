<template>
  <div class="page-container">
    <el-steps :active="currentStep" finish-status="success" class="deploy-steps">
      <el-step title="选择环境"></el-step>
      <el-step title="选择主机"></el-step>
      <el-step title="配置脚本"></el-step>
      <el-step title="确认信息"></el-step>
    </el-steps>

    <div class="step-content">
      <!-- 步骤1：选择环境 -->
      <div v-show="currentStep === 0">
        <el-form ref="envForm" :model="form" label-width="100px">
          <el-form-item label="发布环境" prop="envId" :rules="{ required: true, message: '请选择环境', trigger: 'change' }">
            <el-select 
              v-model="form.envId" 
              placeholder="请选择环境"
              style="width: 300px"
              @change="handleEnvChange"
            >
              <el-option
                v-for="item in envOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
                :disabled="item.status !== 1"
              ></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="项目" prop="projectId" :rules="{ required: true, message: '请选择项目', trigger: 'change' }">
            <el-select 
              v-model="form.projectId" 
              placeholder="请选择项目"
              style="width: 300px"
              @change="handleProjectChange"
            >
              <el-option
                v-for="item in projectOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              ></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="版本" prop="versionId" :rules="{ required: true, message: '请选择版本', trigger: 'change' }">
            <el-select 
              v-model="form.versionId" 
              placeholder="请选择版本"
              style="width: 300px"
              :loading="versionLoading"
            >
              <el-option
                v-for="item in versionOptions"
                :key="item.id"
                :label="`${item.version} (${item.branch})`"
                :value="item.id"
                :disabled="item.buildStatus !== 2"
              >
                <span>{{ item.version }}</span>
                <span class="version-branch">({{ item.branch }})</span>
                <el-tag 
                  size="mini" 
                  :type="item.buildStatus === 2 ? 'success' : 'danger'"
                >{{ item.buildStatus === 2 ? '构建成功' : '构建失败' }}</el-tag>
              </el-option>
            </el-select>
          </el-form-item>
        </el-form>
      </div>

      <!-- 步骤2：选择主机 -->
      <div v-show="currentStep === 1">
        <el-transfer
          v-model="form.hostIds"
          :data="hostList"
          :titles="['可选主机', '已选主机']"
          :props="{
            key: 'id',
            label: item => `${item.name}(${item.ip})`
          }"
          :filter-method="filterHost"
          filterable
        ></el-transfer>
      </div>

      <!-- 步骤3：配置脚本 -->
      <div v-show="currentStep === 2">
        <el-form ref="scriptForm" :model="form" label-width="100px">
          <el-form-item label="部署目录" prop="deployPath" :rules="{ required: true, message: '请输入部署目录', trigger: 'blur' }">
            <el-input v-model="form.deployPath" placeholder="请输入部署目录">
              <template slot="prepend">/</template>
            </el-input>
            <div class="form-tip">部署包将解压到该目录下</div>
          </el-form-item>
          <el-form-item label="前置脚本">
            <div class="script-list">
              <draggable v-model="form.beforeScripts" handle=".drag-handle">
                <div 
                  v-for="(script, index) in form.beforeScripts" 
                  :key="index"
                  class="script-item"
                >
                  <i class="el-icon-rank drag-handle"></i>
                  <el-select 
                    v-model="script.id" 
                    placeholder="请选择脚本"
                    style="width: 200px"
                    filterable
                  >
                    <el-option
                      v-for="item in scriptOptions"
                      :key="item.id"
                      :label="item.name"
                      :value="item.id"
                    ></el-option>
                  </el-select>
                  <el-input
                    v-if="getScriptById(script.id)?.params?.length"
                    v-model="script.params"
                    placeholder="请输入参数，多个参数用空格分隔"
                    style="width: 300px; margin: 0 10px"
                  ></el-input>
                  <el-button 
                    type="text" 
                    icon="el-icon-delete"
                    @click="handleDeleteScript('before', index)"
                  ></el-button>
                </div>
              </draggable>
              <el-button 
                type="dashed" 
                class="add-script" 
                @click="handleAddScript('before')"
              >
                <i class="el-icon-plus"></i>
                添加脚本
              </el-button>
            </div>
          </el-form-item>
          <el-form-item label="后置脚本">
            <div class="script-list">
              <draggable v-model="form.afterScripts" handle=".drag-handle">
                <div 
                  v-for="(script, index) in form.afterScripts" 
                  :key="index"
                  class="script-item"
                >
                  <i class="el-icon-rank drag-handle"></i>
                  <el-select 
                    v-model="script.id" 
                    placeholder="请选择脚本"
                    style="width: 200px"
                    filterable
                  >
                    <el-option
                      v-for="item in scriptOptions"
                      :key="item.id"
                      :label="item.name"
                      :value="item.id"
                    ></el-option>
                  </el-select>
                  <el-input
                    v-if="getScriptById(script.id)?.params?.length"
                    v-model="script.params"
                    placeholder="请输入参数，多个参数用空格分隔"
                    style="width: 300px; margin: 0 10px"
                  ></el-input>
                  <el-button 
                    type="text" 
                    icon="el-icon-delete"
                    @click="handleDeleteScript('after', index)"
                  ></el-button>
                </div>
              </draggable>
              <el-button 
                type="dashed" 
                class="add-script" 
                @click="handleAddScript('after')"
              >
                <i class="el-icon-plus"></i>
                添加脚本
              </el-button>
            </div>
          </el-form-item>
        </el-form>
      </div>

      <!-- 步骤4：确认信息 -->
      <div v-show="currentStep === 3">
        <el-descriptions title="发布信息" :column="2" border>
          <el-descriptions-item label="发布环境">{{ getEnvName }}</el-descriptions-item>
          <el-descriptions-item label="项目">{{ getProjectName }}</el-descriptions-item>
          <el-descriptions-item label="版本">{{ getVersionName }}</el-descriptions-item>
          <el-descriptions-item label="部署目录">/{{ form.deployPath }}</el-descriptions-item>
        </el-descriptions>

        <el-descriptions title="部署主机" :column="1" border class="mt20">
          <el-descriptions-item :label="`已选择 ${form.hostIds.length} 台主机`">
            <el-tag 
              v-for="host in selectedHosts" 
              :key="host.id"
              class="host-tag"
            >{{ host.name }}({{ host.ip }})</el-tag>
          </el-descriptions-item>
        </el-descriptions>

        <el-descriptions title="执行脚本" :column="1" border class="mt20">
          <el-descriptions-item label="前置脚本">
            <template v-if="form.beforeScripts.length">
              <div 
                v-for="(script, index) in form.beforeScripts" 
                :key="index"
                class="script-info"
              >
                {{ index + 1 }}. {{ getScriptById(script.id)?.name }}
                <span v-if="script.params" class="script-params">
                  参数：{{ script.params }}
                </span>
              </div>
            </template>
            <span v-else>无</span>
          </el-descriptions-item>
          <el-descriptions-item label="后置脚本">
            <template v-if="form.afterScripts.length">
              <div 
                v-for="(script, index) in form.afterScripts" 
                :key="index"
                class="script-info"
              >
                {{ index + 1 }}. {{ getScriptById(script.id)?.name }}
                <span v-if="script.params" class="script-params">
                  参数：{{ script.params }}
                </span>
              </div>
            </template>
            <span v-else>无</span>
          </el-descriptions-item>
        </el-descriptions>
      </div>
    </div>

    <div class="step-footer">
      <el-button @click="handlePrev" v-if="currentStep > 0">上一步</el-button>
      <el-button 
        type="primary" 
        @click="handleNext"
        :loading="loading"
      >{{ currentStep === 3 ? '开始发布' : '下一步' }}</el-button>
    </div>
  </div>
</template>

<script>
import { getEnvironmentList } from '@/api/environment'
import { getProjectList, getVersionList } from '@/api/project'
import { getHostList } from '@/api/host'
import { getScriptList, createDeploy } from '@/api/deploy'
import draggable from 'vuedraggable'

export default {
  name: 'DeployCreate',
  components: {
    draggable
  },
  data() {
    return {
      currentStep: 0,
      loading: false,
      versionLoading: false,
      form: {
        envId: '',
        projectId: '',
        versionId: '',
        hostIds: [],
        deployPath: '',
        beforeScripts: [],
        afterScripts: []
      },
      envOptions: [],
      projectOptions: [],
      versionOptions: [],
      hostList: [],
      scriptOptions: []
    }
  },
  computed: {
    selectedHosts() {
      return this.hostList.filter(item => this.form.hostIds.includes(item.id))
    },
    getEnvName() {
      const env = this.envOptions.find(item => item.id === this.form.envId)
      return env?.name
    },
    getProjectName() {
      const project = this.projectOptions.find(item => item.id === this.form.projectId)
      return project?.name
    },
    getVersionName() {
      const version = this.versionOptions.find(item => item.id === this.form.versionId)
      return version ? `${version.version} (${version.branch})` : ''
    }
  },
  created() {
    this.getEnvList()
    this.getProjectList()
    this.getScriptList()

    // 如果URL中有projectId和versionId，自动选中
    const { projectId, versionId } = this.$route.query
    if (projectId) {
      this.form.projectId = Number(projectId)
      if (versionId) {
        this.form.versionId = Number(versionId)
      }
    }
  },
  methods: {
    async getEnvList() {
      try {
        const { data } = await getEnvironmentList()
        this.envOptions = data.filter(item => item.status === 1)
      } catch (error) {
        console.error(error)
      }
    },
    async getProjectList() {
      try {
        const { data } = await getProjectList()
        this.projectOptions = data.list
      } catch (error) {
        console.error(error)
      }
    },
    async getVersionList() {
      if (!this.form.projectId) return
      this.versionLoading = true
      try {
        const { data } = await getVersionList({
          projectId: this.form.projectId,
          buildStatus: 2
        })
        this.versionOptions = data.list
      } catch (error) {
        console.error(error)
      }
      this.versionLoading = false
    },
    async getHostList() {
      if (!this.form.envId) return
      try {
        const { data } = await getHostList({
          envId: this.form.envId,
          status: 1
        })
        this.hostList = data.list
      } catch (error) {
        console.error(error)
      }
    },
    async getScriptList() {
      try {
        const { data } = await getScriptList()
        this.scriptOptions = data.list
      } catch (error) {
        console.error(error)
      }
    },
    handleEnvChange() {
      this.form.hostIds = []
      this.getHostList()
    },
    handleProjectChange() {
      this.form.versionId = ''
      this.getVersionList()
    },
    getScriptById(id) {
      return this.scriptOptions.find(item => item.id === id)
    },
    handleAddScript(type) {
      this.form[`${type}Scripts`].push({
        id: '',
        params: ''
      })
    },
    handleDeleteScript(type, index) {
      this.form[`${type}Scripts`].splice(index, 1)
    },
    filterHost(query, item) {
      return item.name.toLowerCase().includes(query.toLowerCase()) ||
        item.ip.includes(query)
    },
    async handleNext() {
      if (this.currentStep === 0) {
        try {
          await this.$refs.envForm.validate()
          this.currentStep++
        } catch (error) {
          return
        }
      } else if (this.currentStep === 1) {
        if (!this.form.hostIds.length) {
          this.$message.warning('请选择至少一台主机')
          return
        }
        this.currentStep++
      } else if (this.currentStep === 2) {
        try {
          await this.$refs.scriptForm.validate()
          this.currentStep++
        } catch (error) {
          return
        }
      } else if (this.currentStep === 3) {
        await this.handleDeploy()
      }
    },
    handlePrev() {
      this.currentStep--
    },
    async handleDeploy() {
      try {
        this.loading = true
        await createDeploy(this.form)
        this.$message.success('发布单创建成功')
        this.$router.push('/deploy/history')
      } catch (error) {
        console.error(error)
      }
      this.loading = false
    }
  }
}
</script>

<style lang="scss" scoped>
.deploy-steps {
  margin-bottom: 30px;
}

.step-content {
  min-height: 400px;
  padding: 20px;
}

.step-footer {
  margin-top: 30px;
  text-align: center;
}

.version-branch {
  color: #909399;
  margin: 0 10px;
}

.script-list {
  .script-item {
    display: flex;
    align-items: center;
    margin-bottom: 10px;

    .drag-handle {
      cursor: move;
      margin-right: 10px;
      color: #909399;
    }
  }
}

.add-script {
  width: 100%;
  border-style: dashed;
}

.mt20 {
  margin-top: 20px;
}

.host-tag {
  margin-right: 10px;
  margin-bottom: 5px;
}

.script-info {
  line-height: 1.8;

  .script-params {
    color: #909399;
    margin-left: 10px;
  }
}

.form-tip {
  font-size: 12px;
  color: #909399;
  line-height: 1.2;
  padding-top: 4px;
}
</style> 