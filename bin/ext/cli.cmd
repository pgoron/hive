@echo off
setlocal

if "%USE_DEPRECATED_CLI%"=="true" (
    set HADOOP_CLIENT_OPTS= -Dproc_hivecli %HADOOP_CLIENT_OPTS%
    set CLASS=org.apache.hadoop.hive.cli.CliDriver
    set JAR=hive-cli-*.jar
) else (
    set HADOOP_CLIENT_OPTS= -Dproc_beeline %HADOOP_CLIENT_OPTS% -Dlog4j.configurationFile=beeline-log4j2.properties
    set CLASS=org.apache.hive.beeline.cli.HiveCli
    set JAR=hive-beeline-*.jar
)

call %~dp0util\execHiveCmd.cmd %*