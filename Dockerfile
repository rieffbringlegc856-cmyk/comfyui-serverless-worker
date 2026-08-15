FROM runpod/pytorch:2.2.1-py3.10-cuda12.1.1-devel-ubuntu22.04

WORKDIR /

# Установка системных утилит и клонирование официального воркера ComfyUI от RunPod
RUN apt-get update && apt-get install -y git wget curl ffmpeg libsm6 libxext6 && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/runpod-workers/worker-comfyui /comfyui-worker \
    && git clone https://github.com/comfyanonymous/ComfyUI /comfyui

# Установка зависимостей ComfyUI и серверлесс-обработчика RunPod
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip install --no-cache-dir -r /comfyui/requirements.txt \
    && pip install --no-cache-dir -r /comfyui-worker/builder/requirements.txt || true \
    && pip install --no-cache-dir runpod requests websocket-client

# Копируем обработчик RunPod
RUN cp -r /comfyui-worker/src/* / || true

# Клонируем ваши кастомные ноды
RUN git clone https://github.com/ComfyUI/ComfyUI-basic_data_handling /comfyui/custom_nodes/ComfyUI-basic_data_handling \
    && git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack /comfyui/custom_nodes/ComfyUI-Impact-Pack \
    && git clone https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy

# Устанавливаем зависимости кастомных нод
RUN for req in /comfyui/custom_nodes/*/requirements.txt; do [ -f "$req" ] && pip install --no-cache-dir -r "$req"; done

WORKDIR /
CMD ["python3", "-u", "/rp_handler.py"]
