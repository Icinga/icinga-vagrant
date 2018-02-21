:: Windows 2012 C Runtime Library KB2999226 hotfix

@echo off

@powershell -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://download.microsoft.com/download/D/1/3/D13E3150-3BB2-4B22-9D8A-47EE2D609FFF/Windows8.1-KB2999226-x64.msu', 'C:\Windows\Temp\Windows8.1-KB2999226-x64.msu'))"

set hotfix="C:\Windows\Temp\Windows8.1-KB2999226-x64.msu"
if not exist %hotfix% goto :eof

:: get windows version
for /f "tokens=2 delims=[]" %%G in ('ver') do (set _version=%%G)
for /f "tokens=2,3,4 delims=. " %%G in ('echo %_version%') do (set _major=%%G& set _minor=%%H& set _build=%%I)

:: 6.1
if %_major% neq 6 goto :eof
if %_minor% lss 1 goto :eof

@echo on
start /wait wusa "%hotfix%" /quiet

choco install -y puppet-agent
