from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # 基础配置
    APP_NAME: str = "App Deploy"
    DEBUG: bool = True
    
    # 数据库配置
    DATABASE_URL: str = "sqlite:///./deploy.db"
    
    # JWT配置
    SECRET_KEY: str = "your-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24小时
    
    # 文件路径配置
    UPLOAD_DIR: str = "./uploads"
    LOG_DIR: str = "./logs"
    
    # Git配置
    GIT_WORK_DIR: str = "./workspace"
    
    class Config:
        env_file = ".env"

settings = Settings() 