FROM runpod/worker-comfyui:5.0.0-base

# Системные зависимости для Python 3.11 и OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11-dev \
    build-essential \
    libglib2.0-0 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Обновляем ComfyUI и базовые зависимости
RUN cd /comfyui \
    && git fetch --all \
    && (git checkout master || git checkout main) \
    && git pull \
    && /usr/bin/python -m pip install --no-cache-dir -r requirements.txt \
    && /usr/bin/python -m pip install --no-cache-dir sqlalchemy alembic pydantic scikit-image onnxruntime segment-anything piexif

# Подключаем ноды напрямую из сетевого хранилища RunPod Serverless
RUN printf "volume_nodes:\n  base_path: /runpod-volume/ComfyUI\n  custom_nodes: custom_nodes\n" > /comfyui/extra_model_paths.yaml
