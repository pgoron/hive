@echo off
setlocal enabledelayedexpansion

echo JAR=%JAR%
echo CLASS=%CLASS%

SET CLI_JAR=hive-cli-*.jar
SET BEELINE_JAR=hive-beeline-*.jar
SET JAR_FILE=

if "%JAR%"=="%CLI_JAR%" (
    set JARTMPL=%JAR%
) else if "%JAR%"=="%BEELINE_JAR%" (
    set JARTMPL=%JAR%
) else if "%USE_DEPRECATED_CLI%"=="true" (
    set JARTMPL=%CLI_JAR%
) else (
    set JARTMPL=%BEELINE_JAR%
)
echo JARTMPL=%JARTMPL%

REM Find the exact version of the jar
pushd %HIVE_LIB%
for %%f in (%JARTMPL%) do (
    set JAR_FILE=%%f
)
popd

if "%JAR_FILE%"=="" (
    echo Missing %JARTMPL% jar in %HIVE_LIB%
    exit /B 3
)

"%HADOOP%" jar "%HIVE_LIB%\%JAR_FILE%" %CLASS% %HIVE_OPTS% %*