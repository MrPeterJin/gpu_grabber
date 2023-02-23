import os
import argparse

def str2float(string):
    string = ''.join(list(filter(lambda ch: ch in '0123456789.', string)))
    if string == '':
        return None
    else:
        return float(string)


def get_gpu_info():
    '''
    ## Description:
        The function that get the message from nvidia-smi and returns the dict of gpu information.
    ## Return:
        gpu_status_dict: dict
    '''
    gpu_status_dict = dict()

    gpu_status_list = os.popen('nvidia-smi').readlines()
    idx = 0
    while '|=' != gpu_status_list[idx][:2]:
        idx += 1
    idx += 1

    while gpu_status_list[idx][0] != ' ':
        gpu_id = gpu_status_list[idx].split()[1]
        str_list = gpu_status_list[idx+1].split()

        gpu_status_dict[gpu_id] = {
            'fan': str2float(str_list[1]),
            'temperature': str2float(str_list[2]),
            'used power': str2float(str_list[4]),
            'total power': str2float(str_list[6]),
            'used memory': str2float(str_list[8]),
            'total memory': str2float(str_list[10]),
            'gpu util': str2float(str_list[12]),
            'process num': 0
        }
        idx += 4
    
    while '|=' not in gpu_status_list[idx]:
        idx += 1
    idx += 1
    while '+-' != gpu_status_list[idx][:2]:
        str_list = gpu_status_list[idx].split()
        if str_list[1] in gpu_status_dict.keys():
            gpu_status_dict[str_list[1]]['process num'] += 1
        idx += 1
    return gpu_status_dict


def get_args():
    parser = argparse.ArgumentParser(description='The program that get ids of usable GPUs. ')
    parser.add_argument('-N', '--num', type=int, help="The number of GPUs required. ")
    parser.add_argument('-M', '--memory', type=int, default=None, help="The minimum video memory (in MB) required per GPU. ")
    parser.add_argument('-P', '--process', type=int, default=None, help="The maximum number of running processes per GPU. ")
    parser.add_argument('-U', '--util', type=int, default=None, help="The maximum utilization rate (%) per GPU. ")
    parser.add_argument('-I', '--id', nargs='*', default=None, help="The list of specified GPU id(s).")
    
    return parser.parse_args()


def main():
    args = get_args()
    assert args.num is not None and args.num>=0, "[ERROR] The number of GPUs required is None/wrong. "
    usable_gpu_list = list()
    gpu_status_dict = get_gpu_info()
    for id in gpu_status_dict.keys():
        if args.id is not None and id not in args.id:
            continue
        flag = True
        if args.memory is not None and \
           (gpu_status_dict[id]['used memory'] is None or \
            gpu_status_dict[id]['total memory'] is None or \
            gpu_status_dict[id]['total memory'] - gpu_status_dict[id]['used memory'] < args.memory):
                flag = False

        if args.process is not None and \
           (gpu_status_dict[id]['process num'] is None or \
            gpu_status_dict[id]['process num'] > args.process):
                flag = False
        
        if args.util is not None and \
            (gpu_status_dict[id]['gpu util'] is None or \
             gpu_status_dict[id]['gpu util'] > args.util):
                flag = False

        if flag:
            usable_gpu_list.append(id)

    if len(usable_gpu_list) >= args.num:
        print(','.join(usable_gpu_list[:args.num]))


if __name__ == '__main__':
    main()