import sys, os
os.environ["NUMBAPRO_NVVM"] = "/usr/local/cuda/nvvm/lib64/libnvvm.so"
os.environ["NUMBAPRO_LIBDEVICE"] = "/usr/local/cuda/nvvm/libdevice/"

import cudf
import pyblazing

column_names = ['n_nationkey', 'n_name', 'n_regionkey', 'n_comments']
column_types = ['int32', 'str', 'int32', 'str']
nation_gdf = cudf.read_csv("/blazingsql/data/nation.psv", delimiter='|',
                           dtype=column_types, names=column_names)

print(nation_gdf)

tables = {'nation': nation_gdf}
sql = 'select n_name from main.nation'
result_gdf = pyblazing.run_query(sql, tables)

print(sql)
print(result_gdf)
