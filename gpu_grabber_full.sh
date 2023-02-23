#!/bin/bash

# set the current time
current_time=$(date "+%Y-%m-%d,%H:%M:%S")

# set the SSH connection information
SSH_USER="your_ssh_username"
SSH_HOST="your_ssh_host"
SSH_PORT="your_ssh_port"
SSH_KEY="your_ssh_key"

# variable to check GPU availability
REQ_GPUS=0 # number of GPUs requested
REQ_MEM=0 # memory requested in MB per GPU
REQ_UTIL=0 # GPU utilization upperbound
REQ_PROC=0 # number of processes per GPU upperbound

# set your email address
EMAIL_ADDRESS="your_email_address"

# set your environment
rc_path="your_rc_path"
conda_env="your_conda_env_name"

# set your remote get_gpu_ids.py path
get_gpu_ids_path="your_remote_get_gpu_ids_path"

# Set the path to your Python scripts
python_scripts=(
    "your_remote_script1_path"
    "your_remote_script2_path"
)
# variable of GPU availability, filtered by the number of GPUs requested and user customisation
gpu_ids=`ssh -i $SSH_KEY -p $SSH_PORT $SSH_USER@$SSH_HOST "source $rc_path && conda activate $conda_env && python $get_gpu_ids_path -N $REQ_GPUS -M $REQ_MEM -P $REQ_PROC -U $REQ_UTIL"`

# flag for gpu availability
gpu_availability=1

if [ -z "$gpu_ids" ]; then
    gpu_availability=0
fi

# Function to send email notification
function send_email {
    echo "GPU $gpu_ids is/are available for use!" | mail -s "GPU Available" $EMAIL_ADDRESS
}

# Check if any lockfile exists
if [ -e /tmp/cron_lockfile.txt ]; then 
    rm /tmp/cron_lockfile.txt; 
fi

# Check if any GPUs are available
if [ $gpu_availability -eq 1 ]; then
    echo "[log] $current_time GPU $gpu_ids available! Sending email notification..." 
    send_email
    echo "lockfile placeholder" > /tmp/cron_lockfile.txt # prevent other cron jobs from running
    for scripts in "${python_scripts[@]}"; do
        echo "[log] $current_time Running $scripts..." 
        ssh -i $SSH_KEY -p $SSH_PORT $SSH_USER@$SSH_HOST "source $rc_path && conda activate $conda_env && CUDA_VISIBLE_DEVICES=$gpu_ids python $scripts" &
    done
else
    echo "[log] $current_time No GPUs currently available. :(" 
fi


