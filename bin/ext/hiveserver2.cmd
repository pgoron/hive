@echo off
setlocal

echo %DATE% %TIME%: Starting HiveServer2
set CLASS=org.apache.hive.service.server.HiveServer2
set JARTMPL=hive-service-?.*.jar
set HADOOP_CLIENT_OPTS= -Dproc_hiveserver2 %HADOOP_CLIENT_OPTS%

REM Find the exact version of the jar
pushd %HIVE_LIB%
for %%f in (%JARTMPL%) do (
    set JAR=%%f
)
popd

echo "%HADOOP%" jar "%HIVE_LIB%\%JAR%" %CLASS% %HIVE_OPTS% %*
"%HADOOP%" jar "%HIVE_LIB%\%JAR%" %CLASS% %HIVE_OPTS% %*
