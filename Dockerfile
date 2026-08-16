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
RUN mkdir -p /comfyui/custom_nodes /ComfyUI/custom_nodes /comfyui/models/LLM

WORKDIR /comfyui/custom_nodes

# Базовые ноды и логика
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

# Impact Pack
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    && cd ComfyUI-Impact-Pack \
    && /usr/bin/python install.py || true

# Все кастомные ноды рабочего процесса
RUN git clone https://github.com/bash-j/mikey_nodes.git || true
RUN git clone https://github.com/Smirnov75/ComfyUI-mxToolkit.git comfyui-mxtoolkit || true
RUN git clone https://github.com/lbouaraba/comfyui-krea2edit.git comfyui-krea2edit || true
RUN git clone https://github.com/KingManiya/ComfyUI-LLM-text-processor.git || true
RUN git clone https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch.git comfyui-inpaint-cropandstitch || true
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git || true
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git comfyui-videohelpersuite || true
RUN git clone https://github.com/flyingshapes/comfyui-textoverlay.git comfyui-textoverlay || true

# Синхронизация директорий
RUN cp -rn /comfyui/custom_nodes/* /ComfyUI/custom_nodes/ 2>/dev/null || true

# Установка зависимостей всех кастомных нод
RUN for req in /comfyui/custom_nodes/*/requirements.txt /ComfyUI/custom_nodes/*/requirements.txt; do \
      [ -f "$req" ] && /usr/bin/python -m pip install --no-cache-dir -r "$req" || true; \
    done

# Полная конфигурация поиска моделей и input-файлов на Network Volume
RUN printf "runpod_volume:\n  base_path: /runpod-volume\n  checkpoints: models/checkpoints\n  clip: models/clip\n  clip_vision: models/clip_vision\n  configs: models/configs\n  controlnet: models/controlnet\n  embeddings: models/embeddings\n  loras: models/loras\n  upscale_models: models/upscale_models\n  vae: models/vae\n  unet: models/unet\n  llm: models/LLM\n  input: input\n" > /comfyui/extra_model_paths.yaml
