#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}正在启动 DeepSeek Local RAG Agent...${NC}"

# 检查是否使用Docker
read -p "是否使用Docker部署? [Y/n]: " use_docker
use_docker=${use_docker:-Y}

if [[ $use_docker =~ ^[Yy]$ ]]; then
    # 使用Docker
    echo -e "${BLUE}正在启动Docker服务...${NC}"
    docker-compose up -d
    
    echo -e "${BLUE}等待服务启动...${NC}"
    sleep 5
    
    echo -e "${BLUE}下载必要的模型...${NC}"
    ./setup_models.sh
    
    echo -e "${GREEN}服务已启动! 请访问 http://localhost:8501 使用RAG Agent${NC}"
    
    # 显示日志选项
    read -p "是否查看日志? [y/N]: " view_logs
    if [[ $view_logs =~ ^[Yy]$ ]]; then
        docker-compose logs -f
    fi
else
    # 本地安装
    if ! command -v poetry &> /dev/null; then
        echo -e "${BLUE}未检测到Poetry，正在安装...${NC}"
        curl -sSL https://install.python-poetry.org | python3 -
    fi
    
    echo -e "${BLUE}安装依赖...${NC}"
    poetry install
    
    # 检查Ollama和Qdrant是否运行
    echo -e "${BLUE}检查Ollama服务...${NC}"
    if ! curl -s localhost:11434/api/tags &> /dev/null; then
        echo -e "${BLUE}Ollama服务未运行，正在启动...${NC}"
        docker run -d -p 11434:11434 ollama/ollama:latest
        
        echo -e "${BLUE}等待Ollama服务启动...${NC}"
        until curl -s localhost:11434/api/tags &> /dev/null; do
            sleep 2
        done
    fi
    
    echo -e "${BLUE}检查Qdrant服务...${NC}"
    if ! curl -s localhost:6333/collections &> /dev/null; then
        echo -e "${BLUE}Qdrant服务未运行，正在启动...${NC}"
        docker run -d -p 6333:6333 -p 6334:6334 qdrant/qdrant:latest
    fi
    
    echo -e "${BLUE}下载必要的模型...${NC}"
    ./setup_models.sh
    
    echo -e "${GREEN}启动应用...${NC}"
    poetry run streamlit run deepseek_rag_agent.py
fi 