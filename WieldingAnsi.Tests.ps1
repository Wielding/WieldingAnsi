Import-Module Pester
Remove-Module WieldingAnsi -ErrorAction SilentlyContinue
Import-Module ./WieldingAnsi.psm1



BeforeAll {
    $nakedValue = "test"
    $wansiValue =  "{:BoldOn:}test{:R:}"
}

Describe 'ConvertTo-AnsiString no Wansi' {
    
    It 'Should return Length = 4' {
        (ConvertTo-AnsiString $nakedValue).Length | Should -Be 4
    }

    It 'Should return NakedLength = 4' {
        (ConvertTo-AnsiString $nakedValue).NakedLength | Should -Be 4
    }    

    It 'Should return InvisibleLength = 0' {
        (ConvertTo-AnsiString $nakedValue).InvisibleLength | Should -Be 0
    }        

    It 'Should return Value = "test"' {
        (ConvertTo-AnsiString $nakedValue).Value | Should -Be $nakedValue
    }        
}

Describe 'ConvertTo-AnsiString with Wansi' {
    
    It 'Should return Length = 12' {
        $Wansi.Enabled = $true
        (ConvertTo-AnsiString $wansiValue).Length | Should -Be 12
    }

    It 'Should return NakedLength = 4' {
        (ConvertTo-AnsiString $wansiValue).NakedLength | Should -Be 4
    }    

    It 'Should return InvisibleLength = 8' {
        (ConvertTo-AnsiString $wansiValue).InvisibleLength | Should -Be 8
    }        

    It 'Should return Value = "`e[1mtest`e[0m"' {
        (ConvertTo-AnsiString $wansiValue).Value | Should -Be "`e[1mtest`e[0m"
    }        
}

Describe 'ConvertTo-AnsiString with Wansi Disabled' {
    
    It 'Should return Length = 12' {
        $Wansi.Enabled = $false
        (ConvertTo-AnsiString $wansiValue).Length | Should -Be 4
    }

    It 'Should return NakedLength = 4' {
        (ConvertTo-AnsiString $wansiValue).NakedLength | Should -Be 4
    }    

    It 'Should return InvisibleLength = 8' {
        (ConvertTo-AnsiString $wansiValue).InvisibleLength | Should -Be 0
    }        

    It 'Should return Value = "`test"' {
        (ConvertTo-AnsiString $wansiValue).Value | Should -Be "test"
    }        
}


Describe 'ConvertTo-AnsiString with Wansi PadLeft' {
    
    It 'Should return Length = 28' {
        $Wansi.Enabled = $true
        (ConvertTo-AnsiString $wansiValue -PadLeft 20).Length | Should -Be 28
    }

    It 'Should return NakedLength = 20' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 20).NakedLength | Should -Be 20
    }    

    It 'Should return InvisibleLength = 8' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 20).InvisibleLength | Should -Be 8
    }        

    It 'Should return Value = "`e[1m               test`e[0m"' {
        $value = ConvertTo-AnsiString $wansiValue -PadLeft 20
        $value.Value | Should -Be "                `e[1mtest`e[0m"
    }        
}


Describe 'ConvertTo-AnsiString with Wansi PadRight' {
    
    It 'Should return Length = 28' {
        $Wansi.Enabled = $true
        (ConvertTo-AnsiString $wansiValue -PadRight 20).Length | Should -Be 28
    }

    It 'Should return NakedLength = 20' {
        (ConvertTo-AnsiString $wansiValue -PadRight 20).NakedLength | Should -Be 20
    }    

    It 'Should return InvisibleLength = 8' {
        (ConvertTo-AnsiString $wansiValue -PadRight 20).InvisibleLength | Should -Be 8
    }        

    It 'Should return Value = "`e[1mtest`e[0m                "' {
        $value = ConvertTo-AnsiString $wansiValue -PadRight 20
        $value.Value | Should -Be "`e[1mtest`e[0m                "
    }        
}

Describe 'ConvertTo-AnsiString with Wansi PadLeft Short' {
        
    It 'Should return Length = 12' {
        $Wansi.Enabled = $true
        (ConvertTo-AnsiString $wansiValue -PadLeft 3).Length | Should -Be 12
    }

    It 'Should return NakedLength = 4' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 3).NakedLength | Should -Be 4
    }    

    It 'Should return InvisibleLength = 8' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 3).InvisibleLength | Should -Be 8
    }        

    It 'Should return Value = "`e[1mtest`e[0m"' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 3).Value | Should -Be "`e[1mtest`e[0m"
    }        
}

Describe 'ConvertTo-AnsiString with Wansi PadLeft Exact' {
        
    It 'Should return Length = 12' {
        $Wansi.Enabled = $true
        (ConvertTo-AnsiString $wansiValue -PadLeft 4).Length | Should -Be 12
    }

    It 'Should return NakedLength = 4' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 4).NakedLength | Should -Be 4
    }    

    It 'Should return InvisibleLength = 8' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 4).InvisibleLength | Should -Be 8
    }        

    It 'Should return Value = "`e[1mtest`e[0m"' {
        (ConvertTo-AnsiString $wansiValue -PadLeft 4).Value | Should -Be "`e[1mtest`e[0m"
    }        
}

Describe 'Expand-Tokens' {
        
    It 'Should expand' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "MyValue" -Force
        Expand-Tokens "{{TestValue}}-{{TestValue}}" | Should -Be "MyValue-MyValue"
    }

}

Describe 'Expand-Tokens prefix space' {
        
    It 'Should add space' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "MyValue" -Force
        Expand-Tokens "{{TestValue|< }}" | Should -Be " MyValue"
    }
}

Describe 'Expand-Tokens append space' {
        
    It 'Should add space' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "MyValue" -Force
        Expand-Tokens "{{TestValue|> }}" | Should -Be "MyValue "
    }
}

Describe 'Expand-Tokens append and prefix space' {
        
    It 'Should add space' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "MyValue" -Force
        Expand-Tokens "{{TestValue|> < }}" | Should -Be " MyValue "
    }
}

Describe 'Expand-Tokens append and prefix >' {
        
    It 'Should add space' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "MyValue" -Force
        Expand-Tokens "{{TestValue|> <\>}}" | Should -Be ">MyValue "
    }
}

Describe 'Expand-Tokens with ansi code' {
        
    It 'Should be proper length' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "X{:F15:}" -Force
        $as = ConvertTo-AnsiString "{{TestValue}}"

        $as.NakedLength | Should -Be 1
    }

}

Describe 'Expand-Tokens with prepend and append' {
        
    It 'Should be proper length' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "X" -Force
        $as = Expand-Tokens "{{TestValue|<>}}"

        $as | Should -Be " X "
    
    }

    It 'Should be proper length' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "X" -Force
        $as = Expand-Tokens "{{TestValue|><}}"

        $as | Should -Be " X "
    
    }

    It 'Should be proper length' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "X" -Force
        $as = Expand-Tokens "{{TestValue|<}}"

        $as | Should -Be " X"
    
    }

    It 'Should be proper length' {
        Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "TestValue" -Value "X" -Force
        $as = Expand-Tokens "{{TestValue|>}}"

        $as | Should -Be "X "
    
    }
}

Describe 'Format-Options' {

    It 'Should handle error' {
        
        $f = Get-FormatOptions "test|"   

    }
        
    It 'Should succed with prefix and append' {
        
        $f = Get-FormatOptions "test|>ab<cd"

        $f.Prefix | Should -Be $true
        $f.PrefixValue | Should -Be "cd"
        $f.Append | Should -Be $true
        $f.AppendValue | Should -Be "ab"
    
    }

}

Describe 'Format-Options escape' {

    It 'Should succeed with escape' {
        
        $f = Get-FormatOptions "test|<c\<d"

        $f.Value | Should -Be "test"
        $f.Prefix | Should -Be $true
        $f.PrefixValue | Should -Be "c<d"
        $f.Append | Should -Be $false
        $f.AppendValue | Should -Be ""
        
    
    }
}