@echo off
setlocal

set CLASS=org.apache.hive.beeline.HiveSchemaTool
call %~dp0util\execHiveCmd.cmd %*