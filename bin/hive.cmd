@echo off
setlocal enabledelayedexpansion


call %~dp0hive-config.cmd

:parseargs
if "%1" == "--version" (
    set SERVICE=version
    shift
    goto :parseargs
) else if "%1" == "--service" (
    set SERVICE=%2
    shift
    shift
    goto :parseargs
) else if "%1" == "--rcfilecat" (
    set SERVICE=rcfilecat
    shift
    goto :parseargs
) else if "%1" == "--orcfiledump" (
    set SERVICE=orcfiledump
    shift
    goto :parseargs
) else if "%1" == "--llapdump" (
    set SERVICE=llapdump
    shift
    goto :parseargs
) else if "%1" == "--skiphadoopversion" (
    set SKIP_HADOOPVERSION=true
    shift
    goto :parseargs
) else if "%1" == "--skiphbasecp" (
    set SKIP_HBASECP=true
    shift
    goto :parseargs
) else if "%1" == "--help" (
    set HELP=_help
    shift
    goto :parseargs
) else if "%1" == "--debug" (
    rem StartWith --debug
) else if NOT "%1" == "" (
    set SERVICE_ARGS=!SERVICE_ARGS!;%1
    shift
    goto :parseargs
)

if "%SERVICE%" == "" (
    if "%HELP%" == "_help" (
        set SERVICE=help
    ) else (
        set SERVICE=cli
    )
)

if "%SERVICE%" == "help" set SKIP_HBASECP=true
if "%SERVICE%" == "version" set SKIP_HBASECP=true
if "%SERVICE%" == "orcfiledump" set SKIP_HBASECP=true
if "%SERVICE%" == "rcfilecat" set SKIP_HBASECP=true
if "%SERVICE%" == "schemaTool" set SKIP_HBASECP=true
if "%SERVICE%" == "cleardanglingscratchdir" set SKIP_HBASECP=true
if "%SERVICE%" == "metastore" set SKIP_HBASECP=true
if "%SERVICE%" == "beeline" set SKIP_HBASECP=true
if "%SERVICE%" == "llapstatus" set SKIP_HBASECP=true
if "%SERVICE%" == "llap" set SKIP_HBASECP=true


if "%SERVICE%" == "help" set SKIP_HADOOPVERSION=true
if "%SERVICE%" == "schemaTool" set SKIP_HADOOPVERSION=true

if exist "%HIVE_CONF_DIR%\hive-env.cmd" (
    call "%HIVE_CONF_DIR%\hive-env.cmd"
)

rem TODO SPARK

set CLASSPATH=%HIVE_CONF_DIR%

set HIVE_LIB=%HIVE_HOME%\lib

rem Check presence of hive-exec-X.Y.Z.jar
rem Check presence of hive-cli-X.Y.Z.jar
rem Check presence of hive-metastore-X.Y.Z.jar

set CLASSPATH=%HIVE_LIB%\*

rem add the auxillary jars such as serdes
if NOT "%HIVE_AUX_JARS_PATH%" == "" (  
    pushd %HIVE_AUX_JARS_PATH%
    for %%f in (*.jar) do (
        echo %%~ff
        set AUX_CLASSPATH=!AUX_CLASSPATH!;%%~ff
    )
    if "%AUX_PARAM%" == "" (
        set AUX_PARAM=file:///%%~ff
    ) else (
        set AUX_PARAM=!AUX_PARAM!,file:///%%~ff
    )
    popd
)

rem adding jars from auxlib directory
if exist %HIVE_HOME\auxlib (
    pushd %HIVE_HOME%\auxlib
    for %%f in (*.jar) do (
        echo %%~ff
        set AUX_CLASSPATH=!AUX_CLASSPATH!;%%~ff
    )
    if "%AUX_PARAM%" == "" (
        set AUX_PARAM=file:///%%~ff
    ) else (
        set AUX_PARAM=!AUX_PARAM!,file:///%%~ff
    )
    popd
)

if NOT "%AUX_CLASSPATH%" == "" (
    set CLASSPATH=%CLASSPATH%;%AUX_CLASSPATH%
)

rem supress the HADOOP_HOME warnings in 1.x.x
set HADOOP_HOME_WARN_SUPPRESS=true 

rem to make sure log4j2.x and jline jars are loaded ahead of the jars pulled by hadoop
set HADOOP_USER_CLASSPATH_FIRST=true

rem pass classpath to hadoop
if NOT "%HADOOP_CLASSPATH%" == "" (
    set HADOOP_CLASSPATH=%CLASSPATH%;%HADOOP_CLASSPATH%
) else (
    set HADOOP_CLASSPATH=%CLASSPATH%
)

rem also pass hive classpath to hadoop
if NOT "%HIVE_CLASSPATH%" == "" (
    set HADOOP_CLASSPATH=%HADOOP_CLASSPATH%;%HIVE_CLASSPATH%
)

rem TODO check for hadoop in the path

rem HADOOP_HOME env variable overrides hadoop in the path
if "%HADOOP_HOME%" == "" (
    if "%HADOOP_PREFIX%" == "" (    
        if "%HADOOP_DIR%" == "" (
            echo Cannot find hadoop installation: HADOOP_HOME or HADOOP_PREFIX must be set or hadoop must be in the path
            exit /B 4
        )
    )
)
set HADOOP=%HADOOP_HOME%\bin\hadoop.cmd

rem add distcp to classpath, hive depends on it
pushd %HADOOP_HOME%\share\hadoop\tools\lib
for %%f in (hadoop-distcp-*.jar) do (
  set HADOOP_CLASSPATH=!HADOOP_CLASSPATH!;%%~ff
)
popd

rem TODO Make sure we're using a compatible version of Hadoop

rem TODO HBase detection. Need bin/hbase and a conf dir for building classpath entries.

if NOT "%AUX_PARAM%" == "" (
    if NOT "%SERVICE%" == "beeline" (
        HIVE_OPTS=%HIVE_OPTS% --hiveconf hive.aux.jars.path=%AUX_PARAM%
    )
    AUX_JARS_CMD_LINE="-libjars %AUX_PARAM%"
)

rem to initialize logging for all services
rem set HADOOP_CLIENT_OPTS=%HADOOP_CLIENT_OPTS% -Dlog4j.debug -Dlog4j.configurationFile=hive-log4j2.properties

if exist "%HIVE_CONF_DIR%\parquet-logging.properties" (
    rem set HADOOP_CLIENT_OPTS=%HADOOP_CLIENT_OPTS% -Djava.util.logging.config.file=%HIVE_CONF_DIR%\parquet-logging.properties
) else (
    rem set HADOOP_CLIENT_OPTS=%HADOOP_CLIENT_OPTS% -Djava.util.logging.config.file=%~dp0\..\conf\parquet-logging.properties
)

rem if [[ "$SERVICE" =~ ^(hiveserver2|beeline|cli)$ ]] ; then
rem  # if process is backgrounded, don't change terminal settings
rem  if [[ ( ! $(ps -o stat= -p $$) =~ "+" ) && ! ( -p /dev/stdin ) ]]; then
rem    export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS -Djline.terminal=jline.UnsupportedTerminal"
rem  fi
rem fi

if exist "%HIVE_HOME%\bin\ext\%SERVICE%.cmd" (
    rem echo SERVICE=%SERVICE%
    rem echo SERVICE_ARGS=%SERVICE_ARGS%
    rem echo HIVE_LIB=%HIVE_LIB%
    rem echo HADOOP_CLASSPATH=%CLASSPATH%
    rem echo HADOOP_CLIENT_OPTS=%HADOOP_CLIENT_OPTS%
    rem echo HIVE_OPTS=%HIVE_OPTS%

    call "%HIVE_HOME%\bin\ext\%SERVICE%.cmd" %SERVICE_ARGS%
) else (
    echo Service %SERVICE% not found (%HIVE_HOME%\bin\ext\%SERVICE%.cmd)
    exit /B 7
)


