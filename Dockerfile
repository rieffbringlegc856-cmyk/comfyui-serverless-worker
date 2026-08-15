FROM registry.runpod.net/runpod-workers-worker-comfyui-main-dockerfile:a1981e99b

# Скачиваем ваши кастомные ноды внутрь образа
RUN git clone https://github.com/ComfyUI/ComfyUI-basic_data_handling /comfyui/custom_nodes/ComfyUI-basic_data_handling \
    && git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack /comfyui/custom_nodes/ComfyUI-Impact-Pack \
    && git clone https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy

# Устанавливаем зависимости для нод (если есть requirements.txt)
RUN for req in /comfyui/custom_nodes/*/requirements.txt; do [ -f "$req" ] && pip install --no-cache-dir -r "$req"; done
