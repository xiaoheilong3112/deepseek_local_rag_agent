#!/bin/bash

# 设置重试次数和超时时间
MAX_RETRIES=5
TIMEOUT=300

# 确保 Ollama 服务已启动
echo "等待 Ollama 服务启动..."
attempt=0
while true; do
  if curl -s -f -m 10 http://localhost:11434/api/tags >/dev/null 2>&1; then
    break
  fi
  
  attempt=$((attempt+1))
  if [ $attempt -ge $MAX_RETRIES ]; then
    echo "无法连接到 Ollama 服务，请检查是否已启动"
    exit 1
  fi
  
  echo "等待 Ollama 服务... (尝试 $attempt/$MAX_RETRIES)"
  sleep 5
done

echo "Ollama 服务已启动，开始拉取模型..."

# 带重试功能的拉取模型函数
pull_model() {
  local model_name=$1
  local attempt=0
  
  echo "拉取 ${model_name} 模型..."
  
  while [ $attempt -lt $MAX_RETRIES ]; do
    if curl -X POST -s -m $TIMEOUT http://localhost:11434/api/pull -d "{\"name\": \"${model_name}\"}" > /dev/null; then
      echo "✅ ${model_name} 模型拉取成功！"
      return 0
    fi
    
    attempt=$((attempt+1))
    echo "❌ 拉取失败，正在重试... (尝试 $attempt/$MAX_RETRIES)"
    sleep 3
  done
  
  echo "❌ 无法拉取 ${model_name} 模型，请稍后手动拉取"
  return 1
}

# 拉取必要的模型
pull_model "deepseek-r1:1.5b"
pull_model "snowflake-arctic-embed"

# 可选：拉取完整版本的模型
read -p "是否要拉取 DeepSeek 7b 模型？(需要更多磁盘空间和内存) [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  pull_model "deepseek-r1:7b"
fi

echo "模型设置完成！" 