from sqlalchemy import create_engine
from class_PrepPsuExcel import PrepPsuExcel

servername = 'localhost'
database = 'psu'
engine = create_engine('mssql://{}/{}?trusted_connection=yes&driver=ODBC+Driver+13+for+SQL+Server'.format(servername, database))
file_route = 'bases_excel/p19_fen.xlsx'

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

df = PrepPsuExcel(file_route)
df.homolgate_columns_name()
df.info()
df.replace_nan_values(nan_dict)
df.to_sql(f'{file_route[12:19]}', engine, replace_if_exist=True)

