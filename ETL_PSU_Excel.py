
""" Script para extraer, transformar y exportar a motor de sql bases psu en excel

El siguiente script permite realizar un proceso de ETL a las bases PSU entregadas por casa central a la FEN, el cual
es un archivo excel con las personas convocadas a matricularse y en lista de espera.
"""

from sqlalchemy import create_engine
from class_PrepPsuExcel import PrepPsuExcel

# Ruta absoluta o relativa de la base deseada a procesoar
file_path = 'bases_excel/p19_fen.xlsx'

# Datos para generar la conexión a SQL Server
servername = 'localhost'
database = 'psu'
engine = create_engine(f'mssql://{servername}/{database}?trusted_connection=yes&driver=ODBC+Driver+13+for+SQL+Server')

# Diccionario con valores que se reconocen como equivalentes a datos nulos, según columna.
nan_dict = {
    'PTJE_RANKING': 0, 
    'PTJE_NEM': 0,
    'LENGUAJE_Y_COMUNICACION': 0,
    'MATEMATICA': 0, 
    'CIENCIAS': 0, 
    'HISTORIA_Y_CIENCIAS_SOCIALES': 0, 
    'LOCAL_EDUCACIONAL': 0, 
    'PROMEDIO_NOTAS': 0, 
    'UNIDAD_EDUCATIVA': 0, 
    'CODIGO_REGION': 0, 
    'CODIGO_PROVINCIA': 0, 
    'CODIGO_COMUNA': 0,
    'INGRESO_BRUTO_FAMILIAR': 0,
    'CODIGO_REGION_D': 0,
    'CODIGO_PROVINCIA_D': 0,
    'CODIGO_COMUNA_D': 0,
}

# Se instancia la clase para realizar proceso de ETL
df = PrepPsuExcel(file_path)
# Se aplican las transformaciones/preproceso
df.homolgate_columns_name()
df.replace_nan_values(nan_dict)
# Se exporta base a motor de sql
df.to_sql(f'{file_route[12:19]}', engine, if_exists='replace')

