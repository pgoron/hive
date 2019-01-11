REM the root of the Hive installation
if "%HIVE_HOME%" == "" (
    pushd %~dp0
    cd ..
    for /f "tokens=*" %%a in ('cd') do (set HIVE_HOME=%%a)
    popd
)


:parseargs
if "%1" == "--config" (
    shift
    set HIVE_CONF_DIR=%1
    shift
    goto :parseargs
) else if "%1" == "--auxpath" (
    shift
    set HIVE_AUX_JARS_PATH=%1
    shift
    goto :parseargs
)

REM Default conf dir location if no alternative location defined
if "%HIVE_CONF_DIR%" == "" (
    set HIVE_CONF_DIR=%HIVE_HOME%\conf
)

REM Default to use 256MB
if "%HADOOP_HEAPSIZE%" == "" (
    set HADOOP_HEAPSIZE=256
)

echo HIVE_HOME=%HIVE_HOME%
echo HIVE_CONF_DIR=%HIVE_CONF_DIR%
echo HIVE_AUX_JARS_PATH=%HIVE_AUX_JARS_PATH%
echo HADOOP_HEAPSIZE=%HADOOP_HEAPSIZE%