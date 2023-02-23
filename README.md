## GPU Grabber
Tired of having to manually check for GPU availability while conducting a machine learning task during the peak days of important conference? So does the owner of this repository. This script will check for new GPUs on your local clusters and send you an email when a new GPU is available, and completes the rest of your jobs.

### Usage
1. Clone this repository
   ```bash
   git clone git@github.com:MrPeterJin/gpu_grabber.git
    ```
2. Fill in the [gpu_grabber.sh](gpu_grabber.sh) file with your information. Also, fill the `python_scripts` folder with the path to your scripts.
    ```bash
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

    conda_env="your_conda_env_name"
    ```
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
    * * * * * /path/to/gpu_grabber.sh # this would run the script every minute
    ```
   For more information on `crontab`, please refer to [this](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/).

That's it! You should be good to go.

### Credits
This script is heavily contributed by ChatGPT and Github Copilot.
