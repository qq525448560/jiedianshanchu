#!/usr/bin/env bash
set -euo pipefail

# === 配置 ===
APP_DIR="$HOME/app/python-xray-argo"
BACKUP_FILE="$APP_DIR/app.py.backup"
APP_FILE="$APP_DIR/app.py"
LOG_FILE="$APP_DIR/app.log"
NODE_INFO="$HOME/.xray_nodes_info"

# === 清理函数（退出时自动执行） ===
cleanup() {
  rm -rf "$TMPDIR" 2>/dev/null || true
}
TMPDIR="$(mktemp -d)"
trap cleanup EXIT

echo "工作目录: $APP_DIR"
echo "日志文件: $LOG_FILE"
echo "节点信息: $NODE_INFO"
echo

# === 1. 停止进程 ===
PID=$(ps -ef | grep "python3 app.py" | grep -v grep | awk '{print $2}' || true)
if [[ -n "${PID:-}" ]]; then
  echo "🔎 检测到 Xray Argo 正在运行, PID: $PID"
  kill -9 "$PID"
  echo "✅ 已停止 Xray Argo (PID $PID)"
else
  echo "ℹ️ Xray Argo 已经停止"
fi

# === 2. 清理日志和节点信息 ===
rm -f "$NODE_INFO" "$LOG_FILE"
echo "🧹 已清理节点信息和日志"

# === 3. 恢复 app.py ===
if [[ -f "$BACKUP_FILE" ]]; then
  cp "$BACKUP_FILE" "$APP_FILE"
  echo "♻️ 已恢复 app.py 到初始状态"
else
  echo "⚠️ 未找到 $BACKUP_FILE，跳过恢复"
fi

echo
echo "✅ 一键清理完成！"
