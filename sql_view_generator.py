"""Generador de vista de bases PSU

Script para generar archivo .sql tipo 'vista' con las principales variables utilizadas en investigaciones
dentro de la FEN.
    
A través de la conexión al motor SQL Server que contiene la base de datos PSU, genera una query por cada proceso (año)
disponible, extrayendo la información con los nombres de columnas y valores homologados a los que se encuentran
actualmente en SAD (actualizado al 29/06/2020).
"""

import pyodbc


# Conexión a la base psu 
conn = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};'
                      'Server=localhost;'
                      'Database=psu;'
                      'Trusted_Connection=yes;')
# Creación del curso4
cursor = conn.cursor()

# Extraer el nombre de las tablas presentes en psu
cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_type = 'base table';")
tablas_base = cursor.fetchall()
tablas_base = [x[0] for x in tablas_base]

# Extraer los años disponibles de bases PSU (anterior a 2019)
psu_years = set([int(tab_name[1:3]) for tab_name in tablas_base])

# Definimos diccionario con nombre de tipo de ingreso
ing_dict = {
    'psu': 'PSU',
    'bea': 'BEA 5% SUPERIOR',
    'pace': 'PACE',
    'edt': 'ESCUELA DE TALENTOS',
    'sidd': 'DEPORTIVO',
    'sieg': 'EQUIDAD DE GÉNERO',
    'sipee': 'CUPO EQUIDAD'
}

view_query = ''
for year in psu_years:

    if year < 19:

        base = f'p{year}'
        # Identificamos las tablas correspondiente
        tab_a = base + '_a'
        tab_b = base + '_b'
        tab_c = base + '_c'
        # Identificamos las tablas e
        tablas_e = [tab_name for tab_name in tablas_base if (base in tab_name) & ('_e_' in tab_name)]

        # Inicio de la query
        view_query += """
            SELECT
                Cod_Persona,
                Año_Proceso,
                Tipo_Alumno,
                Tipo_Ingreso,
                Estado_Postulacion,
                PreferenciaPostulacion,
                PuntajeIngreso,
                Ptje_PSU_Matematica,
                Ptje_PSU_Lenguaje,
                Ptje_Ranking,
                Utiliza_Ptje_Anterior,
                Sexo,
                Ing_Bruto_Familiar,
                Domicilio_Cod_Comuna,
                f.Local_Educacional,
                f.Unidad_Educativa,
                Grupo_Dependencia,
                Colegio_Cod_Comuna,
                Colegio_PSU_Alumnos, 
                Colegio_PSU_Mate,
                Colegio_PSU_Leng,
                Colegio_Notas_EM
            FROM
                ("""
        # Iteramos por tablas e
        for tab_e in tablas_e:

            tipo_ingreso = ing_dict[tab_e[6:]]
            query_e = f"""
                SELECT 
                    RIGHT(e.NUMERO_DOCUMENTO, 9) AS Cod_Persona,
                    e.AÑO_PROCESO AS Año_Proceso, 
                    (CASE
                        WHEN CODIGO = '11026' THEN 'CA'
                        WHEN CODIGO = '11027' THEN 'IICG'
                        WHEN CODIGO = '11042' THEN 'IC'
                        END) AS Tipo_Alumno, 
                    (CASE
                        WHEN ESTADO_DE_POSTULACION = '24' THEN 'Convocado'
                        WHEN ESTADO_DE_POSTULACION = '25' THEN 'Lista de Espera'
                        END) AS Estado_Postulacion,
                    PREFERENCIA AS PreferenciaPostulacion, 
                    MATEMATICA AS Ptje_PSU_Matematica,
                    LENGUAJE_Y_COMUNICACION AS Ptje_PSU_Lenguaje,
                    PTJE_RANKING AS Ptje_Ranking,
                    e.LOCAL_EDUCACIONAL AS Local_Educacional,
                    e.UNIDAD_EDUCATIVA AS Unidad_Educativa,
                    (CASE
                        WHEN e.GRUPO_DEPENDENCIA = '1' THEN 'Particular Pagado'
                        WHEN e.GRUPO_DEPENDENCIA = '2' THEN 'Particular Subvencionado'
                        WHEN e.GRUPO_DEPENDENCIA = '3' THEN 'Municipal'
                        END) AS Grupo_Dependencia,
                    a.CODIGO_COMUNA AS Colegio_Cod_Comuna,
                    e.COD_COMUNA AS Domicilio_Cod_Comuna,
                    (CASE
                        WHEN POND_AÑO_ACAD = 1 THEN 0
                        WHEN POND_AÑO_ACAD = 2 THEN 1
                        END) AS Utiliza_Ptje_Anterior,
                    b.INGRESO_BRUTO_FAMILIAR AS Ing_Bruto_Familiar,
                    (CASE
                        WHEN e.SEXO = 1 THEN 'FEMENINO'
                        WHEN e.SEXO = 2 THEN 'MASCULINO'
                        END) AS Sexo,
                    e.PUNTAJE_PONDERADO AS PuntajeIngreso,
                    \'{tipo_ingreso}\' AS Tipo_Ingreso
                FROM 
                    {tab_e} AS e
                    LEFT JOIN 
                        {tab_b} AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        {tab_a} AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            """
            if tipo_ingreso == 'PACE':
                query_e = query_e.replace("""
                    (CASE
                        WHEN POND_AÑO_ACAD = 1 THEN 0
                        WHEN POND_AÑO_ACAD = 2 THEN 1
                        END) AS Utiliza_Ptje_Anterior,""", """         
                    1 AS Pond_Actual,""")
                query_e = query_e.replace("""e.PUNTAJE_PONDERADO AS PuntajeIngreso,""", """
                    ((e.PTJE_NEM * .1) + (e.PTJE_RANKING * .2) + 
                        (e.LENGUAJE_Y_COMUNICACION * .1) + (e.MATEMATICA * .5) +
                        ((CASE WHEN ISNULL(e.HISTORIA_Y_CIENCIAS_SOCIALES, 0) > ISNULL(e.CIENCIAS, 0)
                            THEN e.HISTORIA_Y_CIENCIAS_SOCIALES
                            ELSE e.CIENCIAS END) * .1)) AS PuntajeIngreso,""")
            # Únimos con query principal
            view_query += query_e

        # Eliminar último UNION ALL
        view_query = view_query[:-70]
        view_query += """
                ) AS f"""

        # Agregar información de colegios
        view_query += f"""
    
            LEFT JOIN
                (
                SELECT
                    LOCAL_EDUCACIONAL AS Local_Educacional, UNIDAD_EDUCATIVA AS Unidad_Educativa, 
                    -- Cuenta de Estudiantes que rindieron la PSU
                    COUNT(NUMERO_DOCUMENTO) AS Colegio_PSU_Alumnos, 
                    -- Promedio PSU Matemática
                    ROUND(AVG(PTJE_MATEMATICA_ACTUAL), 1) AS Colegio_PSU_Mate,
                    -- Promedio PSU Lenguaje
                    ROUND(AVG(PTJE_LENGUAJE_Y_COMUNICACION_ACTUAL), 1) AS Colegio_PSU_Leng,
                        -- Promedio Notas EM
                    ROUND(AVG(PROMEDIO_NOTAS), 2) AS Colegio_Notas_EM
                FROM
                    {tab_c}
                GROUP BY
                    LOCAL_EDUCACIONAL, UNIDAD_EDUCATIVA
                ) AS c
    
                ON f.Local_Educacional = c.Local_Educacional
                    AND f.Unidad_Educativa = c.Unidad_Educativa
    
            """

    else:
        tab_fen = f'p{year}_fen'

        view_query += f"""
            SELECT
                Cod_Persona,
                Año_Proceso,
                Tipo_Alumno,
                Tipo_Ingreso,
                Estado_Postulacion,
                PreferenciaPostulacion,
                PuntajeIngreso,
                Ptje_PSU_Matematica,
                Ptje_PSU_Lenguaje,
                Ptje_Ranking,
                Utiliza_Ptje_Anterior,
                Sexo,
                Ing_Bruto_Familiar,
                Domicilio_Cod_Comuna,
                f.Local_Educacional,
                f.Unidad_Educativa,
                Grupo_Dependencia,
                Colegio_Cod_Comuna,
                Colegio_PSU_Alumnos, 
                Colegio_PSU_Mate,
                Colegio_PSU_Leng,
                Colegio_Notas_EM
            FROM 
            (
            SELECT 
                CONCAT(NUMERO_DOCUMENTO, DV) AS Cod_Persona,
                AÑO_PROCESO AS Año_Proceso, 
                (CASE
                    WHEN CODIGO = 11026 THEN 'CA'
                    WHEN CODIGO = 11027 THEN 'IICG'
                    WHEN CODIGO = 11042 THEN 'IC'
                    END) AS Tipo_Alumno, 
                (CASE
                    WHEN ESTADO_DE_LA_POSTULACION = 24 THEN 'Convocado'
                    WHEN ESTADO_DE_LA_POSTULACION = 25 THEN 'Lista de Espera'
                    END) AS Estado_Postulacion,
                PREFERENCIA AS PreferenciaPostulacion, 
                MATEMATICA AS Ptje_PSU_Matematica,
                LENGUAJE_Y_COMUNICACION AS Ptje_PSU_Lenguaje,
                PTJE_RANKING AS Ptje_Ranking,
                LOCAL_EDUCACIONAL AS Local_Educacional,
                UNIDAD_EDUCATIVA AS Unidad_Educativa,
                (CASE
                    WHEN GRUPO_DEPENDENCIA = 1 THEN 'Particular Pagado'
                    WHEN GRUPO_DEPENDENCIA = 2 THEN 'Particular Subvencionado'
                    WHEN GRUPO_DEPENDENCIA = 3 THEN 'Municipal'
                    WHEN GRUPO_DEPENDENCIA = 4 THEN 'Servicio Local Educación'
                    END) AS Grupo_Dependencia,
                CODIGO_COMUNA AS Colegio_Cod_Comuna,
                CODIGO_COMUNA_D AS Domicilio_Cod_Comuna,         
                (CASE
                    WHEN POND_AÑO_ACAD = 1 THEN 0
                    WHEN POND_AÑO_ACAD = 2 THEN 1
                    END) AS Utiliza_Ptje_Anterior,
                INGRESO_BRUTO_FAMILIAR AS Ing_Bruto_Familiar,
                (CASE
                    WHEN SEXO = 1 THEN 'FEMENINO'
                    WHEN SEXO = 2 THEN 'MASCULINO'
                    END) AS Sexo,
                (CASE
                    WHEN VIA_INGRESO = 'PACE'
                        THEN (
                            (PTJE_NEM * .1) + (PTJE_RANKING * .2) + 
                            (LENGUAJE_Y_COMUNICACION * .1) + (MATEMATICA * .5) +
                            ((CASE WHEN ISNULL(HISTORIA_Y_CIENCIAS_SOCIALES, 0) > ISNULL(CIENCIAS, 0)
                                THEN HISTORIA_Y_CIENCIAS_SOCIALES
                            ELSE CIENCIAS END) * .1))
                    ELSE PUNTAJE_PONDERADO
                    END) AS PuntajeIngreso,
                (CASE 
                    WHEN VIA_INGRESO = 'BEA' THEN 'BEA 5% SUPERIOR'
                    WHEN VIA_INGRESO = 'SIEG' THEN 'EQUIDAD DE GÉNERO'
                    WHEN VIA_INGRESO = 'EDT' THEN 'ESCUELA DE TALENTOS'
                    WHEN VIA_INGRESO = 'SIPEE' THEN 'CUPO EQUIDAD'
                    WHEN VIA_INGRESO = 'SIDD' THEN 'DEPORTIVO'
                    WHEN VIA_INGRESO = 'EM EXTRANJERO' THEN 'CONVENIO EXTRANJERO'
                    ELSE VIA_INGRESO
                    END) AS Tipo_Ingreso,
                -- Información del Colegio
                NULL AS Colegio_PSU_Alumnos, 
                NULL AS Colegio_PSU_Mate,
                NULL AS Colegio_PSU_Leng,
                NULL AS Colegio_Notas_EM
            FROM 
                {tab_fen}
            ) AS f
        """
    view_query += """
            UNION ALL"""

# Eliminación de último UNION ALL
view_query = view_query[:-9]

view_query += """
            ORDER BY 
                Año_Proceso, Tipo_Alumno, Tipo_Ingreso DESC, Estado_Postulacion, PuntajeIngreso DESC               
            """

# Exportación a archivo sql
with open("view_query.sql", mode="w", encoding='utf-8') as text_file:
    text_file.write(view_query)
