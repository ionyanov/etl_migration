@echo OFF
"%PSQL%" -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -qAt -c "\COPY (select ""Data"" from public.""%2"" where ""Id""='%1') TO '%WFOLDER%\%1' (FORMAT binary)"
aws --endpoint-url %S3_URL% s3 cp "%WFOLDER%\%1" "s3://%S3_BUCKET%" 
REM --quiet 
"%PSQL%" -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -A -q -c "insert into public.migrate_to_elma(id, src) values ('%1', '%2')"
rem del "%WFOLDER%\%1"