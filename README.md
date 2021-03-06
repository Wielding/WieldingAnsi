# WieldingAnsi


Table of Contents
=================
<!-- toc -->
- [WieldingAnsi](#wieldingansi)
- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
  - [Usage](#usage)
  - [ConvertTo-AnsiString](#convertto-ansistring)
  - [Example](#example)
  - [Write-Wansi](#write-wansi)
  - [Example](#example-1)
  - [Wansi Tokens](#wansi-tokens)
  - [Installation](#installation)
  - [Prompt Example](#prompt-example)
- [Considerations](#considerations)
- [Future](#future)
  - [Have fun making your Powershell console scripts look a little better with ease!](#have-fun-making-your-powershell-console-scripts-look-a-little-better-with-ease)
<!-- tocstop -->

Introduction
============
:warning: This is a work in progress so the master branch could break your Powershell profile or scripts until it is deemed stable.:warning: 

Please be patient with the documentation.  It is a bit fragmented since my current focus is on the code and I am throwing things in here as I implement and change them.  That will be addressed when a stable version is reached.

WieldingAnsi is Powershell module that contains variables and functions to make displaying text with ANSI escape sequences in the console easier.  It also has a configuration value that will enable scripts to completely disable the ANSI escape sequences when using [Wansi Tokens](#wansi-tokens) if desired without having to change your code.

WieldingAnsi is written to be a global theming engine.  The `$Wansi` class is used across all scripts that call the [Write-Wansi](#write-wansi) or [ConvertTo-AnsiString](#convertto-ansistring) functions within the same Powershell console session. 

For Windows users this module requires a minimum of Windows 10 1803.  When using this module under Windows it is recommended to use [Windows Terminal](https://github.com/microsoft/terminal).  Any other console may give unpredictable results and might not work at all.

This module has been tested under some WSL distributions and seems to work fine but more testing is required to back up that claim.

For an example of what is possible with ANSI escape codes check out my example project at https://github.com/Wielding/WieldingProcess. (Windows Only)

This project uses ansi escape codes for moving the cursor, clearning the screen and switching to alternate screen buffers by implementing custom [Wansi Tokens](#wansi-tokens).  

Usage
-----
The `Show-AnsiCodes` function displays all of the codes supported in the console to assist with identifying the Wansi codes to use.  

```powershell
Show-AnsiCodes <no parameters>
```
![output](images/ansi_codes.png)

There are 2 ways to use the codes in your script.  The first way is directly accessing the values with the exported `$Wansi` class.

The following will display the word 'Test' with a Red `$($Wansi.F3)` foreground and Blue `$($Wansi.B4)` background, then reset `$($Wansi.R)` the console to defaults.

```powershell
Write-Host "$($Wansi.F3)$($Wansi.B4)Test$($Wansi.R)`n"
```
![output](images/wansi-host.png)

The second way is to use [Wansi Tokens](#wansi-tokens) and call either the `ConvertTo-AnsiString` or `Write-Wansi` exported functions.

ConvertTo-AnsiString
--------------------

The `ConvertTo-AnsiString` function accepts a string containing [Wansi Tokens](#wansi-tokens) that get converted to ANSI escape sequences.  

The command only takes one parameter.
```powershell
 ConvertTo-AnsiString [[-Value] <String>]
 ```

Example
-------
If you enter the following on the Powershell command line

```powershell
ConvertTo-AnsiString "{:F3:}{:B4:}Test{:R:}"
```

It will display

```powershell
Length NakedLength InvisibleLength Value
------ ----------- --------------- -----
    26           4              22 Test
```    


As you can see the `ConvertTo-AnsiString` returns an object with the following properties.

* **Length** - the length of the string including the ANSI escape codes
* **NakedLength** - the length of the visible text in the string minus the ANSI escape codes
*  **InvisibleLength** - the total length of all of the non printing ANSI escape sequences in the returned `Value`
* **Value** - the string with the ANSI escape codes

Write-Wansi
-----------
If you only want to display the string with the Wansi tokens interpreted to your host you can Call `Write-Wansi` which will use `Write-Host` to display the string to the console without the need to call `ConvertTo-AnsiString`. 

```powershell
Write-Wansi <-Value [string]>
```

 You don't have access to the properties of the ANSI string when using `Write-Host` since it is just a shortcut to writing to the console.  For that use [ConvertTo-AnsiString](#convertto-ansistring).

Example
-------
The following will produce the same ANSI encoded string as the previous `ConvertTo-AnsiString` example without bothering with the intermediate object.

NOTE: Write-Wansi does not produce a NewLine character so you must include it in your string as an escape character or use Write-Host afterwards to write one manually.
```powershell
Write-Wansi "{:F3:}{:B4:}Test{:R:}`n"
```

![output](images/write-wansi.png)


Wansi Tokens
------------
Wansi tokens have the same names as the `$Wansi` class properties and are delimited with `{:` and `:}`.  These tokens can be embedded in strings passed to `Write-Wansi` and `ConvertTo-AnsiString` which will convert them to the associated `$Wansi` class property.  You can see this in action by checking out my Powershell `ls` replacement project at https://github.com/Wielding/WieldingLs.  It uses Wansi tokens to apply styles to directory listings while mimicking the **nix* `ls` command.

All Wansi tokens are case sensitive.  If you don't use proper case the token will not be recognized and will be seen in your result instead of converted to an ANSI sequence.  

The supported style tokens are:

  * `"{:UnderlineOn:}"` - start underlining
  * `"{:UnderlineOff:}"` - stop underlining
  * `"{:BoldOn:}"` - start bold
  * `"{:BoldOff:}"` - stop bold
  * `"{:InverseOn:}"` - start inverse
  * `"{:InverseOff:}"` - stop inverse
  * `"{:R:}"` - reset all attributes

Foreground and background colors can be set using "F" and "B" prefixes followed by the number displayed when calling the `Show-AnsiCodes` function.

* `"{:F#}"` 
* `"{:B#}"` 

You can completely disable the Wansi Token colors and styles by setting the global class property `$Wansi.Enabled` to `$false`. This will only change functionality that uses Wansi Tokens and will not change any behavior if you are accessing the ANSI codes directly using the `$Wansi` class.  This will keep all padding the same and adjust the return values from `ConvertTo-AnsiString` to reflect the lack of ANSI codes in the returned `Value`.  

Beware that since `$Wansi.Enabled` is global it will disable all Wansi Token handling in the current Powershell session until it is set back to `$true`.  That means if you are using it in a script and other scripts may be using WieldingAnsi in the same session you should save the initial value and set it back before exiting as to not change the behavior of other scripts.


Installation
------------
```powershell
Install-Module WieldingAnsi
```
Prompt Example
--------

Here is a prompt function that can be placed in your profile using the exported `$Wansi` class.

```powershell
Import-Module WieldingAnsi

function prompt {
  $line =  "-".PadRight($host.UI.RawUI.WindowSize.Width - $env:USERDOMAIN.Length - 1, "-")
  Write-Host "$($Wansi.F226)$line$($Wansi.F202) $($Wansi.BoldOn)$env:USERDOMAIN$($Wansi.R)"
  Write-Host "$($Wansi.F15)[$($Wansi.F46)$((Get-Location).Path.Replace($($HOME), '~'))$($Wansi.F15)]$($Wansi.R)" -NoNewline
  Write-Host "$($Wansi.F2)`n▶$($Wansi.R)" -NoNewline
 
  return " "
}
```

This produces the following prompt in you Powershell console

![output](images/prompt.png)

You can use the modules `Write-Wansi` function to get the same result with this code.

```powershell
function prompt {
  $line =  "-".PadRight($host.UI.RawUI.WindowSize.Width - $env:USERDOMAIN.Length - 1, "-")
  Write-Wansi "{:F226:}$line{:F202:} {:BoldOn:}$env:USERDOMAIN{:R:}"
  Write-Wansi "{:F15:}[{:F46:}$((Get-Location).Path.Replace($($HOME), '~')){:F15:}]{:R:}"
  Write-Wansi "{:F2:}`n▶{:R:}"
 
  return " "
}

```

Considerations
==============
It gets difficult to handle formatting text containing ANSI escape code due to the fact that strings with ANSI escape sequences are longer than they look. The escape sequences are invisible but still count towards a strings length.  That is the reason `ConvertTo-AnsiString` returns an object with the `NakedLength` property.  The `NakedLength` property contains the length of the input string minus the length of the ANSI sequences.

You can use the `NakedLength` property to do any calculations you might need to create formatted output.  

The `ConvertTo-AnsiString` function is a simple tokenizer that checks tokens against the properties in the `$Wansi` class.  That means that you can add your own tokens by simply adding them to `$Wansi`.

For example if you type the following in the console

```powershell
Write-Wansi "{:X:}Test{:R:}"
```
it would return `"{:X:}Test"` since it does not know of any token named 'X'.

If you were to enter the following in your console
```powershell
Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "X" -Value "This is a "
Write-Wansi "{:X:}Test{:R:}"
```

The result would be `"This is a Test"` since the $Wansi class now contains a property named 'X'.

Just be warned that the if you use `ConvertTo-AnsiString` with a visible custom token like above the `NakedLength` property will not include the custom token length. It does not expect any of the tokens to produce any visible output. 

However, you can create custom tokens that contain any complex or new ANSI escape sequences on your own (e.g. cursor movement) and `NakedLength` should be correct.  Depending on the console you are using you can try adding some of the codes listed at https://en.wikipedia.org/wiki/ANSI_escape_code

For example:

```powershell
Add-Member -InputObject $Wansi -MemberType NoteProperty -Name "DoubleUnderlineOn" -Value "`e[21m"
$GdcTheme.FileAttributesColors["Directory"] = "{:F3:}{:DoubleUnderlineOn:}"
```

This first line will add a property to the `$Wansi` object so that you can use the Wansi Token  `{:DoubleUnderlineOn:}`.  The second line will set the File Attribute "Directory" to have a Yellow foreground with a double underline style.  Once again, remember that not all ANSI escape sequences are supported on all Powershell console hosts.  This particular code woks fine using [Windows Terminal](https://github.com/microsoft/terminal) but failed to work on the default Windows Powershell console.

Future
======
I do plan on enhancing and maintaining this code.  My [WieldingLs](https://github.com/Wielding/WieldingLs) project depends on this which I use across several platforms so I need to keep it working.

## Have fun making your Powershell console scripts look a little better with ease! ##