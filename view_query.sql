
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
                    'BEA 5% SUPERIOR' AS Tipo_Ingreso
                FROM 
                    p15_e_bea AS e
                    LEFT JOIN 
                        p15_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p15_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'PSU' AS Tipo_Ingreso
                FROM 
                    p15_e_psu AS e
                    LEFT JOIN 
                        p15_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p15_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
      
                ) AS f
    
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
                    p15_c
                GROUP BY
                    LOCAL_EDUCACIONAL, UNIDAD_EDUCATIVA
                ) AS c
    
                ON f.Local_Educacional = c.Local_Educacional
                    AND f.Unidad_Educativa = c.Unidad_Educativa
    
            
            UNION ALL
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
                    'BEA 5% SUPERIOR' AS Tipo_Ingreso
                FROM 
                    p16_e_bea AS e
                    LEFT JOIN 
                        p16_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p16_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'PSU' AS Tipo_Ingreso
                FROM 
                    p16_e_psu AS e
                    LEFT JOIN 
                        p16_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p16_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
      
                ) AS f
    
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
                    p16_c
                GROUP BY
                    LOCAL_EDUCACIONAL, UNIDAD_EDUCATIVA
                ) AS c
    
                ON f.Local_Educacional = c.Local_Educacional
                    AND f.Unidad_Educativa = c.Unidad_Educativa
    
            
            UNION ALL
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
                    'BEA 5% SUPERIOR' AS Tipo_Ingreso
                FROM 
                    p17_e_bea AS e
                    LEFT JOIN 
                        p17_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p17_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'ESCUELA DE TALENTOS' AS Tipo_Ingreso
                FROM 
                    p17_e_edt AS e
                    LEFT JOIN 
                        p17_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p17_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    1 AS Pond_Actual,
                    b.INGRESO_BRUTO_FAMILIAR AS Ing_Bruto_Familiar,
                    (CASE
                        WHEN e.SEXO = 1 THEN 'FEMENINO'
                        WHEN e.SEXO = 2 THEN 'MASCULINO'
                        END) AS Sexo,
                    
                    ((e.PTJE_NEM * .1) + (e.PTJE_RANKING * .2) + 
                        (e.LENGUAJE_Y_COMUNICACION * .1) + (e.MATEMATICA * .5) +
                        ((CASE WHEN ISNULL(e.HISTORIA_Y_CIENCIAS_SOCIALES, 0) > ISNULL(e.CIENCIAS, 0)
                            THEN e.HISTORIA_Y_CIENCIAS_SOCIALES
                            ELSE e.CIENCIAS END) * .1)) AS PuntajeIngreso,
                    'PACE' AS Tipo_Ingreso
                FROM 
                    p17_e_pace AS e
                    LEFT JOIN 
                        p17_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p17_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'PSU' AS Tipo_Ingreso
                FROM 
                    p17_e_psu AS e
                    LEFT JOIN 
                        p17_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p17_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'DEPORTIVO' AS Tipo_Ingreso
                FROM 
                    p17_e_sidd AS e
                    LEFT JOIN 
                        p17_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p17_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'EQUIDAD DE GÉNERO' AS Tipo_Ingreso
                FROM 
                    p17_e_sieg AS e
                    LEFT JOIN 
                        p17_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p17_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'CUPO EQUIDAD' AS Tipo_Ingreso
                FROM 
                    p17_e_sipee AS e
                    LEFT JOIN 
                        p17_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p17_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
      
                ) AS f
    
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
                    p17_c
                GROUP BY
                    LOCAL_EDUCACIONAL, UNIDAD_EDUCATIVA
                ) AS c
    
                ON f.Local_Educacional = c.Local_Educacional
                    AND f.Unidad_Educativa = c.Unidad_Educativa
    
            
            UNION ALL
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
                    'BEA 5% SUPERIOR' AS Tipo_Ingreso
                FROM 
                    p18_e_bea AS e
                    LEFT JOIN 
                        p18_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p18_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    1 AS Pond_Actual,
                    b.INGRESO_BRUTO_FAMILIAR AS Ing_Bruto_Familiar,
                    (CASE
                        WHEN e.SEXO = 1 THEN 'FEMENINO'
                        WHEN e.SEXO = 2 THEN 'MASCULINO'
                        END) AS Sexo,
                    
                    ((e.PTJE_NEM * .1) + (e.PTJE_RANKING * .2) + 
                        (e.LENGUAJE_Y_COMUNICACION * .1) + (e.MATEMATICA * .5) +
                        ((CASE WHEN ISNULL(e.HISTORIA_Y_CIENCIAS_SOCIALES, 0) > ISNULL(e.CIENCIAS, 0)
                            THEN e.HISTORIA_Y_CIENCIAS_SOCIALES
                            ELSE e.CIENCIAS END) * .1)) AS PuntajeIngreso,
                    'PACE' AS Tipo_Ingreso
                FROM 
                    p18_e_pace AS e
                    LEFT JOIN 
                        p18_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p18_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
                
                UNION ALL
                    
            
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
                    'PSU' AS Tipo_Ingreso
                FROM 
                    p18_e_psu AS e
                    LEFT JOIN 
                        p18_b AS b
                        ON e.NUMERO_DOCUMENTO = b.NUMERO_DOCUMENTO
                    LEFT JOIN
                        p18_a AS a
                        ON e.AÑO_PROCESO = a.AÑO_PROCESO
                            AND e.LOCAL_EDUCACIONAL = a.LOCAL_EDUCATIVA
                            AND e.UNIDAD_EDUCATIVA = a.UNIDAD_EDUCATIVA
                WHERE
                    CODIGO IN ('11026', '11027', '11042')
                
      
                ) AS f
    
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
                    p18_c
                GROUP BY
                    LOCAL_EDUCACIONAL, UNIDAD_EDUCATIVA
                ) AS c
    
                ON f.Local_Educacional = c.Local_Educacional
                    AND f.Unidad_Educativa = c.Unidad_Educativa
    
            
            UNION ALL
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
                p19_fen
            ) AS f
        
            UNION ALL
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
                p20_fen
            ) AS f
        
            
            ORDER BY 
                Año_Proceso, Tipo_Alumno, Tipo_Ingreso DESC, Estado_Postulacion, PuntajeIngreso DESC               
            