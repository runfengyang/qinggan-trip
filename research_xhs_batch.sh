#!/bin/bash

# 新疆大环线小红书批量调研脚本
# 为每个景点搜索小红书笔记并生成结构化数据

OUTPUT_FILE="/Users/yangrunfeng/web_design/xinjiang-trip/xhs_research.json"

echo "🔍 开始新疆大环线小红书调研..."
echo ""

# 清空输出文件
echo '[' > "$OUTPUT_FILE"

# 需要调研的地点
LOCATIONS=(
  "新疆国际大巴扎:D1"
  "天山天池:D2"
  "五彩滩:D3"
  "喀纳斯湖:D4"
  "禾木村:D5"
  "乌尔禾魔鬼城:D6"
  "赛里木湖:D7"
  "那拉提草原:D8"
  "巴音布鲁克草原:D9"
  "独库公路:D9"
)

FIRST=true

for item in "${LOCATIONS[@]}"; do
  IFS=':' read -r location day <<< "$item"

  echo "📍 ${day}: ${location}"
  echo "  搜索中..."

  # 搜索小红书
  RESULT=$(opencli xiaohongshu search "$location" --limit 5 -f json 2>/dev/null)

  if [ -n "$RESULT" ]; then
    # 提取关键信息
    NOTES=$(echo "$RESULT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    notes = []
    for item in data[:3]:
        notes.append({
            'title': item.get('title', ''),
            'author': item.get('author', ''),
            'likes': item.get('likes', '0'),
            'url': item.get('url', '')
        })
    print(json.dumps(notes, ensure_ascii=False))
except:
    print('[]')
" 2>/dev/null || echo "[]")

    # 添加逗号分隔
    if [ "$FIRST" = true ]; then
      FIRST=false
    else
      echo ',' >> "$OUTPUT_FILE"
    fi

    # 写入JSON
    cat >> "$OUTPUT_FILE" << EOF
{
  "location": "$location",
  "day": "$day",
  "notes": $NOTES
}
EOF

    echo "  ✅ 完成"
  else
    echo "  ⚠️ 未找到结果"
  fi

  # 避免请求过快
  sleep 2
done

# 关闭JSON数组
echo ']' >> "$OUTPUT_FILE"

echo ""
echo "✅ 调研完成！结果已保存到: $OUTPUT_FILE"
