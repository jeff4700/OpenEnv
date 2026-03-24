# OpenEnv in Lightning Studio

[OpenEnv](https://github.com/meta-pytorch/OpenEnv) is an end-to-end framework for creating, deploying, and using isolated execution environments for agentic RL training. It provides Gymnasium-style APIs (`step()`, `reset()`, `state()`) that make it easy to interact with environments during RL training loops.

This guide will help you set up and run OpenEnv environments in your Lightning Studio.

## Step 0 (Optional): Use Your Own Custom Environment

**Skip this step if you want to use OpenEnv's official environments.**

If you have your own custom Dockerfile or want to modify an existing environment:

### Option A: Build from your Dockerfile
```bash
docker build -t echo-env:latest -f $(pwd)/OpenEnv/src/envs/echo_env/server/Dockerfile ~/OpenEnv
```
(Replace `echo-env:latest` with your desired image name and update the Dockerfile path to match your local directory)

### Option B: Pull your pre-built image
```bash
docker pull ghcr.io/meta-pytorch/openenv-echo-env
```
(Replace this with your own pre-built image path)

Then proceed to Step 1 using your image name.

## Step 1: Launch Interactive Development Session

Start an interactive session with your environment:

**Using official OpenEnv environments**
```bash
bash launch.sh ghcr.io/meta-pytorch/openenv-echo-env:latest envs 8000
bash launch.sh ghcr.io/meta-pytorch/openenv-chat-env:latest envs 8000
bash launch.sh ghcr.io/meta-pytorch/openenv-coding-env:latest envs 8000
```
**Using your custom environment**
```bash
bash launch.sh echo-env:latest
```

This script will:
- Extracts the environment code from the Docker image to your local directory (`~/envs/`)
- Starts the container with your local code mounted
- Enables **hot-reload** - any changes you make to the code will automatically restart the server
- Exposes the API on the specified port (default: 8000)

## Step 4: Test Your Environment

Once inside the container, you can interact directly with your environment's API and test functionality.
### Access the API
- API endpoint: `http://localhost:8000`
- Access API outside of studio by using the **Port Viewer** plugin

### Run test scripts
Try the example test script:
```bash
python use_echo_server.py
```
## Step 5: Share Your Environment

When you're ready to share your custom environment:
```bash
docker tag echo-env:latest /echo-env:latest
docker push /echo-env:latest
```

**Automated Publishing with GitHub Actions:**

Add your environment to `~/OpenEnv/.github/workflows/docker-build.yml`:
```yaml
strategy:
  matrix:
    image:
      - name: my-custom-env
        dockerfile: path/to/your/Dockerfile
```

Once configured, every push to `main` will automatically build and publish your image to `ghcr.io/<your-username>/openenv-my-custom-env:latest`.