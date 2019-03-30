#Requires -Version 5
#Requires -RunAsAdministrator

<#
    .SYNOPSIS
        Windows Server 2016 RTM の NanoServerImageGenerator を修正し、インターフェース名が ASCII 以外の場合にもアドレスを設定できるようにします。
    
    .DESCRIPTION
        このスクリプトは Windows Server 2016 RTM 専用です。Windows Server 1709 以降では Nano Server は Container Image としてのみサポートされます。
        
        Windows Server 2016 RTM の NanoServerImageGenerator は、インターフェース名が ASCII 文字列以外で表現されることを想定していません。そのため、デフォルトインターフェース名が ASCII 外の環境、例えば "イーサネット" となっている日本語環境では、IP アドレスを正しく設定できません。

        このスクリプトは、NanoServerImageGenerator モジュールを修正し、インターフェース名が ASCII 以外の環境においても、New-NanoServerImage で指定した IP アドレスが正しく設定されるよう、モジュールを修正します。
    
    .PARAMETER Path
        NanoServerImageGenerator モジュールのフォルダーを指定します。指定したフォルダー内のモジュールファイルが直接修正されます。
    
    .INPUTS
        なし。パイプラインからの入力には対応していません。
    
    .OUTPUTS
        System.Int32
        正常終了した場合は 0 を、それ以外の場合は 1 を返します。
    
    .EXAMPLE
        .\Modify-NanoServerImageGenerator.ps1 -Path C:\Temp\NanoServer\NanoServerImageGenerator
        C:\Temp にインストールメディアの NanoServer フォルダーをコピーした場合、NanoServer フォルダー内の NanoServerImageGenerator フォルダーを指定してください。
    
    .NOTES
        This script is only for Windows Server 2016 RTM (10.0.14393).
        This script is tested with Windows Server 2016 Evaluation 10.0.14393.0 JA-JP only.
        Use this at your own risk!
#>

[Cmdletbinding()]
param
(
    [Parameter(Mandatory)]
    [string]$Path,

    [switch]$Force
)

## Initialize
$ErrorActionPreference = "Stop"
# Target Module File
$target = $Path + "\NanoServerImageGenerator.psm1"
# Original FileHash (SHA256)
$hash = "5DDA7841FEDC064F2696D1155717E9094621722C0F2645D1062453D4047C997B"
# Target line
$line2508 = @'
    Set-Content -Value $SetupCompleteCommand -Path "$Script:TargetSetupCompleteFilePath" -Encoding UTF8
'@

## Check target
if(!(Test-Path $target)) {
    Write-Output "モジュールが存在しません。"
    Write-Verbose -Message ("Path: {0}" -f $Path)
    Write-Verbose -Message ("Target: {0}" -f $target)
    exit 1
}

$h = Get-FileHash -Algorithm SHA256 $target
if($hash -ine $h.Hash) {
    Write-Output "モジュールがオリジナルの状態ではありません。"
    Write-Verbose -Message "モジュールのハッシュ値が想定と異なります。"
    Write-Verbose -Message ("Expected Hash (SHA256): {0}" -f $hash)
    Write-Verbose -Message ("Actual Hash (SHA256): {0}" -f $h.Hash)
    exit 1
}

## Copy & Modify
Copy-Item -Path $target -Destination ($target + ".original") -Force
$c = Get-Content -Path $target -Encoding UTF8
$c[2508] = $line2508
Set-Content -Path $target -Value $c -Encoding UTF8

Write-Output "FailoverClusters モジュールを修正しました。"
return 0
