import sys, os
os.environ["NUMBAPRO_NVVM"] = "/usr/local/cuda/nvvm/lib64/libnvvm.so"
os.environ["NUMBAPRO_LIBDEVICE"] = "/usr/local/cuda/nvvm/libdevice/"

from blazingsql import BlazingContext
import cudf

bc = BlazingContext()

# Read cvs
gdf = cudf.read_csv('/blazingsql/data/Music.csv')

# Create table
bc.create_table('music', gdf)

# Query
result = bc.sql('SELECT * FROM main.music', ['music']).get()

# Get GDF
result_gdf = result.columns

# Print GDF
print(result_gdf)

