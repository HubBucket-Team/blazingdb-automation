import cudf
from blazingsql import BlazingContext
import pyblazing
from pyblazing import EncryptionType

#pyblazing.SetupOrchestratorConnection('blazingdb-dask-scheduler-svc', 8889)

bc = BlazingContext()
#authority = "tpch_s3"
#bc.s3(authority, bucket_name='blazingsql-bucket', access_key_id='AKIAJGB3SR3IXU3TE5WA', secret_key='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')
bc.s3('tpch_s3', bucket_name='blazingsql-colab', encryption_type=EncryptionType.NONE, access_key_id='AKIAJGB3SR3IXU3TE5WA', secret_key='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')
