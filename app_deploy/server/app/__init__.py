from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="App Deploy API")

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中应该设置具体的域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 导入路由
from app.api import auth, password, environment, host, project, script, deploy

# 注册路由
app.include_router(auth.router, prefix="/api", tags=["认证"])
app.include_router(password.router, prefix="/api/password", tags=["密码管理"])
app.include_router(environment.router, prefix="/api/environment", tags=["环境管理"])
app.include_router(host.router, prefix="/api/host", tags=["主机管理"])
app.include_router(project.router, prefix="/api/project", tags=["项目管理"])
app.include_router(script.router, prefix="/api/script", tags=["脚本管理"])
app.include_router(deploy.router, prefix="/api/deploy", tags=["发布管理"]) 