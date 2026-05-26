#!/bin/bash

# 新疆大环线小红书调研脚本
# 为每个景点搜索小红书笔记

echo "🗺️ 开始新疆大环线小红书调研..."
echo ""

# 需要调研的地点列表
LOCATIONS=(
  "新疆国际大巴扎"
  "天山天池"
  "喀纳斯湖"
  "禾木村"
  "赛里木湖"
  "那拉提草原"
  "独库公路"
  "五彩滩"
  "乌尔禾魔鬼城"
  "巴音布鲁克草原"
)

for location in "${LOCATIONS[@]}"; do
  echo "🔍 调研: $location"
  echo "  搜索小红书..."

  # 使用 OpenCLI 搜索
  opencli xiaohongshu search "$location" --limit 5 -f json > "/tmp/xhs_${location}.json" 2>/dev/null

  if [ -f "/tmp/xhs_${location}.json" ]; then
    # 提取关键信息
    notes=$(cat "/tmp/xhs_${location}.json" | grep -o '"title":"[^"]*"' | head -3)
    echo "  找到相关笔记:"
    echo "  $notes"
  else
    echo "  未找到结果"
  fi
  echo ""
done

echo "✅ 调研完成！结果保存在 /tmp/xhs_*.json"