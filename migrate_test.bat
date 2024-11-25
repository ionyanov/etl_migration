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

	set SLA=''
	set CALENDAR=''
	set URL=''

call :proc_subdir sql data

EXIT /B
::============================================================================
:proc_subdir <SQLDirName> <DataDirName> 
	set SQL_DIR=%1
	set WORK_DIR=%2
	mkdir %WORK_DIR%
	
	call :proc_dir %SQL_DIR% %WORK_DIR%
	for /D %%D in (%SQL_DIR%\*) do (
		call :proc_dir %SQL_DIR%\%%~nD %WORK_DIR%\%%~nD %%~nD:
	)
	
EXIT /B
::============================================================================
:proc_dir <SQLDirName> <DataDirName> <NameSpace>
	set SQL_DIR=%1
	set WORK_DIR=%2
	set NameSpace=%3
	mkdir %WORK_DIR%
	for /r %%F in (%SQL_DIR%\calls*.sql) do (
		if /i "%%~nF" == "_contacts" (
			set LIMIT=20000
			set MAX_CON=2200000
			REM 2 206 834
			FOR /L %%c IN (220000,!LIMIT!,!MAX_CON!) DO (
				call :proc_file "%%~fF" %WORK_DIR%\%%~nF.csv %NameSpace%%%~nF 1 !LIMIT! %%c
			)
		) ELSE if /i "%%~nF" == "_companies" (
			set LIMIT=20000
			set MAX_ACC=900000
			REM 915 435
			FOR /L %%c IN (0,!LIMIT!,!MAX_ACC!) DO (
				call :proc_file "%%~fF" %WORK_DIR%\%%~nF.csv %NameSpace%%%~nF 0 !LIMIT! %%c
			)
		) ELSE (
			call :proc_file "%%~fF" %WORK_DIR%\%%~nF.csv %NameSpace%%%~nF 2 0 0
		)
	)

EXIT /B
::============================================================================
:proc_file <SqlFileName> <CSVFileName> <TableName> <ClearMode> <Limit> <Offset>
	set SqlFileName=%1
	set CSVFileName=%2
	set TableName=%3
	set ClearMode=%4
	set LIMIT=%5
	set OFFSET=%6
	
	setlocal EnableDelayedExpansion

	set PSQL=C:\Program Files\PostgreSQL\14\bin\psql.exe
	SET PGCLIENTENCODING=UTF8
	@chcp 65001

	@echo !date! !time! Export %TableName% Batch=%LIMIT% from %OFFSET%
	set PGPASSWORD=%SRC_PGPASSWORD%
	"%PSQL%" -h %SRC_DB_HOST% -p %SRC_DB_PORT% -U %SRC_DB_USER% -d %SRC_DB_NAME% -A -q --pset="footer=off" -f %SqlFileName% -o %CSVFileName% -v limit=%LIMIT% -v offset=%OFFSET% -v sla=%SLA% -v calendar=%CALENDAR% -v URL=%URL%
	
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