@echo OFF
setlocal EnableDelayedExpansion

set PSQL=C:\Program Files\PostgreSQL\14\bin\psql.exe
SET PGCLIENTENCODING=UTF8
@chcp 65001

set DB_USER=
set PGPASSWORD=
set DB_HOST=
set DB_PORT=5432
set DB_NAME=bpm

set WFOLDER=files
set WFILE=filelist.csv
set BATCH_SZ=20
set TIMEOUT=10
set S3_URL=
set S3_BUCKET=
set AWS_ACCESS_KEY_ID=
set AWS_SECRET_ACCESS_KEY=

set TABLE_LIST=ContactFile KnowledgeBaseFile ActivityFile

@echo %data% %time% Create table
"%PSQL%" -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -A -q -c "CREATE TABLE public.migrate (id uuid NOT NULL, src varchar NULL)"

mkdir %WFOLDER%
for %%T in (%TABLE_LIST%) do (
	CALL :proc_table %%T > %WFOLDER%\%%T.log
)
EXIT /B

::===============================================================
:proc_table <TableName>
	echo %date% %time% Start processing %1
	set ITERAT = 1

	:CICLE
	"%PSQL%" -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -A -t -q -c "select t.""Id"" from public.""%1"" t LIMIT %BATCH_SZ%" -o %WFILE%
	for /F "usebackq tokens=*" %%I in ("%WFILE%") do (
		start /b cmd /c CALL migrate_files_file.bat %%I %1
	)
	ping 127.0.0.1 -n %TIMEOUT% > nul
	for /f %%i in ("%WFILE%") do (
		rem if %%~zi GTR 0 goto CICLE
	)	
	@echo %data% %time% End processing %1
EXIT /B
