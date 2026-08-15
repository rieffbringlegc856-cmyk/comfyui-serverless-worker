FROM runpod/worker-comfyui:5.0.0-base

# Системные C-заголовки и библиотеки графики
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11-dev \
    build-essential \
    libglib2.0-0 \
    libgl1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Обновляем ComfyUI и базовые зависимости
RUN cd /comfyui \
    && git fetch --all \
    && (git checkout master || git checkout main) \
    && git pull \
    && /usr/bin/python -m pip install --no-cache-dir -r requirements.txt \
    && /usr/bin/python -m pip install --no-cache-dir sqlalchemy alembic pydantic scikit-image onnxruntime segment-anything piexif

# Создаем папки
RUN mkdir -p /comfyui/custom_nodes /ComfyUI/custom_nodes

WORKDIR /comfyui/custom_nodes

# 1. Базовые и логические ноды
RUN git clone https://github.com/StableLlama/ComfyUI-basic_data_handling.git || true
RUN git clone https://github.com/rgthree/rgthree-comfy.git || true
RUN git clone https://github.com/evanspearman/ComfyMath.git || true
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git || true
RUN git clone https://github.com/MoonGoblinDev/Civicomfy.git || true
RUN git clone https://github.com/MadiatorLabs/ComfyUI-RunpodDirect.git || true
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git || true
RUN git clone https://github.com/theUpsider/ComfyUI-Logic.git || true
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git || true
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git || true

# 2. Impact Pack (для Inpaint, Wildcard Processor, Selector)
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    && cd ComfyUI-Impact-Pack \
    && /usr/bin/python install.py || true

# 3. Дополнительные инструменты (mxToolkit, LLM, Krea2)
RUN git clone https://github.com/Smirnov75/ComfyUI-mxToolkit.git || true
RUN git clone https://github.com/kijai/ComfyUI-Krea2.git || git clone https://github.com/Krea-ai/ComfyUI-Krea2.git || git clone https://github.com/comfyanonymous/ComfyUI-Krea2.git || true
RUN git clone https://github.com/psun/ComfyUI-LLMTextProcessor.git || true

# 4. KJNodes
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    && cd ComfyUI-KJNodes \
    && git checkout $(git rev-list -n 1 --before="2025-01-01" main) || true

# Синхронизация директорий
RUN cp -rn /comfyui/custom_nodes/* /ComfyUI/custom_nodes/ 2>/dev/null || true

# Установка Python-зависимостей для всех кастомных папок
RUN for req in /comfyui/custom_nodes/*/requirements.txt /ComfyUI/custom_nodes/*/requirements.txt; do \
      [ -f "$req" ] && /usr/bin/python -m pip install --no-cache-dir -r "$req" || true; \
    done
