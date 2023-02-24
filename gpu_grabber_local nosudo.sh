#!/bin/bash

# set the current time
current_time=$(date "+%Y-%m-%d,%H:%M:%S")

# set the SSH connection information
SSH_USER="your_ssh_username"
SSH_HOST="your_ssh_host"
SSH_PORT="your_ssh_port"
SSH_KEY="your_ssh_key"

# set your email address
EMAIL_ADDRESS="your_email_address"

# set the path to your Python scripts
python_scripts=(
    "/path/to/train1.py"
    "/path/to/train2.py"
    "/path/to/train3.py"
)

# set your environment
rc_path="your_rc_path"
conda_env="your_conda_env_name"

# Variable to check GPU availability
gpu_status=$(ssh $SSH_USER@$SSH_HOST "nvidia-smi")

# Check if any lockfile exists
if [ -e /tmp/cron_lockfile.txt ]; then 
    rm /tmp/cron_lockfile.txt; 
fi

# Check if any GPUs are available
if [[ $gpu_status == *"No running processes found"* ]]; then
    echo "[log] $current_time GPU available! Sending email notification..." >> /tmp/gpu_grabber.log
    echo "lockfile placeholder" >> /tmp/cron_lockfile.txt # prevent other cron jobs from running
    for scripts in "${python_scripts[@]}"; do
        echo "[log] $current_time Running $scripts..." >> /tmp/gpu_grabber.log
        ssh -i $SSH_KEY -p $SSH_PORT $SSH_USER@$SSH_HOST "source $rc_path && conda activate $conda_env && python $scripts" &
    done
    rm /tmp/cron_lockfile.txt # script finished, remove lockfile
else
    echo "[log] $current_time No GPUs currently available. :(" >> /tmp/gpu_grabber.log
fi


