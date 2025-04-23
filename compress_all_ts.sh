#!/bin/bash

TARGET_DIR="/app/downloads"
CRF=28

# 输出格式化工具函数
format_size() {
  size_bytes=$1
  echo "scale=2; $size_bytes / 1024 / 1024" | bc
}

# 遍历所有 ts 文件
find "$TARGET_DIR" -type f -name '*.ts' | while read -r ts_file; do
  mp4_file="${ts_file%.ts}.mp4"

  echo "🎬 开始压缩: $ts_file"
  echo "👉 输出为: $mp4_file"

  # 获取压缩前文件大小（MB）
  size_before=$(stat -c %s "$ts_file")
  size_before_mb=$(format_size $size_before)

  # 获取视频时长（秒）
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$ts_file")
  duration_fmt=$(printf "%.1f" "$duration")

  # 记录压缩开始时间
  start_time=$(date +%s)

  # 执行压缩
  ffmpeg -i "$ts_file" -vcodec libx265 -crf $CRF -preset fast -acodec aac "$mp4_file" -y

  # 记录压缩结束时间
  end_time=$(date +%s)
  compress_duration=$((end_time - start_time))

  # 获取压缩后文件大小
  if [ -f "$mp4_file" ]; then
    size_after=$(stat -c %s "$mp4_file")
    size_after_mb=$(format_size $size_after)

    echo "✅ 压缩完成:"
    echo "📦 原文件大小: ${size_before_mb} MB"
    echo "📦 压缩后大小: ${size_after_mb} MB"
    echo "⏱ 视频时长: ${duration_fmt} 秒"
    echo "⚙️ 压缩耗时: ${compress_duration} 秒"

    # 删除原始 ts 文件
    rm -f "$ts_file"
  else
    echo "❌ 压缩失败: $ts_file"
  fi

  echo "--------------------------------------"
done
