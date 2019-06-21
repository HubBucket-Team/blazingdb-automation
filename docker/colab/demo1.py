import os
os.environ["NUMBAPRO_NVVM"] = "/usr/local/cuda/nvvm/lib64/libnvvm.so"
os.environ["NUMBAPRO_LIBDEVICE"] = "/usr/local/cuda/nvvm/libdevice/"

import cudf
from blazingsql import BlazingContext


bc = BlazingContext()

column_names = ['n_nationkey', 'n_name', 'n_regionkey', 'n_comments']
column_types = ['int32', 'int64', 'int32', 'int64']

nation_gdf = cudf.read_csv("/blazingsql/data/nation.psv", delimiter='|',
                           dtype=column_types, names=column_names)

print(nation_gdf)
bc.create_table('nation', nation_gdf)

query = 'select n_nationkey, n_regionkey, n_nationkey + n_regionkey as addition from main.nation'
result_gdf = bc.sql(query).get()

print(query)
print(result_gdf)
