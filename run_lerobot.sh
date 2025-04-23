#!/bin/bash

set -e

PROJECT_DIR="$(pwd)"

# Function to display help
show_help() {
    echo "Usage: $0 [OPTION]..."
    echo "Setup and manage the project environment."
    echo
    echo "Options:"
    echo "  -install     Set up the Linux environment."
    echo "  -teleoperate Run the teleoperation script."
    echo "  -help        Display this help message."
}

# Function to set up the environment
setup_environment() {
    if ! command -v uv &> /dev/null; then
        echo "Installing uv..."
        curl -Ls https://astral.sh/uv/install.sh | bash
    else
        echo "uv already installed."
    fi

    if ! command -v ffmpeg &> /dev/null; then
        echo "Installing ffmpeg via package manager..."
        sudo apt update && sudo apt install -y ffmpeg
    else
        echo "ffmpeg already installed."
    fi

    echo "Creating Python 3.10 virtual environment with uv..."
    uv venv --python=3.10
    source .venv/bin/activate

    echo "Installing your project in editable mode with [feetech]..."
    uv pip install -e ".[feetech]"

    echo "✅ Linux environment setup complete!"
}

# Function to run teleoperation
run_teleoperate() {
    source .venv/bin/activate
    sudo chmod 666 /dev/ttyACM0
    sudo chmod 666 /dev/ttyACM1

    python lerobot/scripts/control_robot.py \
      --robot.type=so100 \
      --robot.cameras='{}' \
      --control.type=teleoperate
}

# Main script logic
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -install)
            setup_environment
            shift
            ;;
        -teleoperate)
            run_teleoperate
            shift
            ;;
        -help)
            show_help
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done
