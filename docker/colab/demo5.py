from blazingsql import BlazingContext
import cudf
bc = BlazingContext()

# Csv files
column_names = ['diagnosis_result', 'radius', 'texture', 'perimeter']
column_types = ['float32', 'float32', 'float32', 'float32']
bc.create_table('data_00', '/blazingdb/data/cancer_data_00.csv', delimiter=',', dtype=column_types, names=column_names)

# Parquet
column_names = ['perimeter', 'area', 'smoothness', 'compactness']
bc.create_table('data_01_parquet', '/blazingdb/data/cancer_data_01.parquet')
query_01 = bc.sql('SELECT * FROM main.data_01_parquet').get()
gdf_01 = query_01.columns
bc.create_table('data_01', gdf_01)

# Gdf
column_names = ['compactness', 'symmetry', 'fractal_dimension']
column_types = ['float32', 'float32', 'float32', 'float32']
gdf_02= cudf.read_csv('/blazingdb/data/cancer_data_02.csv',delimiter=',', dtype=column_types, names=column_names)
bc.create_table('data_02', gdf_02)

# Query
sql = '''
SELECT a.*, b.area, b.smoothness, c.* from main.data_00 as a
LEFT JOIN main.data_01  as b
ON (a.perimeter = b.perimeter)
LEFT JOIN main.data_02 as c
ON (b.compactness = c.compactness)
'''
join = bc.sql(sql).get()
result = join.columns
print(result)

