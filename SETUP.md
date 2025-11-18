# DeepSeek Local RAG Agent 安装指南

本文档将指导你如何使用 Poetry 和 Docker 部署 DeepSeek Local RAG Agent。

## 环境要求

- Docker 和 Docker Compose
- GPU（推荐，但不是必需）
- Python 3.8+（如果要在本地运行）

## 安装步骤

### 使用 Docker Compose（推荐）

1. **启动服务**

   ```bash
   docker-compose up -d
   ```

   这将启动三个服务：
   - Ollama（LLM服务）
   - Qdrant（向量数据库）
   - 应用程序（Streamlit界面）

2. **拉取必要的模型**

   服务启动后，运行以下脚本拉取所需模型：

   ```bash
   ./setup_models.sh
   ```

   这将下载：
   - deepseek-r1:1.5b（轻量级模型）
   - snowflake-arctic-embed（嵌入模型）
   - 可选：deepseek-r1:7b（更大更强的模型）

3. **访问应用**

   打开浏览器，访问 http://localhost:8501

### 仅本地使用 Poetry 安装（可选）

如果您希望在本地运行，而不使用Docker：

1. **安装Poetry**

   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

2. **安装依赖**

   ```bash
   cd /path/to/deepseek_local_rag_agent
   poetry install
   ```

3. **确保Ollama和Qdrant服务可用**

   您需要设置Ollama和Qdrant服务。可以通过Docker单独运行它们：

   ```bash
   docker run -d -p 11434:11434 ollama/ollama:latest
   docker run -d -p 6333:6333 -p 6334:6334 qdrant/qdrant:latest
   ```

4. **拉取模型**

   ```bash
   ./setup_models.sh
   ```

5. **启动应用**

   ```bash
   poetry run streamlit run deepseek_rag_agent.py
   ```

## 配置

### Qdrant

- 在Streamlit界面中，您需要设置以下信息：
  - Qdrant URL: http://localhost:6333 (如果使用Docker Compose，可设为http://qdrant:6333)
  - Qdrant API Key: (如果您的Qdrant服务需要API密钥)

### 网络搜索（可选）

如果要启用网络搜索功能，您需要：
- 在Exa AI注册账号并获取API密钥
- 在Streamlit界面中启用"Enable Web Search Fallback"
- 输入您的Exa API密钥

## 使用说明

1. 在Streamlit界面中，您可以：
   - 上传PDF文档
   - 添加网页URL
   - 选择模型大小（1.5b或7b）
   - 切换RAG模式/普通模式
   - 调整文档相似度阈值
   - 启用/禁用网络搜索

2. 上传文档后，您可以通过聊天界面询问与文档相关的问题。

3. 如果找不到相关文档，系统可以选择性地回退到网络搜索或直接使用模型回答。 