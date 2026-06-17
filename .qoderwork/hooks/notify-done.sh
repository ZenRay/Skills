#!/bin/bash
# .qoderwork/hooks/notify-done.sh
# Stop Hook — Agent 完成响应时发送桌面通知

set -uo pipefail

input=$(cat)
# stop_reason 可用于未来扩展（如不同原因展示不同消息）
stop_reason=$(echo "$input" | jq -r '.stop_reason // "completed"')

# Desktop notification (macOS + Linux fallback)
msg="任务已完成 [${stop_reason}]，等待下一步指令"

if command -v osascript &>/dev/null; then
  osascript -e "display notification \"${msg}\" with title \"Qoder\" sound name \"Glass\"" 2>/dev/null || true
elif command -v notify-send &>/dev/null; then
  notify-send "Qoder" "${msg}" 2>/dev/null || true
fi

exit 0
