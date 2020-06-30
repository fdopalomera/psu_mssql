""""
    TODO:
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

    Parameters
    ----------
    file_path : str
        Ruta absoluta o relativa de archivo Access a importar

    Attributes
    ----------
    tables: dict
        Diccionario con tablas de base PSU en pandas.DataFrame
    tables_name:
        Lista con nombre de las tablas presentes en el base PSU
    """

    def __init__(self, file_path):

        self.tables = self.get_tables(file_path)
        self.tables_name = list(self.tables.keys())

    @staticmethod
    def get_tables(file_path):
        """
        Importa las tablas de la base PSU de Access en DataFrames de pandas y las devuelve en un diccionario

        Parameters
        ----------
        file_path : str
            Ruta absoluta o relativa de archivo Access a importar

        Returns
        -------
        dict
            Diccionario con tablas de base PSU en pandas.DataFrame
        """

        cursor = pyodbc.connect(r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=%s;' % file_path).cursor()
        tables_dict = dict()
        tables_name = [row.table_name for row in cursor.tables() if re.match('p1*', row.table_name)]

        for tab_name in tables_name:
            values = cursor.execute('SELECT * FROM {}'.format(tab_name))
            cols_name = [tup[0] for tup in cursor.description]
            tables_dict[tab_name] = pd.DataFrame.from_records(data=values, columns=cols_name)
            
        return tables_dict
    
    def clean_columns_name(self, print_results=False):
        """
        Corrige el nombre de las columnas con casos típicos encontrados en las bases PSU

        Parameters
        ----------
        print_results : bool, default False
            Sí se desea imprimir el reporte de cambios en el nombre de las columnas
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

    def compare_columns_name(self, table_name, columns_list, output='equals'):
        """
        Compara el nombre de las columnas de una tabla seleccionada con una lista

        Parameters
        ----------
        table_name : str
            Nombre de la tabla a realizar la comparación
        columns_list : list
            Lista con nombre de columnas a comparar con las presentes en la tabla seleccionada
        output : {'equal' or 'diff'}, default 'diff'
            Define el retorno de la comparación en columnas iguales ('equals') o diferentes ('diff')

        Returns
        -------
        list or pandas.DataFrame
            Devuelve columnas resultantes de la comparación
        """

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
            raise ValueError("Valor no admitido, seleccione 'diff' o 'equals'")

    def rename_columns(self, colname_dict):
        """
        Renombra las columnas de las tablas de la base PSU

        Parameters
        ----------
        colname_dict: dict
            Diccionario con la estructura {table_type: {old_colname1: colname1, ...}}
        -------
        """

        for tab_type in colname_dict.keys():
            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                self.tables[tab_name].rename(columns=colname_dict[tab_type], inplace=True)

    def tables_to_sql(self, engine, tables_list, type_list=True, if_exists='replace'):
        """
        Exporta las tablas seleccionadas en la base de datos establecida

        Parameters
        ----------
        engine: sqlalchemy.engine.Engine
            Objeto para generar la conexión a la base de datos de sql a exportar las tablas
        tables_list: list
            Tablas a
        type_list: bool, default True

        if_exists: {'replace' or 'fail' or 'append'}, default 'replace'
            Acción a realizarse si alguna tabla a exportarse se encuentra actualmente en la base de datos.

            * replace: Elimina la anterior antes de insertar la nueva
            * fail: Levanta un ValueError
            * append: Inserta los nuevos valores en la tabla existente
        """

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
        """
        Convierte los valores no numéricos en datos nulos.

        Parameters
        ----------
        dtypes_dict: dict
            Diccionario con la estructura {table_type: {numeric_col1: numeric_dtype1, ...}}
        """

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

        """
        Cambia el tipo de datos de las columnas seleccionadas.

        Parameters
        ----------
        dtypes_dict : dict
            Diccionario con la estructura {table_type: {col_name1: dtype1, ...}}
        """

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

        """
        Realiza las transformaciones requeridas a nivel de columnas.

        Parameters
        ----------
        transform_dict : dict
            Diccionario con la estructura {table_type: {col_name1: transformation1, ...}}
        """

        for tab_type in transform_dict.keys():
            expected_cols = list(transform_dict[tab_type].keys())

            for tab_name in [tab for tab in self.tables_name if '_{}'.format(tab_type) in tab]:
                found_cols = self.compare_columns_name(tab_name, expected_cols, output='equals')
                filtered_dict = {col: transform_dict[tab_type][col] for col in found_cols}

                for col, transformer in filtered_dict.items():
                    self.tables[tab_name].loc[:, col] = transformer(self.tables[tab_name][col])

    def replace_null_values(self, null_dict):

        """
        Reemplaza los valores establecidos como datos nulos por np.NaN.

        Parameters
        ----------
        null_dict : dict
             Diccionario con la estructura {table_type: {col_name1: null_value1, ...}}
        """

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
        """
        Exporta todas las tablas en la base de datos establecida.

        Parameters
        ----------
        engine: sqlalchemy.engine.Engine
            Objeto para generar la conexión a la base de datos de sql a exportar las tablas

        if_exists: {'replace' or 'fail' or 'append'}, default 'replace'
            Acción a realizarse si alguna tabla a exportarse se encuentra actualmente en la base de datos.

            * replace: Elimina la anterior antes de insertar la nueva
            * fail: Levanta un ValueError
            * append: Inserta los nuevos valores en la tabla existente
        """

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

        """
        Evalúa si el valor ingresado es numérico, retornando como float si es así o np.NaN en caso contrario.

        Parameters
        ----------
        x : str, int or float
            Valor a evaluar

        Returns
        -------
        float or np.NaN
            Sí el valor ingresado es un número, retorna un float. En caso contrario, retorna np.NaN

        """

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

        """
        Retorna el valor ingresado en el tipo de dato deseado

        Parameters
        ----------
        x : object
            Valor a convertir
        dtype : object
            Tipo de dato a convertir

        Returns
        -------
        int or float
        """

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

        """
        Si el valor es un string, retorna el string convirtiendo las comas por puntos

        Parameters
        ----------
        x : str or object
            Valor a evaluar

        Returns
        -------
        str or object
        """

        if isinstance(x, str):
            return x.replace(',', '.')
        else:
            return x






