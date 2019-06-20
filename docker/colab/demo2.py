import cudf
import pandas as pd
from blazingsql import BlazingContext

bc = BlazingContext()

column_names = ['n_nationkey', 'n_name', 'n_regionkey', 'n_comments']
column_types = {'n_nationkey': 'int32', 'n_regionkey': 'int64'}
nation_df = pd.read_csv("/blazingsql/data/nation.psv", delimiter='|',
                        dtype=column_types, names=column_names)
print(nation_df)

bc.create_table('nation', nation_df)
query = 'select n_nationkey, n_regionkey, n_nationkey + n_regionkey as addition from main.nation'
result_gdf = bc.sql(query).get()

print(query)
print(result_gdf)
