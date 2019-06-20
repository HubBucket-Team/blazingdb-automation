import pyarrow as pa
from cudf import DataFrame
from dask.distributed import Client
import operator

def collect_results(metaToken):
    arrow_table = pa.RecordBatchStreamReader('/home/felipe/god-build/workspace-debug/pyblazing_project/develop/pyBlazing/examples/data/gpu.arrow').read_all()
    df = arrow_table.to_pandas()
    df = df[['swings', 'tractions']]
    df = DataFrame.from_pandas(df)
    print(df)
    return "done"

client = Client('10.0.0.58:8786')
client.restart()

job = client.submit( collect_results, metaToken)
print( job.result())