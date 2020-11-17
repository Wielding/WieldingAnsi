class AnsiCodes {
    [string]$UnderlineOn = "`e[4m"
    [string]$UnderlineOff = "`e[24m"
    [string]$BoldOn = "`e[1m"
    [string]$BoldOff = "`e[22m"    
    [string]$InverseOn = "`e[7m"
    [string]$InverseOff = "`e[27m"        
    [string]$R = "`e[0m"
}

class AnsiString {
    [int]$Length
    [int]$NakedLength
    [string]$Value
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

        foreach ($color in 0..255) {
            $fg = ConvertTo-AnsiString " $color"
            $bg = ConvertTo-AnsiString "{`:B$color`:}   "
            $s = ("{0, -5}{1}{2}" -f $fg.Value.PadRight(4), "{:F0:}", $bg.Value.PadRight(14 + ($color.ToString().Length)))
            Write-Wansi $s
            if ( (($color + 1) % 6) -eq 4 ) { Write-Host "`r" }
        }
        Write-Host `n

    }

function ConvertTo-AnsiString() {
    <#
 .SYNOPSIS
    Converts input string with Wansi tokens

 .DESCRIPTION
    Converts input string with Wansi tokens to a string with embedded ANSI escape codes.
#>            
    param (
        [string]$value
    )

    $TextInfo = (Get-Culture).TextInfo
    $result = $value
    $naked = $value
    $captures = [regex]::Matches($value,"\{:(\w+):\}").Groups.captures

    foreach($capture in $captures) {
        if ($null -ne $capture.Groups) {
            $token = $capture.Groups[0].Value
            $property = $TextInfo.ToTitleCase($capture.Groups[1].Value)
            $naked = $naked.Replace($capture.Groups[0].Value, "")

            if ([bool]($Wansi.PSObject.Properties.name -match $property)) {
                $code = $Wansi.PSObject.Properties.Item($property).Value
                $result = $result.Replace($token, $code)
            }            
        }
    }
   
    $ansiString = New-Object -TypeName AnsiString
    $ansiString.Value = $result
    $ansiString.NakedLength = $naked.Length
    $ansiString.Length = $result.Length

    return $ansiString
}

function Write-Wansi() {
<#
 .SYNOPSIS
    Displays a string with Wansi tokens

 .DESCRIPTION
    Displays a string with Wansi tokens
#>            
    param (
        [string]$value
    )

    Write-Host $(ConvertTo-AnsiString $value).Value -NoNewline
}

Update-AnsiCodes

Export-ModuleMember -Function Out-Default, 'Show-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'Update-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'ConvertTo-AnsiString'
Export-ModuleMember -Function Out-Default, 'Write-Wansi'
Export-ModuleMember -Variable 'Wansi'


