""""
    TODO: replace_nan_values: reemplazar valores nulos en tabla b
                              revisar existencia de columnas (LISTO)
        - resolver problema de 3 últimas filas al imputar datos (BORRAR FILAS NULAS?)
"""
import pyodbc
import re
import pandas as pd
import numpy as np
from time import time


class PrepPsuAccess:
    """
    Clase para reolizar proceso de ETL para bases de PSU en Access
    """

    def __init__(self, file_path):
        
        self.file_path = file_path
        self.conn = pyodbc.connect(r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=%s;' %file_path)
        self.cursor = self.conn.cursor()
        self.tables = self.get_tables()
        self.tables_name = list(self.tables.keys())
        
    def get_tables(self):
        """
        Importa las tablas de la base PSU en DataFrames de pandas y las devuelve en un diccionaario
        :return
            {dict} diccionario con elementos de forma {nombre_tabla, Pandas_DataFrame}
        """
        
        tables_dict = dict()
        tables_name = [row.table_name for row in self.cursor.tables() if re.match('p1*', row.table_name)]
        for tab_name in tables_name:
            values = self.cursor.execute('SELECT * FROM {}'.format(tab_name))
            cols_name = [tup[0] for tup in self.cursor.description]
            tables_dict[tab_name] = pd.DataFrame.from_records(data=values, columns=cols_name)
            
        return tables_dict
    
    def clean_columns_name(self, print_results=True):
        """
        Corrige el nombre de las columnas con casos típicos encontrados en las bases PSU
        """
        for tab_name in self.tables_name:

            cols_name = self.tables[tab_name]
            # Reemplazo de 'NY' por 'Ñ'
            new_cols_name = [x.replace('NY', 'Ñ') for x in cols_name]
            # Reemplazo de espacios vacíos, dependiendo de posición en el string
            new_cols_name = [x.replace(' ', '') if x[-1] == ' ' else x.replace(' ', '_') for x in new_cols_name]

            # Evaluar cambios
            diff1 = set(cols_name) - set(new_cols_name)
            diff2 = set(new_cols_name) - set(cols_name)
            if diff1 == diff2:
                if print_results:
                    print('En {} no hubo cambios'.format(tab_name))
            else:
                # Actualizar nombre de columnas
                self.tables[tab_name].columns = new_cols_name
                # Imprimir columnas cambiadas
                if print_results:
                    print(f'For {tab_name}\ncols {diff1}\nconverted to\n cols{diff2}\n')

    def replace_nan_values(self, nan_dict):

        """"
        Por ahora solo columna e
        """

        # Reemplazo de valores nulos en tabla e
        for tab_name in [x for x in self.tables_name if '_e' in x]:

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

        elif output == 'equals':
            intersect = list_cols & real_cols

            return list(intersect)
        else:
            raise ValueError('Not defined')

    def compare_multiple_columns(self, column_list, table_type='_e'):

        """
        Compara distintas tablas de un tipo establecido
        :param table_type: str
                    Tipo de tabla PSU, ejemplo: '_e'
        :param column_list: list
                    Columnas a comparar con tablas
        :return:
        """

        for tab_name in [x for x in self.tables_name if table_type in x]:

            tmp = self.compare_columns_name(tab_name, column_list)
            if tmp is not None:
                print('{}:\n{}\n'.format(tab_name, tmp))

    def rename_columns(self, colname_dict):

        for tab_type in colname_dict.keys():
            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                self.tables[tab_name].rename(columns=colname_dict[tab_type], inplace=True)

    def tables_to_sql(self, engine, tables_list, type_list=True, if_exists='replace'):

        """Carga todas las tablas del tipo de tabla procesadas en la base de datos establecida"""

        start = time()
        if type_list:
            for tab_type in tables_list:
                for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                    self.tables[tab_name].to_sql(tab_name, engine, if_exists=if_exists, index=False)
        else:
            for tab_name in tables_list:
                self.tables[tab_name].to_sql(tab_name, engine, if_exists=if_exists, index=False)

        end = time()
        hours, rem = divmod(end - start, 3600)
        minutes, seconds = divmod(rem, 60)
        print("{:0>2}:{:0>2}:{:05.2f}".format(int(hours), int(minutes), seconds))

    def remove_numeric_dirtydata(self, dtypes_dict):

        for tab_type in dtypes_dict.keys():

            expected_cols = list(dtypes_dict[tab_type].keys())

            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:

                found_cols = self.compare_columns_name(tab_name, expected_cols, output='equals')
                filtered_dict = {col: dtypes_dict[tab_type][col] for col in found_cols}

                for col, dtype in filtered_dict.items():

                    # Reemplazar separador decimal
                    self.tables[tab_name].loc[:, col] = self.tables[tab_name][col].map(lambda x: self._conv_decsep(x))
                    # Eliminar strings con valores no númericos
                    self.tables[tab_name].loc[:, col] = self.tables[tab_name][col].map(lambda x: self._rm_nonumeric(x))
                    # Convertir tipo de datos de string a númerico
                    self.tables[tab_name].loc[:, col] = self.tables[tab_name][col].map(lambda x: self._conv_dtype(x, dtype))

    def remove_numcol_dirtydata(self, tab_name, numeric_dict):

        """Limpia los valores de columnas de naturaleza númerica"""

        for col, dtype in numeric_dict.items():
            # Reemplazar separador decimal
            self.tables[tab_name].loc[:, col] = self.tables[tab_name][col].map(lambda x: self._conv_decsep(x))
            # Eliminar strings con valores no númericos
            self.tables[tab_name].loc[:, col] = self.tables[tab_name][col].map(lambda x: self._rm_nonumeric(x))
            # Convertir tipo de datos de string a númerico
            self.tables[tab_name].loc[:, col] = self.tables[tab_name][col].map(lambda x: self._conv_dtype(x, dtype))

    def change_column_dtype(self, dtypes_dict):

        """Cambia el tipo de datos de las columnas seleccionadas"""

        for tab_type in dtypes_dict.keys():
            expected_cols = list(dtypes_dict[tab_type].keys())

            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                found_cols = self.compare_columns_name(tab_name, expected_cols, output='equals')
                filtered_dict = {col: dtypes_dict[tab_type][col] for col in found_cols}

                #Revisar uso de value
                for col, dtype in filtered_dict.items():
                    #self.remove_numcol_dirtydata(tab_name, filtered_dict)
                    # Cambiar el tipo de dato
                    self.tables[tab_name].loc[:, col] = pd.to_numeric(self.tables[tab_name][col], errors='coerce')

                print(self.tables[tab_name].info())

    def transform_col(self, transform_dict):

        """Realiza las transformaciones requeridas a nivel de columnas"""

        for tab_type in transform_dict.keys():
            expected_cols = list(transform_dict[tab_type].keys())

            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                found_cols = self.compare_columns_name(tab_name, expected_cols, output='equals')
                filtered_dict = {col: transform_dict[tab_type][col] for col in found_cols}

                for col, transformer in filtered_dict.items():
                    self.tables[tab_name].loc[:, col] = transformer(self.tables[tab_name][col])

    def replace_null_values(self, null_dict):

        """Reemplaza los valores establecidos como datos nulos por np.NaN"""

        for tab_type in null_dict.keys():
            # Revisar si es necesario comparar valores nulos
            expected_cols = list(null_dict[tab_type].keys())

            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                found_cols = self.compare_columns_name(tab_name, expected_cols, output='equals')
                filtered_dict = {col: null_dict[tab_type][col] for col in found_cols}
                # Reemplazar valores nulos
                self.tables[tab_name].replace(to_replace=null_dict[tab_type],
                                             value=np.NaN,
                                             inplace=True)

    def to_sql(self, engine, if_exists='replace'):

        """Carga todas las tablas procesadas en la base de datos establecida"""

        start = time()
        # Para cada tabla en la base cargada en in la instancia
        for tab_name in self.tables_name:
            # Carga de la tabla en la base de sql
            self.tables[tab_name].to_sql(tab_name,
                                         engine,
                                         if_exists=if_exists,
                                         index=False)
        # Tracking del tiempo necesitado para realizar la exportación
        end = time()
        hours, rem = divmod(end - start, 3600)
        minutes, seconds = divmod(rem, 60)
        print("{:0>2}:{:0>2}:{:05.2f}".format(int(hours), int(minutes), seconds))

    # A continuación se definen static methods utiliizados en instance methods anteriormente definidos
    @staticmethod
    def _rm_nonumeric(x):

        """Evalua si el valor ingresado es númerico, retornandolo como float si es así o np.NaN en caso contrario"""

        if pd.isna(x):
            return np.NaN
        else:
            try:
                float(x)
                return x
            except:
                return np.NaN

    @staticmethod
    def _conv_dtype(x, dtype):

        """Retorna el valor ingresado en el tipo de dato deseado"""

        if pd.isna(x):
            return np.NaN
        else:
            if dtype is int:
                return int(x)
            elif dtype is float:
                return float(x)
            else:
                raise ValueError('Problema con valor {} de tipo {}'.format(x, type(x)))

    @staticmethod
    def _conv_decsep(x):

        """Si el valor es un string, retorna el string convirtiendo las comas por puntos"""

        if isinstance(x, str):
            return x.replace(',', '.')
        else:
            return x






