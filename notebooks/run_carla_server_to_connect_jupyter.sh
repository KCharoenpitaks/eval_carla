#!/bin/bash

# >>> conda initialize >>>

# export CARLA_ROOT=/mnt3/Documents/carla
# export SCENARIO_RUNNER_ROOT=/mnt3/Documents/Bench2Drive/scenario_runner
# export LEADERBOARD_ROOT=/mnt3/Documents/Bench2Drive/leaderboard
# export PYTHONPATH="${CARLA_ROOT}/PythonAPI/carla/":"${SCENARIO_RUNNER_ROOT}":"${LEADERBOARD_ROOT}":"${CARLA_ROOT}/PythonAPI/carla/dist/carla>


# export PATH=/usr/local/cuda-12.1/bin:$PATH
# export CUDA_HOME=/usr/local/cuda-12.1
# export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64:$LD_LIBRARY_PATH
# export CC=/usr/bin/gcc

# Activate the conda environment
conda activate pdm_lite

# Set CUDA paths
export PATH=/usr/local/cuda-12.1/bin:$PATH
export CUDA_HOME=/usr/local/cuda-12.1

# CARLA and project paths
export CARLA_ROOT=/mnt3/Documents/carla
export WORK_DIR=/mnt3/Documents/Bench2Drive
export PYTHONPATH=$PYTHONPATH:${CARLA_ROOT}/PythonAPI:${CARLA_ROOT}/PythonAPI/carla
export SCENARIO_RUNNER_ROOT=${WORK_DIR}/scenario_runner
export LEADERBOARD_ROOT=${WORK_DIR}/leaderboard
export PYTHONPATH="${CARLA_ROOT}/PythonAPI/carla/:${CARLA_ROOT}/PythonAPI/:${SCENARIO_RUNNER_ROOT}:${LEADERBOARD_ROOT}:${PYTHONPATH}:${CARLA_ROOT}/PythonAPI/carla/dist/carla-0.9.14-py3.7-linux-x86_64.egg"

# Change to the working directory
cd $WORK_DIR

# Kill any existing Carla processes
pkill Carla || true
pkill Carla || true
pkill Carla || true

# Trap to ensure Carla is killed on script termination
term() {
  echo "Terminating Carla..."
  pkill Carla || true
  exit 1
}
trap term SIGINT SIGTERM

# CARLA server settings
export CARLA_SERVER=${CARLA_ROOT}/CarlaUE4.sh
export REPETITIONS=1
export DEBUG_CHALLENGE=0

# Error handling
handle_error() {
  echo "An error occurred. Terminating Carla..."
  pkill Carla || true
  exit 1
}
trap 'handle_error' ERR

# Start CARLA server with high-quality settings and random port
export PORT=$((RANDOM % (40000 - 2000 + 1) + 2000))
echo "Starting CARLA on port $PORT with Epic quality..."
$CARLA_SERVER -carla-streaming-port=0 -carla-rpc-port=$PORT -RenderOffScreen -quality-level=Epic -nosound &
CARLA_PID=$!

# Wait for CARLA to initialize
sleep 20

# Start Jupyter Notebook
echo "Starting Jupyter Notebook..."
jupyter notebook --no-browser --port=8888

# Cleanup on exit (optional, if you want to keep Carla running even after Jupyter stops)
wait $CARLA_PID