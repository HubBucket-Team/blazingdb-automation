from dask.distributed import Client
#import operator

metaToken = None

def collect_results(metaToken):
    import pyarrow as pa
    from cudf import DataFrame

    arrow_table = pa.RecordBatchStreamReader('/tmp/gpu.arrow').read_all()
    df = arrow_table.to_pandas()
    df = df[['swings', 'tractions']]
    df = DataFrame.from_pandas(df)
    print(df)
    return "done"

client = Client('127.0.0.1:8786')
#client.restart()

job = client.submit(collect_results, metaToken)
print(job.result())
