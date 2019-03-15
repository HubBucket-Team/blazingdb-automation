import cudf
import pyblazing
import time

from dask.distributed import Client


def load_data(index):
    print("load_data index:", index)
    column_names = ['n_nationkey', 'n_name', 'n_regionkey', 'n_comments']
    column_types = ['int32', 'int64', 'int32', 'int64']
    nation_gdf = cudf.read_csv("/blazingdb/data/nation.psv", delimiter='|', dtype=column_types, names=column_names)
    tables = {'nation': nation_gdf}
    return tables

def run_query(index, tables):
    print("run_query index:", index)
    sql = 'select n_nationkey, n_regionkey, n_nationkey + n_regionkey as addition from main.nation'
    result_gdf = pyblazing.run_query(sql, tables)
    tamanio = len(result_gdf.columns)
    print("tamanio:", tamanio)
    with open('/tmp/salida'+str(index)+'.txt', 'w') as file:
        file.write(str(tamanio))
    #time.sleep(3)
    return tamanio


for x in range(20):
    client = Client('127.0.0.1:8786')
    #print("x: ", x)
    sum_demo = client.map(sum, [x], workers=['172.18.0.23', '172.18.0.24'])
    tables = client.map(load_data, [x], workers=['172.18.0.24'])
    results = client.map(run_query, [x], tables, workers=['172.18.0.25'])
    total = client.submit(sum, results)
    print("x: %s - result: %s" % (x, total.result()))
    del client

