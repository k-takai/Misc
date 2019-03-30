#Requires -Version 3
#Requires -RunAsAdministrator

<#
    .SYNOPSIS
        WMI 経由でレジストリーの値を取得します。WMI のリモートアクセスが可能な環境であれば、その他のリモートアクセスが許可されていなくても使用できます。
    
    .DESCRIPTION
    
    .PARAMETER ComputerName
        接続先のコンピューター名を指定します。
    
    .INPUTS
    
    .OUTPUTS
    
    .EXAMPLE
    
    .NOTES

#>

Param(
    [parameter(Mandatory=$true)]
    [string[]]$ComputerName
)

$HKEY_LOCAL_MACHINE = 2147483650
$ns = "root\default"
$cls = "StdRegProv"
$regkey = "SOFTWARE\Policies\Microsoft"

$result = New-Object System.Collections.ArrayList

$ComputerName | % {
    $c = $_
    $wmi = Get-WmiObject -List $cls -Namespace $ns -ComputerName $c
    $r = $wmi.EnumKey($HKEY_LOCAL_MACHINE, $regkey)
    $r.sNames | % {
        $obj = New-Object -TypeName PSObject
        Add-Member -InputObject $obj -MemberType NoteProperty -Name ComputerName -Value $c
        Add-Member -InputObject $obj -MemberType NoteProperty -Name Name -Value $_
        Add-Member -InputObject $obj -MemberType NoteProperty -Name Type -Value "SubKey"
        Add-Member -InputObject $obj -MemberType NoteProperty -Name Value -Value $null
        $result.Add($obj) | Out-Null
    }
    $r = $wmi.EnumValues($HKEY_LOCAL_MACHINE, $regkey)
    if($r.ReturnValue -eq 0) {
        for($i = 0; $i -lt $r.sNames.Count; $i++) {
            $obj = New-Object -TypeName PSObject
            Add-Member -InputObject $obj -MemberType NoteProperty -Name ComputerName -Value $c
            Add-Member -InputObject $obj -MemberType NoteProperty -Name Name -Value $r.sNames[$i]
            switch ($r.Types[$i]) {
                1 { # REG_SZ
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Type -Value "REG_SZ"
                    $val = $wmi.GetStringValue($HKEY_LOCAL_MACHINE, $regkey, $r.sNames[$i])
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Value -Value $val.sValue
                }
                2 { # REG_EXPAND_SZ
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Type -Value "REG_EXPAND_SZ"
                    $val = $wmi.GetExpandedStringValue($HKEY_LOCAL_MACHINE, $regkey, $r.sNames[$i])
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Value -Value $val.sValue
                }
                3 { # REG_BINARY
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Type -Value "REG_BINARY"
                    $val = $wmi.GetBinaryValue($HKEY_LOCAL_MACHINE, $regkey, $r.sNames[$i])
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Value -Value $val.uValue
                }
                4 { # REG_DWORD
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Type -Value "REG_DWORD"
                    $val = $wmi.GetDWORDValue($HKEY_LOCAL_MACHINE, $regkey, $r.sNames[$i])
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Value -Value $val.uValue
                }
                7 { # REG_MULTI_SZ
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Type -Value "REG_MULTI_SZ"
                    $val = $wmi.GetMultiStringValue($HKEY_LOCAL_MACHINE, $regkey, $r.sNames[$i])
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Value -Value $val.sValue
                }
                11 { # REG_QWORD
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Type -Value "REG_QWORD"
                    $val = $wmi.GetQWORDValue($HKEY_LOCAL_MACHINE, $regkey, $r.sNames[$i])
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Value -Value $val.uValue
                }
                default { # Invalid Object
                }
            }
            $result.Add($obj) | Out-Null
        }
    }
}

return $result
