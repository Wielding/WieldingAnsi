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
    $esc = $([char]27)
    foreach ($fb in 38, 48) {
        foreach ($color in 0..255) {
            Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "$(if ($fb -eq 38) {"F"} Else {"B"})$color" -Value "$esc[$fb;5;${color}m" -Force
        }
    }    
}

function Show-AnsiCodes() {
    $esc = $([char]27)

    Write-Host "`n$esc[1;4mStyles$esc[0m"
    Write-Host "$($Wansi.BoldOn)Bold 'BoldOn'$($Wansi.R)"
    Write-Host "$($Wansi.UnderlineOn)Underlined 'UnderlineOn'$($Wansi.R)"
    Write-Host "$($Wansi.InverseOn)Inverse 'InverseOn'$($Wansi.R)"

    Write-Host "`n$esc[1;4mForeground(F),  Background(B)$esc[0m"
    foreach ($fb in 38, 48) {
        foreach ($color in 0..255) {
            $field = "$(if ($fb -eq 38) {"F"} else {"B"})$color".PadLeft(4)
            Write-Host -NoNewLine "$esc[$fb;5;${color}m$field $esc[0m"
            if ( (($color + 1) % 6) -eq 4 ) { Write-Host "`r" }
        }
        Write-Host `n
    }    
}

Update-AnsiCodes

Export-ModuleMember -Function Out-Default, 'Show-AnsiCodes'
Export-ModuleMember -Function Out-Default, 'Update-AnsiCodes'
Export-ModuleMember -Variable 'Wansi'

