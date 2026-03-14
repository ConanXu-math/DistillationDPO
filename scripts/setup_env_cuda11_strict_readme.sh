#!/bin/bash
# 严格按 README：Python 3.8 + CUDA 11.1
# 使用前请先安装 CUDA 11.1 到 /usr/local/cuda-11.1（见 环境配置-严格按README-CUDA11.md）

set -e
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$PROJECT_DIR/.venv38"
CUDA11="/usr/local/cuda-11.1"

if [[ ! -d "$CUDA11" ]]; then
  echo "错误: 未找到 $CUDA11，请先安装 CUDA 11.1 后再运行本脚本。"
  echo "见: $PROJECT_DIR/环境配置-严格按README-CUDA11.md"
  exit 1
fi

if [[ ! -x "$VENV/bin/python" ]]; then
  echo "错误: 未找到虚拟环境 $VENV，请先执行："
  echo "  python3.8 -m venv $VENV && source $VENV/bin/activate"
  exit 1
fi

export CUDA_HOME="$CUDA11"
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}"

echo "使用 CUDA_HOME=$CUDA_HOME"
source "$VENV/bin/activate"

# 1. PyTorch 1.9 + CUDA 11.1
pip install torch==1.9.0 torchvision==0.10.0 --index-url https://download.pytorch.org/whl/cu111

# 2. 其余依赖
pip install -r "$PROJECT_DIR/requirements.txt"
pip install torch==1.9.0 torchvision==0.10.0 --index-url https://download.pytorch.org/whl/cu111 --force-reinstall --no-deps

# 3. MinkowskiEngine（CUDA 11.1 需用 gcc-10 编译，否则系统头文件与 nvcc 不兼容）
if command -v gcc-10 &>/dev/null && command -v g++-10 &>/dev/null; then
  export CC=gcc-10 CXX=g++-10
  echo "使用 CC=$CC CXX=$CXX 编译 MinkowskiEngine"
fi
if ! pip install --no-build-isolation -U MinkowskiEngine==0.5.4 -v --no-deps 2>/dev/null; then
  echo "从项目内修补源码安装 MinkowskiEngine..."
  cd "$PROJECT_DIR/scripts/MinkowskiEngine-0.5.4"
  rm -rf build MinkowskiEngine.egg-info
  if ! command -v gcc-10 &>/dev/null; then
    echo "错误: 未找到 gcc-10。CUDA 11.1 必须用 gcc-10 编译，请先执行："
    echo "  sudo apt install -y gcc-10 g++-10"
    echo "然后重新运行本脚本。"
    exit 1
  fi
  python setup.py install --blas=openblas
  cd "$PROJECT_DIR"
fi

# 4. 可编辑安装
pip install -U -e .

echo ""
echo "验证..."
python -c "import torch; import MinkowskiEngine as ME; print('torch:', torch.__version__, 'CUDA:', torch.cuda.is_available()); print('MinkowskiEngine OK')"
