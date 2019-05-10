import dask

from dask.distributed import Client


def square(x):
  return x**2

def neg(x):
  return -x

def inc(x):
  return x+1

def run_square(index):
    nros = [index, 2, 3, 6, 5, 9, 8, 7]
    A = list(map(square, nros))
    result = sum(A)
    with open('/tmp/square'+str(index)+'.txt', 'w') as file:
        file.write(str(result))
    return result

def run_inc(index):
    nros = [index, 2, 3, 6, 5, 9, 8, 7]
    A = list(map(inc, nros))
    result = sum(A)
    with open('/tmp/inc'+str(index)+'.txt', 'w') as file:
        file.write(str(result))
    return result


client = Client('192.168.2.10:8786')
with dask.config.set(num_workers=2):
    for i in range(20):
        print("i:", i)
        sum_square = client.submit(run_square, i)
        print("sum_square:", sum_square.result())
        sum_inc = client.submit(run_inc, i)
        print("sum_inc:", sum_inc.result())
