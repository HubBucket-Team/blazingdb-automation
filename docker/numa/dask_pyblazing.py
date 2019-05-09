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


column_names = ['n_nationkey', 'n_name', 'n_regionkey', 'n_comments']
column_types = ['int32', 'int64', 'int32', 'int64']
nation_gdf = cudf.read_csv("/blazingdb/data/nation.psv", delimiter='|', dtype=column_types, names=column_names)
tables = {'nation': nation_gdf}

def run_query(index):
    print("run_query index:", index)
    sql = 'select n_nationkey, n_regionkey, n_nationkey + n_regionkey as addition from main.nation'
    result_gdf = pyblazing.run_query(sql, tables)
    tamanio = len(result_gdf.columns)
    with open('/tmp/salida'+str(index)+'.txt', 'w') as file:
        file.write(str(tamanio))
    #time.sleep(3)
    return tamanio


client = Client('127.0.0.1:8786')
sum_demo = client.map(sum, [6])
results = client.map(run_query, [8])
total = client.submit(sum, results)
print("result:", total.result())
