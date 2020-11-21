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
    [int]$InvisibleLength
    [string]$Value
}

$Wansi = New-Object -TypeName AnsiCodes

function Get-WieldingAnsiInfo {
    $moduleName = (Get-ChildItem "$PSScriptRoot/*.psd1").Name

    Import-PowerShellDataFile -Path "$PSScriptRoot/$moduleName"
}

function Update-AnsiCodes() {
    <#
 .SYNOPSIS
    Builds the color attributes for the AnsiCodes class

 .DESCRIPTION
    Builds the color attributes for the AnsiCodes class

 .NOTES
    It is not generally necessary to call this function unless you want to reset 
    the $Wansi class values after they have been altered in some way.
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

     .EXAMPLE
        Show-AnsiCodes
        Displays the ANSI code table
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

 .PARAMETER Value
    The string containing Wansi tokens to be converted

 .EXAMPLE
    Write-Wansi "{:F3:}{:B4:}Test{:R:}`n"
    Writes the word 'Test' to the console with a Red foreground and Blue background.

 .OUTPUTS
    an AnsiString object with Length, NakedLength and Value properties.
#>            
    param (
        [string]$Value,
        [int]$PadRight,
        [int]$PadLeft
    )

    $TextInfo = (Get-Culture).TextInfo
    $result = $Value
    $naked = $Value
    $captures = [regex]::Matches($Value, "\{:(\w+):\}").Groups.captures
    $tokensLength = 0

    foreach ($capture in $captures) {
        if ($null -ne $capture.Groups) {
            $token = $capture.Groups[0].Value
            $property = $TextInfo.ToTitleCase($capture.Groups[1].Value)
            $naked = $naked.Replace($capture.Groups[0].Value, "")

            if ([bool]($Wansi.PSObject.Properties.name -match $property)) {
                $code = $Wansi.PSObject.Properties.Item($property).Value
                $tokensLength += $code.Length
                $result = $result.Replace($token, $code)
            }            
        }
    }

    $padLength = 0

    if ($PadLeft -ne 0) {        
        $originalLength = $result.Length
        $result = $result.PadLeft($PadLeft + $tokensLength, " ")
        $padLength += ($result.Length - $originalLength)
    }

    if ($PadRight -ne 0) {
        $originalLength = $result.Length
        $result = $result.PadRight($PadRight + $tokensLength, " ")
        $padLength += ($result.Length - $originalLength)
    }
   
    $ansiString = New-Object -TypeName AnsiString
    $ansiString.Value = $result
    $ansiString.NakedLength = $naked.Length + $padLength
    $ansiString.Length = $result.Length
    $ansiString.InvisibleLength = $tokensLength

    return $ansiString
}

function Write-Wansi() {
    <#
 .SYNOPSIS
    Displays passed string containing Wansi tokens to the console.

 .DESCRIPTION
    Displays provided string containing Wansi tokens to the console after
    converting the tokens to ANSI escape sequences

  .PARAMETER Value
    The string value to convert Wansi tokens to ansi codes and write to console
    
  .NOTES
    This function does not produce a newline character so the caller must supply one
    with an escape sequence or produce one when the function returns if desired.
#>            
    param (
        [string]$Value
    )

    Write-Host $(ConvertTo-AnsiString $Value).Value -NoNewline
}

Update-AnsiCodes

Export-ModuleMember -Function Out-Default, 'Get-WieldingAnsiInfo'
Export-ModuleMember -Function Out-Default, 'Show-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'Update-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'ConvertTo-AnsiString'
Export-ModuleMember -Function Out-Default, 'Write-Wansi'
Export-ModuleMember -Variable 'Wansi'


