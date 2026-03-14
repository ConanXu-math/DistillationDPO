#!/usr/bin/env bash
# 步骤 2：生成 SemanticKITTI 地面真值地图
# 使用前请先完成步骤 1：将数据集解压到 datasets/SemanticKITTI/dataset/sequences/

set -e
cd "$(dirname "$0")/.."
SEQUENCES="${1:-datasets/SemanticKITTI/dataset/sequences/}"
shift 2>/dev/null || true
mkdir -p checkpoints
echo "生成地图，路径: $SEQUENCES"
python map_from_scans.py --path "$SEQUENCES" "$@"
