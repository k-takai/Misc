#Requires -Version 5.1
#Requires -RunAsAdministrator

# For Windows Server 2016 TP5

Write-Output "Docker Host 構成スクリプト"

Invoke-WebRequest "https://get.docker.com/builds/Windows/x86_64/docker-1.12.0.zip" -OutFile "$env:TEMP\docker-1.12.0.zip" -UseBasicParsing
Expand-Archive -Path "$env:TEMP\docker-1.12.0.zip" -DestinationPath $env:ProgramFiles
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)
& $env:ProgramFiles\docker\dockerd.exe --register-service
Start-Service Docker

Write-Output "docker image を取得してください"

$s = @'
docker pull microsoft/windowsservercore
docker images

docker search microsoft
docker pull microsoft/iis:windowsservercore
docker images
docker run -d -p 80:80 microsoft/iis:windowsservercore ping -t localhost
docker ps
'@

Write-Output $s
