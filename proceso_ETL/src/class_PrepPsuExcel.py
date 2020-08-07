
import pandas as pd
import numpy as np


class PrepPsuExcel:
    """
    Clase para reolizar proceso de ETL para bases de PSU en Excel

    Parameters
    ----------
    file_path : str
        Ruta absoluta o relativa de archivo Excel a importar
    """

    def __init__(self, file_path):
        self.__base = pd.read_excel(file_path)
    
    def homolgate_columns_name(self):
        """
        Homoloaga el nombre de las columnas a las que se encuentran 
        en las tablas E de la bases en Access de la PSU
        """
        
        dict_colsname = {
            'LENG_Y_COM': 'LENGUAJE_Y_COMUNICACION', 
            'HIST_CS_SOC': 'HISTORIA_Y_CIENCIAS_SOCIALES',
            'ING_BRUTO_FAMILIAR': 'INGRESO_BRUTO_FAMILIAR'
            }
        
        new_cols_name = self.__base.rename(columns=dict_colsname).columns
        new_cols_name = [x.replace('NY', 'Ñ') for x in new_cols_name]
        new_cols_name = [x.replace(' ', '') if x[-1] == ' ' else x.replace(' ', '_')   for x in new_cols_name]
        
        diff1 = set(self.__base.columns) - set(new_cols_name)
        diff2 = set(new_cols_name) - set(self.__base.columns)
        if diff1 == diff2:
            print('No hubo cambios')
        else:
            # Actualizar nombre de columnas
            self.__base.columns = new_cols_name
            # Imprimir columnas cambiadas
            print('{} to {}'.format(diff1, diff2))

    def replace_nan_values(self, nan_dict):

        """
        Reemplaza los valores establecidos como datos nulos por np.NaN.

        Parameters
        ----------
        nan_dict : dict
             Diccionario con la estructura {col_name1: null_value1, ...}}
        """
        
        nan_before = self.__base.isnull().sum()
        self.__base = self.__base.replace(to_replace=nan_dict, value=np.NaN)
        nan_after = self.__base.isnull().sum()
        nan_diff = (nan_after - nan_before)[list(nan_dict.keys())]
        nan_diff.name = 'added_nan_values'
        print(nan_diff)
            
    def to_sql(self, table_name, engine, if_exists='replace'):
        """
        Exporta la tabla la base de datos establecida.

        Parameters
        ----------
        table_name: str
            Nombre de la tabla a exportar

        engine: sqlalchemy.engine.Engine
            Objeto para generar la conexión a la base de datos de sql a exportar las tablas

        if_exists: {'replace' or 'fail' or 'append'}, default 'replace'
            Acción a realizarse si alguna tabla a exportarse se encuentra actualmente en la base de datos.

            * replace: Elimina la anterior antes de insertar la nueva
            * fail: Levanta un ValueError
            * append: Inserta los nuevos valores en la tabla existente
        """
       
        self.__base.to_sql(table_name, engine, if_exists=if_exists, index=False)