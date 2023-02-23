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

# Set the path to your Python scripts
python_scripts=(
    "/path/to/train1.py"
    "/path/to/train2.py"
    "/path/to/train3.py"
)

conda_env="your_conda_env_name"

# Variable to check GPU availability
gpu_status=$(ssh $SSH_USER@$SSH_HOST "nvidia-smi")


# Function to send email notification
function send_email {
    echo "GPU available for use!" | mail -s "GPU Available" $EMAIL_ADDRESS
}

# Check if any GPUs are available
if [[ $gpu_status == *"No running processes found"* ]]; then
    echo "[log] $current_time GPU available! Sending email notification..." > gpu_grabber.log
    send_email
    for scripts in "${python_scripts[@]}"; do
        echo "[log] $current_time Running $scripts..." > gpu_grabber.log
        ssh -i $SSH_KEY -p $SSH_PORT $SSH_USER@$SSH_HOST "conda activate $conda_env && python $scripts" &
    done
else
    echo "[log] $current_time No GPUs currently available. :(" > gpu_grabber.log
fi


