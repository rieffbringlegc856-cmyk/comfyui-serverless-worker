FROM runpod/worker-comfyui:5.0.0-base

# Системные зависимости для Python 3.11 и OpenCV
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

# Базовые ноды внутри контейнера
WORKDIR /comfyui/custom_nodes
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
RUN git clone https://github.com/Smirnov75/ComfyUI-mxToolkit.git comfyui-mxtoolkit || true
RUN git clone https://github.com/psun/ComfyUI-LLMTextProcessor.git ComfyUI-LLM-text-processor || true
RUN git clone https://github.com/Acly/comfyui-inpaint-nodes.git comfyui-inpaint-cropandstitch || true

# KJNodes стабильной версии
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    && cd ComfyUI-KJNodes \
    && git checkout $(git rev-list -n 1 --before="2025-01-01" main) || true

# Установка зависимостей нод
RUN for req in /comfyui/custom_nodes/*/requirements.txt; do \
      [ -f "$req" ] && /usr/bin/python -m pip install --no-cache-dir -r "$req" || true; \
    done

# Подключение локальных нод (включая krea2edit) с Network Volume при старте
RUN python3 -c '\
path = "/rp_handler.py"\n\
with open(path, "r") as f: code = f.read()\n\
target = "def start_comfyui():"\n\
injection = """\n\
    import os\n\
    vol_nodes = "/runpod-volume/ComfyUI/custom_nodes"\n\
    if os.path.exists(vol_nodes):\n\
        for n in os.listdir(vol_nodes):\n\
            src = os.path.join(vol_nodes, n)\n\
            dst = os.path.join("/comfyui/custom_nodes", n)\n\
            if not os.path.exists(dst):\n\
                try: os.symlink(src, dst)\n\
                except Exception: pass\n\
"""\n\
code = code.replace(target, target + injection)\n\
with open(path, "w") as f: f.write(code)\n\
'
