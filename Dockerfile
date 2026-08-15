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

# Подменяем системную папку custom_nodes на сетевой диск при запуске контейнера
RUN sed -i '/def start_comfyui/a \    import shutil\n    if os.path.exists("/runpod-volume/ComfyUI/custom_nodes"):\n        for item in os.listdir("/runpod-volume/ComfyUI/custom_nodes"):\n            s = os.path.join("/runpod-volume/ComfyUI/custom_nodes", item)\n            d = os.path.join("/comfyui/custom_nodes", item)\n            if not os.path.exists(d):\n                os.symlink(s, d)' /rp_handler.py
