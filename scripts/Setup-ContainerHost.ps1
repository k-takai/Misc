#Requires -Version 5.1
#Requires -RunAsAdministrator

Write-Output "Docker Host 構成スクリプト"

Install-WindowsFeature Hyper-V -IncludeManagementTools

# Stop-Service docker
# Uninstall-Package docker
# Uninstall-Module DockerMsftProvider

Install-Module -Name DockerProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerProvider -RequiredVersion Preview

Restart-Computer -Force

Write-Output "docker image を取得してください"

$s = @'
docker pull microsoft/nanoserver-insider
docker pull microsoft/windowsservercore-insider
docker images

docker search microsoft
docker pull microsoft/iis:windowsservercore
docker images
docker run -d -p 80:80 microsoft/iis:windowsservercore ping -t localhost
docker ps
'@

Write-Output $s
