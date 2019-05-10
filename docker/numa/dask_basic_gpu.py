from distributed import Client
from time import sleep
import random

import subprocess

client = Client('192.168.2.10:8786')

def nvidia_data(name):
    def dask_function(dask_worker):
        print("dask_function name:", name)
        cmd = 'nvidia-smi --query-gpu={} --format=csv,noheader'.format(name)
        result = subprocess.check_output(cmd.split())
        return result.strip().decode()
    return dask_function

def register_metrics(dask_worker):
    for name in ['utilization.gpu', 'utilization.memory']:
        dask_worker.metrics[name] = nvidia_data(name)

client.run(register_metrics)


def inc(x):
    sleep(random.random() / 10)
    return x + 1

def dec(x):
    sleep(random.random() / 10)
    return x - 1

def add(x, y):
    sleep(random.random() / 10)
    return x + y


incs = client.map(inc, range(100))
decs = client.map(dec, range(100))
adds = client.map(add, incs, decs)
total = client.submit(sum, adds)

del incs, decs, adds
total.result()
