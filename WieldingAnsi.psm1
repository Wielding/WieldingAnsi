class AnsiCodes {
    [string]$UnderlineOn = "`e[4m"
    [string]$UnderlineOff = "`e[24m"
    [string]$BoldOn = "`e[1m"
    [string]$BoldOff = "`e[22m"    
    [string]$InverseOn = "`e[7m"
    [string]$InverseOff = "`e[27m"        
    [string]$R = "`e[0m"
}

$Wansi = New-Object -TypeName AnsiCodes

function Update-AnsiCodes() {
<#
 .SYNOPSIS
    Builds the color attributes for the AnsiCodes class

 .DESCRIPTION
    Builds the color attributes for the AnsiCodes class
#>    
    $esc = $([char]27)
    foreach ($fb in 38, 48) {
        foreach ($color in 0..255) {
            Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "$(if ($fb -eq 38) {"F"} Else {"B"})$color" -Value "$esc[$fb;5;${color}m" -Force
        }
    }    
}

function Show-AnsiCodes() {
<#
 .SYNOPSIS
    Displays the supported ANSI values

 .DESCRIPTION
    Displays the supported ANSI values
#>        
    Write-Wansi "`n{:UnderlineOn:}Styles{:R:}`n"
    Write-Wansi "{:BoldOn:}Bold '`$Wansi.BoldOn'{:BoldOff:} : Bold Off '`$Wansi.BoldOff'{:R:}`n"
    Write-Wansi "{:UnderlineOn:}Underline '`$Wansi.UnderlineOn'{:UnderlineOff:} : Underline Off '`$Wansi.UnderlineOff'{:R:}`n"
    Write-Wansi "{:InverseOn:}Inverse '`$Wansi.InverseOn'{:InverseOff:} : Inverse Off '`$Wansi.InverseOff'{:R:}`n"    
    Write-Wansi "{:InverseOn:}{:UnderlineOn:}{:BoldOn:}Everything On {:R:}: Reset `$(`$Wansi.R)`n"

    Write-Wansi "`n{:UnderlineOn:}Foreground(`$Wansi.F`#),  Background(`$Wansi.B`#){:R:}`n"
    foreach ($fb in 38, 48) {
        foreach ($color in 0..255) {
            $field = "$(if ($fb -eq 38) {"F"} else {"B"})$color".PadLeft(4)
            Write-Host -NoNewLine "`e[$fb;5;${color}m$field `e[0m"
            if ( (($color + 1) % 6) -eq 4 ) { Write-Host "`r" }
        }
        Write-Host `n
    }    
}

function ConvertTo-AnsiString() {
    param (
        [string]$value
    )

    $result = $value
    $TextInfo = (Get-Culture).TextInfo

    $candidates = $value -split {$_ -eq "{" -or $_ -eq "}"}

    foreach ($item in $candidates) {
        if ($item.StartsWith(":") -and $item.EndsWith(":")) {
            $property = $TextInfo.ToTitleCase($item.Replace(":", ""))

            if ([bool]($Wansi.PSObject.Properties.name -match $property)) {
                $code = $Wansi.PSObject.Properties.Item($property).Value
                $result = $result.Replace("`{$item`}", $code)
            }
        }
    }

    return $result
}

function Write-Wansi() {
    param (
        [string]$value
    )

    Write-Host $(ConvertTo-AnsiString $value) -NoNewline
}

Update-AnsiCodes

Export-ModuleMember -Function Out-Default, 'Show-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'Update-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'ConvertTo-AnsiString'
Export-ModuleMember -Function Out-Default, 'Write-Wansi'
Export-ModuleMember -Variable 'Wansi'

