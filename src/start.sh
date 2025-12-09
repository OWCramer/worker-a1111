#!/usr/bin/env bash

echo "Worker Initiated"

echo "Starting WebUI API"
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"
export PYTHONUNBUFFERED=true

if [ -f "/workspace/models/model.safetensor" ]; then
    declare -a ARGS

    ARGS+=(--xformers)
    ARGS+=(--no-half-vae)
    ARGS+=(--skip-python-version-check)
    ARGS+=(--skip-torch-cuda-test)
    ARGS+=(--skip-install)
    ARGS+=(--ckpt "/runpod-volume/models/model.safetensor")
    ARGS+=(--opt-sdp-attention)
    ARGS+=(--disable-safe-unpickle)
    ARGS+=(--port 3000)
    ARGS+=(--api)
    ARGS+=(--nowebui)
    ARGS+=(--skip-version-check)
    ARGS+=(--no-hashing)
    ARGS+=(--no-download-sd-model)

    python /stable-diffusion-webui/webui.py "${ARGS[@]}" &
else
    echo "WARN: Model not found at /workspace/models/model.safetensor. Skipping WebUI start."
fi

echo "Starting RunPod Handler"
python -u /handler.py