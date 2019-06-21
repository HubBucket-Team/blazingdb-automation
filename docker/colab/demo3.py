import os
os.environ["NUMBAPRO_NVVM"] = "/usr/local/cuda/nvvm/lib64/libnvvm.so"
os.environ["NUMBAPRO_LIBDEVICE"] = "/usr/local/cuda/nvvm/libdevice/"

import cudf
from blazingsql import BlazingContext
import pyarrow as pa

bc = BlazingContext()

arrow_table = pa.RecordBatchStreamReader('/blazingsql/data/gpu.arrow').read_all()
df = arrow_table.to_pandas()
df = df[['swings', 'tractions']]
print(df)

bc.create_table('gpu_info', df)

query = 'select swings+1, tractions+10 from main.gpu_info'
result_gdf = bc.sql(query).get()

print(query)
print(result_gdf)

