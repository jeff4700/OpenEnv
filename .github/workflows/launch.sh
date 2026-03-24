# docker build -t envtorch-base:latest -f $(pwd)/OpenEnv/src/core/containers/images/Dockerfile .
# docker build -t echo-env:latest -f $(pwd)/echo_env/server/Dockerfile .

# docker run -it --rm -v $(pwd)/echo_env:/app/src/envs/echo_env -p 8000:8000 echo-env:latest

#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
IMAGE="${1:-my-fastapi-image:latest}"     # Docker image name (arg 1)
TARGET_DIR="${2:-envs}"                   # Local directory to store extracted files (arg 2)
CONTAINER_PATH="/app/src/envs"            # Path inside container to extract/mount
PORT="${3:-8000}"                         # Host/container port (arg 3)

# --- Step 1: Extract /app/src/envs from image ---
echo ">>> Creating temporary container from $IMAGE"
CID=$(docker create "$IMAGE")

echo ">>> Copying $CONTAINER_PATH to ./$TARGET_DIR"
sudo rm -rf "./$TARGET_DIR"
docker cp "$CID:$CONTAINER_PATH" "./$TARGET_DIR"

echo ">>> Removing temporary container"
docker rm "$CID" >/dev/null

# --- Step 2: Read original CMD and clean it for Bash ---
ORIG_CMD=$(docker inspect --format='{{.Config.Cmd}}' "$IMAGE")
# Remove brackets, quotes, and commas
ORIG_CMD_CLEAN=$(echo "$ORIG_CMD" | sed 's/[][]//g' | sed 's/"//g' | tr ',' ' ')

echo ">>> Original CMD: $ORIG_CMD_CLEAN"
echo ">>> Starting container with --reload watching $CONTAINER_PATH"
echo

# --- Step 3: Run container with mounted code and auto-reload ---
docker run -it --rm \
  -v "$(pwd)/$TARGET_DIR:$CONTAINER_PATH" \
  -w /app \
  -p "$PORT:$PORT" \
  "$IMAGE" \
  $ORIG_CMD_CLEAN --reload --reload-dir "$CONTAINER_PATH"
