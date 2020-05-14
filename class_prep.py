""""
    TODO: replace_nan_values: reemplazar valores nulos en tabla b
                              revisar existencia de columnas (LISTO)
        - resolver problema de 3 últimas filas al inputar datos (BORRAR FILAS NULAS?)
"""
import pyodbc
import re
import pandas as pd
import numpy as np
from sqlalchemy.types import String, Integer, Float


def rm_nonumeric(x):
    if pd.isna(x):
        return np.NaN
    else:
        try:
            float(x)
            return x
        except:
            return np.NaN


def conv_dtype(x, sql_dtype):
    if sql_dtype is Integer:
        return int(X)
    if sql_dtype is Float:
        return float(x)

class PrepPsuAccess:

    def __init__(self, file_path):
        
        self.file_path = file_path
        self.conn = pyodbc.connect(r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=%s;' %file_path)
        self.cursor = self.conn.cursor()
        self.tables = self.get_tables()
        self.tables_name = list(self.tables.keys())
        
    def get_tables(self):
        
        tables_dict = dict()
        tables_name = [row.table_name for row in self.cursor.tables() if re.match('p1*', row.table_name)]
        for tab_name in tables_name:
            values = self.cursor.execute('SELECT * FROM {}'.format(tab_name))
            cols_name = [tup[0] for tup in self.cursor.description]
            tables_dict[tab_name] = pd.DataFrame.from_records(data=values, columns=cols_name)
            
        return tables_dict
    
    def clean_columns_name(self):
        for tab_name in self.tables_name:

            cols_name = self.tables[tab_name]
            # Reemplazo de 'NY' por 'Ñ'
            new_cols_name = [x.replace('NY', 'Ñ') for x in cols_name]
            # Reemplazo de espacios vacíos, dependiendo de posición en el string
            new_cols_name = [x.replace(' ', '') if x[-1] == ' ' else x.replace(' ', '_') for x in new_cols_name]

            diff1 = set(cols_name) - set(new_cols_name)
            diff2 = set(new_cols_name) - set(cols_name)
            if diff1 == diff2:
                print('En {} no hubo cambios'.format(tab_name))
            else:
                # Actualizar nombre de columnas
                self.tables[tab_name].columns = new_cols_name
                # Imprimir columnas cambiadas
                print('For {}\ncols {}\nconverted to\n cols{}\n'.format(tab_name, diff1, diff2))

    def replace_nan_values(self, nan_dict):

        """"
        Por ahora solo columna e
        """

        # Reemplazo de valores nulos en tabla e
        for tab_name in [x for x in self.tables_name if x.__contains__('_e')]:

            nan_before = self.tables[tab_name].isnull().sum()
            self.tables[tab_name] = self.tables[tab_name].replace(to_replace=nan_dict, value=np.NaN)
            nan_after = self.tables[tab_name].isnull().sum()
            # Revisar
            nan_diff = (nan_after - nan_before)[list(nan_dict.keys())]
            nan_diff.name = 'added_nan_values'
            print('Valores reemplazados en {}:\n{}\n'.format(tab_name, nan_diff))

    def get_columns_name(self, table_name, vertical_print=True):

        if vertical_print:
            print('\n'.join(self.tables[table_name].columns))
        else:
            return list(self.tables[table_name].columns)

    def compare_columns_name_deprecated(self, table_name, columns_list):

        real_cols = pd.Series(sorted(self.tables[table_name].columns))
        list_cols = pd.Series(sorted(columns_list))

        tmp = pd.DataFrame({'real_cols': real_cols, 'list_cols': list_cols})
        tmp['equal'] = tmp['real_cols'] == tmp['list_cols']

        array = tmp['equal'].to_numpy()

        if (array[0] == array[1:]).all():
            print('{} con columnas iguales!'.format(table_name))
        else:
            return tmp

    def compare_columns_name(self, table_name, columns_list, output='diff'):

        list_cols = set(columns_list)
        real_cols = set(self.tables[table_name].columns)

        if output == 'diff':
            diff1 = list_cols - real_cols
            diff2 = real_cols - list_cols

            if (diff1 == set()) & (diff2 == set()):
                print('{}: todas las columnas iguales!\n'.format(table_name))
            else:
                a = pd.Series(sorted(list(diff1)))
                b = pd.Series(sorted(list(diff2)))

                return pd.DataFrame({'list_cols': a, 'real_cols': b})

        if output == 'equals':
            intersect = list_cols & real_cols

            return list(intersect)

    def compare_multiple_columns(self, column_list, table_type='_e'):

        """
        Compara distintas tablas de un tipo establecido
        :param table_type: str
                    Tipo de tabla PSU, ejemplo: '_e'
        :param column_list: list
                    Columnas a comparar con tablas
        :return:
        """

        for tab_name in [x for x in self.tables_name if x.__contains__(table_type)]:

            tmp = self.compare_columns_name(tab_name, column_list)
            if tmp is not None:
                print('{}:\n{}\n'.format(tab_name, tmp))

    def change_columns_name(self, table_name, columns_dict):

        self.tables[table_name].rename(columns=columns_dict)

    def table_to_sql(self, engine, tab_name, dtype_dict=None, if_exists='fail'):

        if dtype_dict is None:
            self.tables[tab_name].to_sql(tab_name, engine, if_exists=if_exists, index=False)
        else:
            self.tables[tab_name].to_sql(tab_name, engine, if_exists=if_exists, index=False, dtype=dtype_dict)

    def to_sql(self, engine, dtypes_dict, auto_rw_dict='add', if_exists='replace'):

        # TODO: dict(tab_name:'add', tab2, 'drop'))
        exported_tables = []
        for tab_type in dtypes_dict.keys():

            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                tmp_df = self.compare_columns_name(tab_name, list(dtypes_dict[tab_type].keys()))
                # Dict temporal de dtypes
                tmp_dict = dtypes_dict[tab_type]

                if tmp_df is not None:
                    # Remover campos esperados y no encontrados por el diccionario
                    [tmp_dict.pop(key) for key in tmp_df['list_cols'].to_list()]

                    if auto_rw_dict == 'drop':
                        drop_cols = tmp_df['real_cols'].to_list()
                        print('En {} columnas originales eliminadas: \n{}\n'.format(tab_name, drop_cols))

                    elif auto_rw_dict == 'add':
                        added_cols = tmp_df['real_cols'].to_list()
                        [tmp_dict.update({key, String(255)}) for key in tmp_df['list_cols']]
                        print('En {} columnas originales agregadas: \n{}\n'.format(tab_name, added_cols))
                    else:
                        raise ValueError('Invalid Value {} for \"auto_rw_dict\"'.format(auto_rw_dict))
                # Carga de la tabla en la base de sql
                self.tables[tab_name].to_sql(tab_name,
                                             engine,
                                             if_exists=if_exists,
                                             index=False,
                                             dtype=tmp_dict)
                exported_tables.append(tab_name)
        # Exportar con formato automático (VARCHAR) tablas restantes
        for tab_name in [tab_name for tab_name in self.tables_name if tab_name not in exported_tables]:
            self.tables[tab_name].to_sql(tab_name,
                                         engine,
                                         if_exists=if_exists,
                                         index=False)

    def remove_numeric_dirtydata(self, dtypes_dict):

        for tab_type in dtypes_dict.keys():
            expected_cols = list(dtypes_dict[tab_type].keys())

            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                found_cols = self.compare_columns_name(tab_name, expected_cols, output='equals')
                filtered_dict = {col: dtypes_dict[col] for col in found_cols}
                numeric_cols = [col for col, dtype in filtered_dict.items()
                                if isinstance(dtype, (Integer, Float))]
                numeric_dict = {col: filtered_dict[col] for col in numeric_cols}

                for col, dtype in numeric_dict:
                    # Reemplazar separador decimal
                    self.tables[tab_name][col] = self.tables[tab_name][col].map(lambda x: x.replace(',', '.'))
                    # Eliminar strings con valores no númericos
                    self.tables[tab_name][col] = self.tables[tab_name][col].map(lambda x: rm_nonumeric(x))
                    # Convertir tipo de datos de string a númerico
                    self.tables[tab_name][col] = self.tables[tab_name][col].map(lambda x: conv_dtype(x, dtype))



