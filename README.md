# Proceso de ETL y diseño de Vista para bases PSU

## Tabla de Contenidos

- [Tabla de Contenidos](#tabla-de-contenidos)
- [Acerca del Proyecto](#acerca-del-proyecto)
- [Objetivos](#objetivos)
    - [Generales](#generales)
    - [Específicos](#especficos)
- [Herramientas Utilizadas](#herramientas-utilizadas)
- [Cómo Usar](#cómo-usar)
- [Memoria de Cálculo](#memoria-de-cálculo)
    - [Campos de la Vista](#campos-de-la-vista)
    - [Detalles a considerar](#detalles-a-considerar)

## Acerca del Proyecto

Proyecto que busca facilitar la disponibilidad de la información de los alumnos y postulantes a la FEN que se encuentra 
en las bases PSU. Para lograrlo, se diseñó un proceso de ETL para extraer, limpiar y exportar a una base de datos local 
las tablas referidas a la PSU, para luego generar una vista a partir de estas que congregue la información de distintos 
procesos, mostrando y calculando los principales campos utilizados en reportes e investigaciones de la SEE.

## Objetivos

### Generales

* Crear un proceso de ETL que importe bases PSU provenientes de archivos Access o Excel, limpie la data y luego exporte
a una base de datos de SQL Server.
* Generar una Vista de SQL, que reúna la información de postulantes a la FEN de distintos años del proceso, visualizando 
la información más utilizada o requerida.

### Específicos 

* En las bases originales hay muchos campos que tienen el valor '0' como valor nulo, lo que ensucia los cálculos 
agregados como el promedio, y que fueron reemplazados por valores nulos (NULL) en el proceso de ETL junto a otros 
caracteres alfanuméricos donde debía haber solo dígitos. Ej: Año: 202s -> NULL
* En la vista, homogeneizar el nombre de las columnas  y valores con la nomenclatura que tiene actualmente SAD, para poder cruzar 
información de la base PSU con la de SAD sin necesidad de otras transformaciones. 
Ej: Columnas `RUT` y `DV` de la base PSU se transforma a columna `Cod_Persona` como se encuentra en SAD, o el caso de 
valores 'BEA' se convierten a 'BEA 5% SUPERIOR'.

## Bitácora

* Hasta Agosto 2020, se cuenta con 4 bases de Access, correspondientes al periodo 2015-2018, con al menos la 
`tabla_e` (Postulaciones) correspondiente a los alumnos que fueron convocados por PSU. Dependiendo del año, 
se cuenta con más o menos `tablas_e` que pertenecen a los chic@s que entran por otros sistemas de ingresos 
(ej: 'SIPEE', 'SIDD', 'SIEG' , 'PACE'). Este punto igual es importante mencionar, dado que muchas veces los alumnos 
de ingresos especiales

## Herramientas Utilizadas

* [SQL_Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
* [SQL](https://code.visualstudio.com/download)
* [Python](https://marketplace.visualstudio.com/items?itemName=kaishuu0123.vscode-erd-preview)

## Instalación

1) Descargar e instalar SQL Server 2019 Developer (free)
2.1) Si se utiliza Anaconda o Miniconda , Instalar las siguientes librerías 
- Usando Conda
```sh
conda install numpy pandas pyodbc
```
- Usando PIP
```sh
pip install numpy pandas pyodbc
```
2.2) Alternativamente, puede usar un ambiente virtual de Python
```sh
python -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install requirements.txt
```
## Etapas proceso ETL

1) Importación de bases a ambiente de Python
2) Aplicar transformaciones
3) Exportar tablas a BBDD de motor de SQL Server local
4) Generar Vista con script
5) (OPCIONAL) Exportar Vista a excel u otro tipo de archivo para su distribución

## Cómo Usar

### Cruzar columnas con SAD
* Como puede que un alumno tenga postulaciones en distintos carreras de la FEN, en la misma carrera a través de 
distintos tipos de ingresos o pudiendo (en los más raros casos) quedar convocado en 2 carreras a la vez, se puede 
realizar el cruce de información con SAD a través de los siguientes 4 campos: `Cod_Persona`, `Año_Proceso` (Con el campo
`LEFT(Sem_IngresoDecreto, 4` de SAD), `Tipo_Alumno` y `Tipo_Ingreso`.

## Memoria de Cálculo

### Campos de la Vista

* __Cod_Persona__: Rut o número de documento de identificación de la persona que realiza la postulación.
* __Año_Proceso__: Año del proceso de selección universitaria en el cual la postulación es realizada.
* __Tipo_Alumno__: Carrera de la FEN (IC, CA, IICG) escogida para postular.
* __Tipo_Ingreso__: Tipo de Ingreso a la cual la postulación está referida. Ej: PSU, PACE, SIPEE, etc.
* __Estado_Postulacion__: Clasificación del resultado de la postulación, pudiendo ser "CONVOCADO" o en "LISTA ESPERA"
* __PreferenciaPostulacion__: Lugar de preferencia que el postulante asignó a la postulación.
* __PuntajeIngreso__: Puntaje promedio ponderado de los puntajes PSU del postulante según 
* __Ptje_PSU_Matematica__: Puntaje obtenido en la Prueba de Mátemtica.
* __Ptje_PSU_Lenguaje__: Puntaje obtenido en la Prueba de Lenguaje y Comunicación.
* __Ptje_Ranking__: Puntaje obtenido a través de la posición relativa del alumno con respecto a su generación de egreso
(y pasadas) de egreso del colegio.
* __Utiliza_Ptje_Anterior__: Determina si el puntaje de postulación proviene del actual proceso o del año anterior.
* __Sexo__: Género del postulante.
* __Ing_Bruto_Familiar__: Tramo de ingresos en el cual el estudiante declara que pertenece su familia.
* __Domicilio_Cod_Comuna__: Código de la comuna en la que se encontraba su domicilio al momento de realizar la 
postulación.
* __Local_Educacional__: Código del local educacional.
* __Unidad_Educativa__: Código de la unidad educativa.
* __Grupo_Dependencia__: Según la entidad que depende y es administrado el colegio, se clasifica en: Municipal,
Particular Subvencionado o Particular Pagado.
* __Colegio_Cod_Comuna__: Código de la comuna en la que se encuentra el colegio donde el o la postulante realizó su 
último año de enseñanza media.
* __Colegio_PSU_Alumnos__: Cantidad de estudiantes del colegio del postulante que rindieron la psu el año del proceso 
en que la postulación fue realizada.
* __Colegio_PSU_Mate__: Puntaje promedio obtenido en la prueba de matemáticas por los estudiantes del colegio del 
postulante, que rindieron la psu el año del proceso en que la postulación fue realizada.
* __Colegio_PSU_Leng__: Puntaje promedio obtenido en la prueba de lenguaje por los estudiantes del colegio del 
postulante, que rindieron la psu el año del proceso en que la postulación fue realizada.
* __Colegio_Notas_EM__: Notas de enseñanza media promedio de los estudiantes del colegio del 
postulante, que rindieron la psu el año del proceso en que la postulación fue realizada.

### Detalles a considerar
* Como puede ser posible que un postulante `en lista de espera haya ingresado la FEN, ell@s también se encuentran en la 
vista.
*  Originalmente a los alumnos que ingresan postulan por el PACE se les calcula un puntaje PSU ponderado distinto al
común, dado que ponderan otras variables propias de este sistema de ingreso. En las vista de sql, se recalculó con la 
ponderación que al año 2020 se tiene: 50% Matemática, 10% Lenguaje, 10% Ciencias o Historia, 20% Ranking y 10% NEM.
* `Ingreso Bruto Familiar presenta distintas escalas dependiendo del año del proceso.

## Contribuyentes

* Fernando Palomera  - [https://github.com/fdopalomera](https://github.com/fdopalomera)