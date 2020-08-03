# Proceso de ETL para bases PSU

## Tabla de Contenidos

- [Tabla de Contenidos](#tabla-de-contenidos)
- [Acerca del Proyecto](#acerca-del-proyecto)
- [Herramientas Utilizadas](#herramientas-utilizadas)
- [Cómo Usar](#cómo-usar)
- [Memoria de Cálculo](#memoria-de-cálculo)

## Acerca del Proyecto

<--! ![Esquema_Vistas](?raw=true) -->


## Objetivos
* Generar una Vista 
* Homogeneizar el nombre de las columnas  y valores con la nomenclatura que tiene actualmente SAD, para poder cruzar 
información de la base PSU con la de SAD sin necesidad de otras transformaciones. 
Ej: Columnas `RUT` y `DV` de la base PSU se transforma a columna `Cod_Persona` como se encuentra en SAD, o el caso de 
valores 'BEA' se convierten a 'BEA 5% SUPERIOR'.
* En las bases originales hay muchos campos que tienen el valor '0' como valor nulo, lo que ensucia los cálculos 
agregados como el promedio, y que fueron reemplazados por valores nulos (NULL) en el proceso de ETL junto a otros 
caracteres alfanuméricos donde debía haber solo dígitos. Ej: Año: 202s -> NULL
* Generar una Vista 

## Bitácora

* Hasta Agosto 2020, se cuenta con 4 bases de Access, correspondientes al periodo 2015-2018, con al menos la 
`tabla_e` (Postulaciones) correspondiente a los alumnos que fueron convocados por PSU. Dependiendo del año, 
se cuenta con más o menos `tablas_e` que pertenecen a los chic@s que entran por otros sistemas de ingresos 
(ej: 'SIPEE', 'SIDD', 'SIEG' , 'PACE'). Este punto igual es importante mencionar, dado que muchas veces los alumnos 
de ingresos especiales

Pueden filtrar por tipo de ingreso y ver cual hay por periodo agrupando por 'Año_Proceso',  'Tipo_Ingreso'.
## Herramientas Utilizadas

* [SQL_Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
* [SQL](https://code.visualstudio.com/download)
* [Python](https://marketplace.visualstudio.com/items?itemName=kaishuu0123.vscode-erd-preview)

## Instalación

1) Descargar e instalar SQL Server 2019 (o el de preferencia) Developer (free)
2) Descargar e instalar Anaconda
3) Instalar las siguientes librerías 
- Usando Conda
```sh
conda install pandas pyodbc
```
- Usando PIP
```sh
pip install pandas pyodbc
```
- Usando Requirements tx
## Etapas proceso ETL

1) Importación de bases a ambiente de Python
2) Aplicar transformaciones
3) Exportar tablas a BBDD de motor de SQL Server local
4) Generar Vista con script
5) OPCIONAL: Exportar Vista a excel u otro formato de archivo para su distribución

## Cómo Usar



## Vista PSU



### Cruzar columnas con SAD
* Como puede que un alumno tenga postulaciones en distintos carreras de la FEN, en la misma carrera a través de distintos tipos de ingresos o pudiendo (en los más raros casos) quedar convocado en 2 carreras a la vez, se puede realizar el cruzar información de SAD con el cruce de estos 4 campos: `Cod_Persona`, `Año_Proceso` (en SAD sería `LEFT(Sem_IngresoDecreto, 4`), `Tipo_Alumno` y `Tipo_Ingreso`.

### Recomendaciones para analistas


* Como puede ser posible que alguién en lista de espera haya ingresado la FEN, ell@s también se encuentran en esta base (Pueden filtrar con la columna 'Estado Postulación')


6.- A los alumnos que ingresan por el PACE se les calcula un puntaje ponderado distintos al común (que pondera otras variables propias del sistema de ingreso), por lo que se recalculó con la ponderación actual de los PSU.
7.- Es posible agregar más variables. Cómo todo el proceso de ETL está en script si encontráramos más bases (o las mismas pero con más información) puedo realizar el proceso, para lo cual debe comunicarse revisar el nombre del campo dentro de las tablas que se encuentran en las bases PSU.

## Memoria de Cálculo


<!-- Pendientes(Test) -->
<!-- Contribuyentes --->