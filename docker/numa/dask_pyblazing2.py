import cudf
import pyblazing
from pyblazing import DriverType, FileSystemType, EncryptionType
from pyblazing import SchemaFrom

import time

from dask.distributed import Client


dir_path = '/tmp/tpch/'
chunk_files = ['customer_0_0.parquet', 'customer_0_1.parquet']

def run_query(index, tables):
    print("run_query index:", index)
    print("load_data:", dir_path + chunk_files[index])
    customer_table = pyblazing.create_table(table_name='customer_parquet', type=SchemaFrom.ParquetFile, path= dir_path + chunk_files[index])
    nation_table = pyblazing.create_table(table_name='nation_parquet', type=SchemaFrom.ParquetFile, path= dir_path + '/nation_0_0.parquet')
    tables = {'customer_parquet': customer_table.columns, 'nation_parquet': nation_table..columns}

    sql = '''
        select avg(c.c_custkey), avg(c.c_nationkey), n.n_regionkey
        from main.customer_parquet as c
        inner join main.nation_parquet as n
        on c.c_nationkey = n.n_nationkey
        group by n.n_regionkey
    '''

    result_gdf = pyblazing.run_query(sql, tables)
    tamanio = len(result_gdf.columns)
    print("tamanio:", tamanio)
    with open('/tmp/salida'+str(index)+'.txt', 'w') as file:
        file.write(str(tamanio))
    #time.sleep(3)
    return tamanio


print('*** Register a POSIX File System ***')
fs_status = pyblazing.register_file_system(
    authority="tpch",
    type=FileSystemType.POSIX,
    root="/"
)
print(fs_status)

chunk_ids = [0, 1]
workers_ips = ['172.18.0.23', '172.18.0.24']

client = Client('127.0.0.1:8786')
results = client.map(run_query, [chunk_ids], workers=workers_ips)

total = client.submit(sum, results)
print("x: %s - result: %s" % (chunk_ids, total.result()))
del client