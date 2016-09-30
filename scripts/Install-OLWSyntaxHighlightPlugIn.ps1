#Requires -Version 4
$ErrorActionPreference = "Stop"

$installsource = "https://richhewlett.blob.core.windows.net/blogdownloads/SyntaxHighlight_WordPressCom_OLWPlugIn_V2.0.0.zip"
$installtarget = $env:LOCALAPPDATA + "\OpenLiveWriter Additional Resources\Plugins"
$regkey = "HKCU:\SOFTWARE\OpenLiveWriter\PluginAssemblies"
$dllname = "SyntaxHighlight_WordPressCom_OLWPlugIn.dll"

$logbase = $env:TEMP
$logprefix = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
if($logprefix -eq "") {
    $logprefix = "powershell"
}
$logts = Get-Date -Format yyyyMMddHHmmss
$logname = "${logbase}\${logprefix}-${logdate}.log"

function Log([string] $msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $output = "${ts} ${msg}"
    $output | Write-Output
    $output | Out-File -FilePath $logname -Encoding utf8 -Append
}

$message = "このスクリプトは Open Live Writer 用の SyntaxHighlightPlugin をインストールします`r`n続行しますか？"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "インストールを実行します"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "インストールを中止します"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0) 
if($result -eq 1) {
    exit 0
}

Log($MyInvocation.MyCommand.Path)
Log("インストールを開始します - {0}" -f $env:COMPUTERNAME)

Log("構成をチェックしています")
if(!(Test-Path $regkey)) {
    Log("レジストリー キー {0} が存在しません" -f $regkey)
    Log("Open Live Writer がインストールされていないか、正しく構成されていません")
    $message = "続行しますか？"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "現状の構成にかかわらずインストールを続行します"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "インストールを中止します"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch($result) {
        0 { New-Item -Path $regkey -Force | Out-Null }
        1 { exit 0 }
    }
}

$uri = New-Object System.Uri($installsource)
$downloadfile = $env:TEMP + "\" + (Split-Path $uri.AbsolutePath -Leaf)
Log("インストールファイルをダウンロードします")
Log("Download from : {0}" -f $installsource)
Log("Save to : {0}" -f $downloadfile)
Invoke-WebRequest -Uri $uri -UseBasicParsing -OutFile $downloadfile

Log("プラグインをインストールします")
Log("Install to : {0}" -f $installtarget)
if(!(Test-Path $installtarget)) {
    New-Item -ItemType Directory -Path $installtarget -Force | Out-Null
}
Expand-Archive -Path $downloadfile -DestinationPath $installtarget -Force

Log("プラグインを Open Live Writer に登録します")
New-ItemProperty -Path $regkey -Name SyntaxHighlightPlugin -Value ($installtarget + "\" + $dllname) -Force | Out-Null

$p = Get-Process -Name OpenLiveWriter -ErrorAction SilentlyContinue
if($p -ne $null) {
    Log("Open Live Writer が起動中です")
    Log("全ての Open Live Writer プロセスを終了後、再度 Open Live Writer を起動してください")
} 

Log("インストールが完了しました")
exit 0
