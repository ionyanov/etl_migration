ECHO OFF
setlocal EnableDelayedExpansion

	set SRC_DB_USER=
	set SRC_PGPASSWORD=
	set SRC_DB_HOST=
	set SRC_DB_PORT=5432
	set SRC_DB_NAME=bpm

	REM ELMA
	set DST_DB_USER=
	set DST_PGPASSWORD=
	set DST_DB_HOST=
	set DST_DB_PORT=5432
	set DST_DB_NAME=elma365

call :proc_dir sql_files data

EXIT /B
::============================================================================
:proc_dir <SQLDirName> <DataDirName>
	set SQL_DIR=%1
	set WORK_DIR=%2
	mkdir %WORK_DIR%
	for /r %%F in (%SQL_DIR%\*.sql) do (
		call :proc_file "%%~fF" %WORK_DIR%\%%~nF.csv 1 0 0
	)

EXIT /B
::============================================================================
:proc_file <SqlFileName> <CSVFileName> <ClearMode> <Limit> <Offset>
	set SqlFileName=%1
	set CSVFileName=%2
	set TableName=disk_files
	set ClearMode=%3
	set LIMIT=%4
	set OFFSET=%5
	
	setlocal EnableDelayedExpansion

	set PSQL=C:\Program Files\PostgreSQL\14\bin\psql.exe
	SET PGCLIENTENCODING=UTF8
	@chcp 65001

	@echo !date! !time! Export %TableName% Batch=%LIMIT% from %OFFSET%
	set PGPASSWORD=%SRC_PGPASSWORD%
	"%PSQL%" -h %SRC_DB_HOST% -p %SRC_DB_PORT% -U %SRC_DB_USER% -d %SRC_DB_NAME% -A -q --pset="footer=off" -f %SqlFileName% -o %CSVFileName% -v limit=%LIMIT% -v offset=%OFFSET%
	
	set PGPASSWORD=%DST_PGPASSWORD%
	if /i "%ClearMode%"=="1" (
		@echo !date! !time! Cleare by Id %TableName% Batch=%OFFSET%
		set cnt=0
		set ids='00000000-0000-0000-0000-000000000000'
		for /F "eol=; tokens=1 delims=| skip=1" %%A in (%CSVFileName%) do (
			set /a "cnt=!cnt!+1"
			set ids=!ids!,'%%A'
			if /i !cnt! == 100 (
				set cnt=0
				"%PSQL%" -h %DST_DB_HOST% -p %DST_DB_PORT% -U %DST_DB_USER% -d %DST_DB_NAME% -A -q -c "delete from head.""%TableName%"" where id in (!ids!)"
				set ids='00000000-0000-0000-0000-000000000000'
			)
		)
		"%PSQL%" -h %DST_DB_HOST% -p %DST_DB_PORT% -U %DST_DB_USER% -d %DST_DB_NAME% -A -q -c "delete from head.""%TableName%"" where ""id"" in (!ids!)"
		timeout 2 > NUL
	) else if /i "%ClearMode%"=="2" (
		@echo !date! !time! Cleare ALL %TableName%
		"%PSQL%" -h %DST_DB_HOST% -p %DST_DB_PORT% -U %DST_DB_USER% -d %DST_DB_NAME% -A -q -c "delete from head.""%TableName%"""
		timeout 2 > NUL
	)
	
	@echo !date! !time! Import %TableName% Batch=%OFFSET%
	set /p fields=< %CSVFileName%
	set "fields=!fields:|="", ""!"
	"%PSQL%" -h %DST_DB_HOST% -p %DST_DB_PORT% -U %DST_DB_USER% -d %DST_DB_NAME% -c "\copy head.""%TableName%""( ""!fields!"" ) FROM '%CSVFileName%' HEADER DELIMITER '|' CSV QUOTE '~' ESCAPE '\'"
EXIT /B