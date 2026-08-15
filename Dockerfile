FROM runpod/worker-comfyui:5.0.0-base

# Устанавливаем системные зависимости нового ядра ComfyUI
RUN pip install --no-cache-dir sqlalchemy alembic pydantic

# Обновляем ядро ComfyUI
RUN cd /comfyui \
    && git fetch --all \
    && (git checkout master || git checkout main) \
    && git pull \
    && pip install --no-cache-dir -r requirements.txt || true

# Создаем директории
RUN mkdir -p /comfyui/custom_nodes /ComfyUI/custom_nodes

WORKDIR /comfyui/custom_nodes

# Клонируем кастомные ноды
RUN git clone https://github.com/StableLlama/ComfyUI-basic_data_handling.git || true
RUN git clone https://github.com/rgthree/rgthree-comfy.git || true
RUN git clone https://github.com/evanspearman/ComfyMath.git || true
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git || true
RUN git clone https://github.com/MoonGoblinDev/Civicomfy.git || true
RUN git clone https://github.com/MadiatorLabs/ComfyUI-RunpodDirect.git || true
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git || true
RUN git clone https://github.com/theUpsider/ComfyUI-Logic.git || true
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git || true

# KJNodes стабильной версии
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    && cd ComfyUI-KJNodes \
    && git checkout $(git rev-list -n 1 --before="2025-01-01" main) || true

# Синхронизируем директории
RUN cp -rn /comfyui/custom_nodes/* /ComfyUI/custom_nodes/ 2>/dev/null || true

# Устанавливаем Python-зависимости всех нод
RUN for req in /comfyui/custom_nodes/*/requirements.txt /ComfyUI/custom_nodes/*/requirements.txt; do \
      [ -f "$req" ] && pip install --no-cache-dir -r "$req" || true; \
    done
