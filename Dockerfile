FROM runpod/pytorch:2.2.1-py3.10-cuda12.1.1-devel-ubuntu22.04

WORKDIR /

# Установка системных утилит и клонирование обработчиков
RUN apt-get update && apt-get install -y git wget curl ffmpeg libsm6 libxext6 && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/runpod-workers/worker-comfyui /comfyui-worker \
    && git clone https://github.com/comfyanonymous/ComfyUI /comfyui

# Установка зависимостей ComfyUI и RunPod
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip install --no-cache-dir -r /comfyui/requirements.txt \
    && pip install --no-cache-dir -r /comfyui-worker/builder/requirements.txt || true \
    && pip install --no-cache-dir runpod requests websocket-client

# Копируем обработчик RunPod
RUN cp -r /comfyui-worker/src/* / || true

# Клонируем ваши проверенные кастомные ноды
RUN git clone https://github.com/StableLlama/ComfyUI-basic_data_handling.git /comfyui/custom_nodes/ComfyUI-basic_data_handling \
    && git clone https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy \
    && git clone https://github.com/kijai/ComfyUI-KJNodes.git /comfyui/custom_nodes/ComfyUI-KJNodes \
    && git clone https://github.com/evanspearman/ComfyMath /comfyui/custom_nodes/ComfyMath \
    && git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes \
    && git clone https://github.com/MoonGoblinDev/Civicomfy.git /comfyui/custom_nodes/Civicomfy \
    && git clone https://github.com/MadiatorLabs/ComfyUI-RunpodDirect.git /comfyui/custom_nodes/ComfyUI-RunpodDirect \
    && git clone https://github.com/ltdrdata/ComfyUI-Manager.git /comfyui/custom_nodes/ComfyUI-Manager

# Устанавливаем Python-зависимости нод
RUN for req in /comfyui/custom_nodes/*/requirements.txt; do [ -f "$req" ] && pip install --no-cache-dir -r "$req"; done

WORKDIR /
CMD ["python3", "-u", "/rp_handler.py"]
