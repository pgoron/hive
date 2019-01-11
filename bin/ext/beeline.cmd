@echo off
setlocal

set CLASS=org.apache.hive.beeline.BeeLine

REM Find the exact version of the jar
pushd %HIVE_LIB%
for %%f in (hive-beeline-*.jar) do (
    set JAR_FILE=%%f
)
popd

"%HADOOP%" jar "%HIVE_LIB%\%JAR_FILE%" %CLASS% %HIVE_OPTS% %*