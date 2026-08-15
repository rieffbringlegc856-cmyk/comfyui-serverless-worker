FROM runpod/worker-comfyui:5.0.0-base

# Создаем папки для кастомных нод по всем возможным путям ComfyUI
RUN mkdir -p /comfyui/custom_nodes /ComfyUI/custom_nodes

WORKDIR /comfyui/custom_nodes

# Клонируем ноды по отдельности
RUN git clone https://github.com/StableLlama/ComfyUI-basic_data_handling.git || true
RUN git clone https://github.com/rgthree/rgthree-comfy.git || true
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git || true
RUN git clone https://github.com/evanspearman/ComfyMath.git || true
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git || true
RUN git clone https://github.com/MoonGoblinDev/Civicomfy.git || true
RUN git clone https://github.com/MadiatorLabs/ComfyUI-RunpodDirect.git || true
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git || true

# Синхронизируем папки, если в образе ComfyUI лежит в /ComfyUI
RUN cp -rn /comfyui/custom_nodes/* /ComfyUI/custom_nodes/ 2>/dev/null || true

# Устанавливаем зависимости
RUN for req in /comfyui/custom_nodes/*/requirements.txt /ComfyUI/custom_nodes/*/requirements.txt; do \
      [ -f "$req" ] && pip install --no-cache-dir -r "$req" || true; \
    done
