import pandas as pd
import numpy as np

"""
Heredar todos los métodos de DataFrame?

"""

class PrepPsu:

    def __init__(self, file_route):
        self.__base = pd.read_excel(file_route)
        
    def coumns(self):        
        return self.__base.columns 
    
    def info(self): 
        return self.__base.info() 
    
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
        
        nan_before = self.__base.isnull().sum()
        self.__base = self.__base.replace(to_replace=nan_dict, value=np.NaN)
        nan_after = self.__base.isnull().sum()
        nan_diff = (nan_after - nan_before)[list(nan_dict.keys())]
        nan_diff.name = 'added_nan_values'
        print(nan_diff)

    def clean_columns_name(self, old_value, new_value):
        
        new_cols_name = [x.replace(old_value, new_value) for x in self.__base.columns]
        diff1 = set(self.__base.columns) - set(new_cols_name)
        diff2 = set(new_cols_name) - set(self.__base.columns)
        if diff1 == diff2:
            print('No hubo cambios')
        else:
            # Actualizar nombre de columnas
            self.__base.columns = new_cols_name
            # Imprimir columnas cambiadas
            print('{} to {}'.format(diff1, diff2))
            
    def to_sql(self, table_name, engine, replace_if_exist=False):
        
        action = 'fail'
        if replace_if_exist:
            action = 'replace'
       
        self.__base.to_sql(table_name, engine, if_exists=action, index=False)