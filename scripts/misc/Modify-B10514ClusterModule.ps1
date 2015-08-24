#Requires -Version 4
#Requires -RunAsAdministrator

# This script is only for Windows Server 2016 TP3 Build 10514.

# FailoverCsluters Module File
$path = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\FailoverClusters\Microsoft.FailoverClusters.PowerShell.psm1"

# Original FileHash (SHA512)
$hash = "332296757E18AB660396C5F3F13F0F690B887D9CBDD3B6AA9C8805608E8C98BAE2CE1A1F39F46CF68E0319FB808D0F9D5B8F00268A289689BD85E8EA5D0E63CB"

$line74 = @'
    $Message = $Message + " cmdlet was cancelled"
'@
$line96 = @'
    ShowError("Wrong OS Version - Need at least Windows Server 2012 R2 or Windows 8.1. You are running '" + $OS.Name + "'")
'@

if(!(Test-Path $path)) {
    Write-Output "FailoverClusters モジュールがインストールされていません。"
    exit
}

$h = Get-FileHash -Algorithm SHA512 $path
if($hash -ine $h.Hash) {
    Write-Output "FailoverClusters モジュールが、Windows Server 2016 TP3 Build 10514 オリジナルの状態ではありません。"
    exit
}

Copy-Item -Path $path -Destination ($path + ".original") -Force

Start-Process takeown -ArgumentList "/f $path /a" -Wait
Start-Process icacls -ArgumentList "$path /grant Administrators:F" -Wait
$c = Get-Content -Path $path -Encoding Ascii
$c[73] = $line74
$c[95] = $line96
Set-Content -Path $path -Value $c -Encoding Ascii
Start-Process icacls -ArgumentList "$path /setowner `"NT Service\TrustedInstaller`" /c /q" -Wait
Start-Process icacls -ArgumentList "$path /grant:r Administrators:RX" -Wait

Write-Output "FailoverClusters モジュールを修正しました。"
return
