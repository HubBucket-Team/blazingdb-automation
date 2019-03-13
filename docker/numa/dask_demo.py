from dask.distributed import Client

client = Client('192.168.2.10:8786')

def square(x):
  return x**2

def neg(x):
  return -x

def inc(x):
  return x+1

A = client.map(square, range(1000))
B = client.map(neg, A)
total = client.submit(sum, B)

print("result:", total.result())
print("gather A:", client.gather(A))
print("gather B:", client.gather(B))

nros = [1, 2, 3, 6, -1, 9]
total2 = client.submit(sum, nros)
print("result:", total2.result())
print("gather nros:", client.gather(nros))
