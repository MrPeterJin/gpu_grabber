## GPU Grabber
Tired of having to manually check for GPU availability while conducting a machine learning task during the peak days of important conference? So does the owner of this repository. This script will check for new GPUs on your remote clusters and send you an email when a new GPU is available, and completes the rest of your jobs.

### Requirements
1. A remote server with GPUs, of course ;)
2. `sudo` access to the server, since we need to install and config `ssmtp` on the server.
### Usage
This script is designed to be used on a remote cluster with several shared GPUs. It divides into two versions: the `local` version and the `full` version. 

The `local` version does not require you to send anything to the remote server, but it has the limitation that it would only notify you when there is a GPU is *totally vacant*. Also, you need to clarify the GPU ID in your own python scripts through explicit expression like `os.environ["CUDA_VISIBLE_DEVICES"] = "gpu_ids_you_expect_are_available"`.    
The `full` version not only does this automatically for you, but also provides flexible filters for you to choose which GPU you would expected to use under different conditions (e.g., GPU number, utilization, etc.). However, it requires you to send a python script to the remote server for GPU_ID filtering, which might be a security concern.
#### Local Version (gpu_grabber_local.sh)
1. Clone this repository
   ```bash
   git clone git@github.com:MrPeterJin/gpu_grabber.git
    ```
2. Configure your private ssh key through [this blog](https://itslinuxfoss.com/ssh-using-private-key-linux/#:~:text=A%20step-by-step%20procedure%20is%20mentioned%20below%20to%20make,3%20Step%203%3A%20Connect%20to%20the%20Remote%20Machine)       
3. Setting up your mail server via `ssmtp` configs.   
   3.1. Install `ssmtp` via `apt-get`    
   `sudo apt-get install ssmtp && sudo /etc/ssmtp/ssmtp.conf`

   3.2. Add the following in the `ssmtp.conf` file with your information.    
   ```bash
   Debug=YES
   root=your_email_address
   mailhub=smtp.gmail.com:587 # or your mail server, this is for gmail
   AuthUser=your_email_address
   AuthPass=your_email_password
   UseSTARTTLS=YES
   ```
4. Setting up your `crontab` to run the script periodically.    
   4.1 Run `crontab -e` to edit your `crontab` file.      
   4.2 Add the following line to the file.    
   ```bash
    * * * * * if [ ! -e /tmp/cron_lockfile.txt ]; then /path/to/gpu_grabber.sh; fi # this would run the script every minute to check if therer is a GPU vacant while the filelock is not present
    ```
    For more information on `crontab`, please refer to [this](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/).
5. Fill in the [gpu_grabber_local.sh](gpu_grabber_local.sh) file with your information. Also, fill the `python_scripts` folder with the path to your scripts.
    ```bash
    # set the SSH connection information
    SSH_USER="your_ssh_username"
    SSH_HOST="your_ssh_host"
    SSH_PORT="your_ssh_port"
    SSH_KEY="your_ssh_key" # this is the path to your private key, normally it's ~/.ssh/id_rsa

    # set your email address
    EMAIL_ADDRESS="your_email_address"

    # set the path to your Python scripts
    python_scripts=(
        "/path/to/train1.py"
        "/path/to/train2.py"
        "/path/to/train3.py"
    )

    rc_path="your_rc_path" # this is the path to your .xxxrc file, normally it's ~/.xxxrc, where xxx is your shell name (e.g., bash, zsh, etc.)
    conda_env="your_conda_env_name"
    ```

#### Full Version (gpu_grabber_full.sh)
1-4. Same as the `local` version.      
5. Apart from filling the same information in the [gpu_grabber_local.sh](gpu_grabber_local.sh) file, there are some additional filters for GPUs you need to take care of:    
    
```bash
# variable to check GPU availability
REQ_GPUS=0 # number of GPUs you expect to use
REQ_MEM=0 # VRAM in MB per GPU you expect to use
REQ_UTIL=0 # current GPU utilization upperbound
REQ_PROC=0 # current number of processes per GPU upperbound
```
For instance, a settings with `REQ_GPUS=1`, `REQ_MEM=8000`, `REQ_UTIL=10`, `REQ_PROC=1` means that you expect to use one GPU with at least 8GB VRAM, and currently the GPU is occupied less than 10% and less than 1 process.

That's it! You should be good to go.
  
### Credits
This script is heavily contributed by ChatGPT and Github Copilot. Also, thanks to [cnhaox](https://github.com/cnhaox/GPU-grabber)'s code for the inspiration.
