FROM runpod/worker-comfyui:5.0.0-base

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
