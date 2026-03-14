#!/usr/bin/env python3
"""检查数据与权重是否就绪，便于按步骤查缺补漏。"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEQ_DIR = os.path.join(ROOT, "datasets", "SemanticKITTI", "dataset", "sequences")
CKPT_DIR = os.path.join(ROOT, "checkpoints")
TEACHER_CKPT = os.path.join(CKPT_DIR, "lidiff_ddpo_refined.ckpt")

def main():
    ok = True

    # 步骤 1：数据集
    if not os.path.isdir(SEQ_DIR):
        print("[ ] 步骤 1：未找到 sequences 目录")
        print(f"    需要: {SEQ_DIR}")
        ok = False
    else:
        seqs = [d for d in os.listdir(SEQ_DIR) if os.path.isdir(os.path.join(SEQ_DIR, d)) and d.isdigit()]
        if not seqs:
            print("[ ] 步骤 1：sequences 目录为空，请下载并解压 SemanticKITTI 到该路径")
            print(f"    路径: {SEQ_DIR}")
            ok = False
        else:
            # 检查 00 是否有 velodyne、labels、poses
            s00 = os.path.join(SEQ_DIR, "00")
            has_velo = os.path.isdir(os.path.join(s00, "velodyne"))
            has_labels = os.path.isdir(os.path.join(s00, "labels"))
            has_poses = os.path.isfile(os.path.join(s00, "poses.txt"))
            if not (has_velo and has_labels and has_poses):
                print("[ ] 步骤 1：序列 00 缺少 velodyne/labels/poses.txt，请确认解压完整")
                ok = False
            else:
                print(f"[√] 步骤 1：数据集就绪（序列: {', '.join(sorted(seqs))}）")

    # 步骤 2：地图
    map_00 = os.path.join(SEQ_DIR, "00", "map_clean.npy")
    if not os.path.isfile(map_00):
        print("[ ] 步骤 2：未生成地面真值地图，请运行:")
        print("    python map_from_scans.py --path datasets/SemanticKITTI/dataset/sequences/")
        ok = False
    else:
        print("[√] 步骤 2：已生成 map_clean.npy")

    # 步骤 3：教师权重
    if not os.path.isfile(TEACHER_CKPT):
        print("[ ] 步骤 3：未找到教师权重，请下载并放置:")
        print(f"    {TEACHER_CKPT}")
        print("    下载: https://drive.google.com/drive/folders/1z7Iq6nPDZXtASUDP8R8sqhUAvVfRqKQH")
        ok = False
    else:
        print("[√] 步骤 3：教师权重已就绪 (lidiff_ddpo_refined.ckpt)")

    if ok:
        print("\n全部就绪，可以训练:")
        print("  python trains/DistillationDPO.py --SemanticKITTI_path datasets/SemanticKITTI --pre_trained_diff_path checkpoints/lidiff_ddpo_refined.ckpt")
        return 0
    print()
    return 1

if __name__ == "__main__":
    sys.exit(main())
