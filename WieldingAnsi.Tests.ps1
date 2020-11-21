Import-Module Pester
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


Describe 'ConvertTo-AnsiString with Wansi PadLeft' {
    
    It 'Should return Length = 28' {
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
