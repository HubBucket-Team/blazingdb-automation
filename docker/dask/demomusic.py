import cudf
import pyblazing
from blazingsql import BlazingContext

pyblazing.SetupOrchestratorConnection('127.0.0.1', 8889)

bc = BlazingContext()

column_names = ['ARTIST','RATING','YEAR','LOCATION','FESTIVAL_SET']
bc.create_table('music', '/home/jupyter/Music.csv', delimiter=',',names=column_names)
# Create table


# Query
result = bc.sql('SELECT * FROM main.music')
