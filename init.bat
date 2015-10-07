@echo off

:: TODO: check for vagrant, virtualbox

set git_found=0
set ssh_found=0

:: look for git, ruby, ssh
for %%x in (git) do if not [%%~$PATH:x]==[] set git_found=1
for %%x in (ssh) do if not [%%~$PATH:x]==[] set ssh_found=1

if %git_found%==0 (
  echo git executable not found in PATH. Please fix it!
  EXIT /B 1
)
if %ssh_found%==0 (
  echo ssh executable not found in PATH. Please fix it!
  EXIT /B 1
)

echo Done. Now navigate into the available Vagrant boxes.
