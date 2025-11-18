#!/bin/bash
set -e

# 启动模式，默认为 jupyter
MODE=${APP_MODE:-jupyter}

case "$MODE" in
  jupyter)
    echo "以 Jupyter Lab 模式启动..."
    exec jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser --NotebookApp.token=${JUPYTER_TOKEN}
    ;;
  streamlit)
    echo "以 Streamlit 模式启动..."
    exec streamlit run deepseek_rag_agent.py --server.address=0.0.0.0
    ;;
  bash)
    echo "启动 Bash 会话..."
    exec bash
    ;;
  *)
    echo "未知的启动模式: $MODE"
    echo "请使用: jupyter, streamlit 或 bash"
    exit 1
    ;;
esac 