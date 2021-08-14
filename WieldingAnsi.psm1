
#  \033[38;2;<r>;<g>;<b>m     #Select RGB foreground color
#  \033[48;2;<r>;<g>;<b>m     #Select RGB background color

class WansiConfig {
    [string]$UnderlineOn = "`e[4m"
    [string]$UnderlineOff = "`e[24m"
    [string]$BoldOn = "`e[1m"
    [string]$BoldOff = "`e[22m"    
    [string]$InverseOn = "`e[7m"
    [string]$InverseOff = "`e[27m"        
    [string]$R = "`e[0m"
    [bool]$Enabled = $true
}

class AnsiString {
    [int]$Length
    [int]$NakedLength
    [int]$InvisibleLength
    [string]$Value
}

class FormatOptions {
    [string]$Value
    [bool]$Prefix
    [string]$PrefixValue
    [bool]$Append 
    [string]$Appendvalue
}

$Wansi = New-Object -TypeName WansiConfig

function Get-FormatOptions {
    param (
        $Token
    )

    $f = New-Object -TypeName FormatOptions 
    $f.AppendValue = ""
    $f.PrefixValue = ""

    if (-not ($Token -match "\|")) {
        $f.Value = $Token
        return $f
    }

    $spec = $Token.SubString($Token.IndexOf("|") + 1)

    $f.Value = $Token.SubString(0, $Token.IndexOf("|"))

    if ($spec.Length -lt 1) {
        return $f
    }

    $escapeNext = $false
    $capture = ""
    
    $spec.ToCharArray() | ForEach-Object {

        $c = $_

        switch -Wildcard ($c) {
            "\" {
                $escapeNext = $true;Break
            }
            ">" {
                if (-not $escapeNext){
                    $capture = "A"
                    $f.Append = $true
                     Break
                }                
            }
            "<" {
                if (-not $escapeNext){
                    $capture = "P"
                    $f.Prefix = $true
                     Break
                }

            }
            "*" {
                $escapeNext = $false
                switch ($capture) {
                    "P" {
                        $f.PrefixValue += $c
                        Break
                    }

                    "A" {
                        $f.AppendValue += $c
                        Break                        
                    }
                }
                

            }
            # default {
            # }
        }

    }

    $f

}
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

    $output = ""
    $output += (ConvertTo-AnsiString "`n{:UnderlineOn:}Styles{:R:}`n").Value
    $output += (ConvertTo-AnsiString "{:BoldOn:}Bold '`$Wansi.BoldOn'{:BoldOff:} : Bold Off '`$Wansi.BoldOff'{:R:}`n").Value
    $output += (ConvertTo-AnsiString "{:UnderlineOn:}Underline '`$Wansi.UnderlineOn'{:UnderlineOff:} : Underline Off '`$Wansi.UnderlineOff'{:R:}`n").Value
    $output += (ConvertTo-AnsiString "{:InverseOn:}Inverse '`$Wansi.InverseOn'{:InverseOff:} : Inverse Off '`$Wansi.InverseOff'{:R:}`n").Value
    $output += (ConvertTo-AnsiString "{:InverseOn:}{:UnderlineOn:}{:BoldOn:}Everything On {:R:}: Reset `$(`$Wansi.R)`n" ).Value
    
    $output += (ConvertTo-AnsiString "`n{:UnderlineOn:}Foreground(`$Wansi.F`#),  Background(`$Wansi.B`#){:R:}`n").Value

    foreach ($color in 0..255) {
        $fg = ConvertTo-AnsiString " $color" -PadRight 5
        $bg = ConvertTo-AnsiString "{`:B$color`:}" -PadRight 5
        $temp = "{0, -5}{1}{2}" -f $fg.Value, "{:F0:}", $bg.Value
        $output += (ConvertTo-AnsiString "$temp{:R:}").Value
        if ( (($color + 1) % 6) -eq 4 ) { $output += "`n" }
    }

    $output
}

function Set-WansiToken {
    param (
        [string]$Name,
        [string]$Value
    )

    Add-Member -InputObject $Wansi -MemberType NoteProperty -Name $Name -Value $Value -Force

}

function Expand-Tokens {
    param (
        [string]$Value
    )

    $result = $Value

    # "\{\{(\w+[<>](.)?[<>]?(.))\}\}"

    $captures = [regex]::Matches($Value, "\{\{([^\}]*)\}\}").Groups.captures
    foreach ($capture in $captures) {
        if ($null -ne $capture.Groups) {
            $token = $capture.Groups[0].Value


            $property =$capture.Groups[1].Value

            $fmt = Get-FormatOptions $property

            $code = $Wansi.PSObject.Properties.Item($fmt.Value).Value

            if ($fmt.Prefix) {
                if ($fmt.PrefixValue.Length -lt 1) {
                    $fmt.PrefixValue = " "
                }
                $code = $fmt.PrefixValue + $code
            }

            if ($fmt.Append) {
                if ($fmt.AppendValue.Length -lt 1) {
                    $fmt.AppendValue = " "
                }
                $code = $code + $fmt.AppendValue
            }

            $result = $result.Replace($token, $code)
        }
    }

    $result

}

function ConvertTo-AnsiString {
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

    $result = Expand-Tokens $Value    
    $naked = $result

    $captures = [regex]::Matches($result, "\{:(\w+):\}").Groups.captures
    $tokensLength = 0

    foreach ($capture in $captures) {
        if ($null -ne $capture.Groups) {
            $token = $capture.Groups[0].Value
            $property =$capture.Groups[1].Value
            $naked = $naked.Replace($capture.Groups[0].Value, "")


            if ([bool]($Wansi.PSObject.Properties.name.Contains($property))) {
                $code = $Wansi.PSObject.Properties.Item($property).Value
                $tokensLength += $code.Length
                if ($Wansi.Enabled) {
                    $result = $result.Replace($token, $code)
                }  else {
                    $result = $result.Replace($token, "")
                }
            }            
        }
    }

    $padLength = 0

    if (-not $Wansi.Enabled) {
        $tokensLength = 0;
    }

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
    if ($Wansi.Enabled) {
        $ansiString.InvisibleLength = $tokensLength
    } else {
        $ansiString.InvisibleLength = 0
        $ansiString.NakedLength = $result.Length
    }

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

    Write-Output $(ConvertTo-AnsiString $Value).Value
}

Update-AnsiCodes

Export-ModuleMember -Function Out-Default, 'Get-WieldingAnsiInfo'
Export-ModuleMember -Function Out-Default, 'Set-WansiToken'
Export-ModuleMember -Function Out-Default, 'Get-FormatOptions'
Export-ModuleMember -Function Out-Default, 'Show-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'Update-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'Expand-Tokens'
Export-ModuleMember -Function Out-Default, 'ConvertTo-AnsiString'
Export-ModuleMember -Function Out-Default, 'Write-Wansi'
Export-ModuleMember -Variable 'Wansi'


