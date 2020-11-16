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
    $esc = $([char]27)

    Write-Host "`n$esc[1;4mStyles$esc[0m"
    Write-Host "$($Wansi.BoldOn)Bold '`$Wansi.BoldOn'$($Wansi.BoldOff) : Bold Off '`$Wansi.BoldOff'$($Wansi.R)"
    Write-Host "$($Wansi.UnderlineOn)Underline '`$Wansi.UnderlineOn'$($Wansi.UnderlineOff) : Underline Off '`$Wansi.UnderlineOff'$($Wansi.R)"
    Write-Host "$($Wansi.InverseOn)Inverse '`$Wansi.InverseOn'$($Wansi.InverseOff) : Inverse Off '`$Wansi.InverseOff'$($Wansi.R)"    
    Write-Host "$($Wansi.InverseOn)$($Wansi.UnderlineOn)$($Wansi.BoldOn)Everything On $($Wansi.R): Reset `$(`$Wansi.R)"


    Write-Host "`n$esc[1;4mForeground(`$Wansi.F`#),  Background(`$Wansi.B`#)$esc[0m"
    foreach ($fb in 38, 48) {
        foreach ($color in 0..255) {
            $field = "$(if ($fb -eq 38) {"F"} else {"B"})$color".PadLeft(4)
            Write-Host -NoNewLine "$esc[$fb;5;${color}m$field $esc[0m"
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

