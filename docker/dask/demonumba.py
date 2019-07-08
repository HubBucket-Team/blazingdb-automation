from dask.distributed import Client


def collect_results():
  from numba import cuda
  #print(cuda.gpus)
  for gpu in cuda.gpus:
    print("gpu", gpu)

client = Client('127.0.0.1:8786')
job = client.submit(collect_results)
print(job.result())
