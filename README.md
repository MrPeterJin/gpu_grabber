## GPU Grabber
Tired of having to manually check for GPU availability while conducting a machine learning task during the peak days of important conference? So does the owner of this repository. This script will check for new GPUs on your local clusters and send you an email when a new GPU is available, and completes the rest of your jobs.

### Usage
1. Clone this repository
2. Fill in the `gpu_grabber.sh` file with your information. Also, fill the `python_scripts` folder with the path to your scripts.
3. Setting up your mail server via `ssmtp` configs.
4. Setting up your `crontab` to run the script periodically.

That's it! You should be good to go.
