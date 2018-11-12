@echo off
IF [%1] == [] (
    GOTO :help
) 
IF [%2] == [] (
    GOTO :help
) 

SET sqlPackageCmd="C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe"
IF NOT EXIST %sqlPackageCmd% (
    ECHO cannot find SqlPackage command at %sqlPackageCmd. 
    EXIT /B 1
)

SET sourceConnectionString=%1
SET targetConnectionString=%2


set timestamp=%DATE:/=-%_%TIME::=-%
set timestamp=%timestamp: =%
set timestamp=%timestamp:.=%
set tmp=%temp%\getDbSchema_%timestamp%
mkdir "%tmp%"
%sqlPackageCmd% /a:extract /scs:"%sourceConnectionString%" /tf:"%tmp%\source.dacpac" /OverwriteFiles:False 
%sqlPackageCmd% /a:script /sf:"%tmp%\source.dacpac" /tcs:"%targetConnectionString%" /p:ExcludeObjectTypes="Users;RoleMembership" /p:AllowIncompatiblePlatform="True" /OverwriteFiles:False /op:"%tmp%\upgrade.sql"
ECHO(
ECHO(
ECHO(
ECHO(
type "%tmp%\upgrade.sql"
rmdir /S /Q "%tmp%"
EXIT /B 0

:help
ECHO(
ECHO Produces a sqlcmd script to upgrade [target] database to match [source] schema
ECHO(
ECHO UPDATESQLSERVERSCHEMA [source connection string] [target connection string]
ECHO connection strings must include database name
ECHO(
ECHO use UPDATESQLSERVERSCHEMA "source" "target" >OUTPUTFILE
ECHO to output to a file OUTPUTFILE
ECHO if you get error alerts in SSMS, enable sqlcmd mode.
EXIT /B 0
