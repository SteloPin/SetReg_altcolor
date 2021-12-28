;----------------------------------------------------------------------------
; 28.12.2021 by SteLoPin
; Version 1.0
;----------------------------------------------------------------------------
;ExitScreen = true
EscClose = true
i = 0
filesize = 0
dmd_colorize = 0
rom_count = 0
dmd_colorize_set0_count = 0
dmd_colorize_set1_count = 0
FormatTime, CurrentDateTime,, yyyy.MM.dd HH:mm:ss
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;----------------------------------------------------------------------------
p1=%1%
altcolor_path = %1% ; without \
p2=%2%
myScriptName := SubStr(A_ScriptName, 1 ,StrLen(A_ScriptName)-4)    
;MsgBox % myScriptName	
p1 := "test"   ; for debug purpose
p1 := "default" ; for debug purpose
if ( (%0% < 2 or p1 = "?" or p1 = "h" or p1 = "help") and p1 <> "default" and p1 <> "test")
{
    tmp := "28.12.2021 by SteLoPin stelopin@gmail.com"
	tmp := tmp . "`r`n`r`nProgram to set registery values for key dmd_colorize if altcolor exists or is missing."
	tmp := tmp . "`r`n`r`nPossible parameter:"
	tmp := tmp . "`r`n`r`npath to altcolor directory e.g. ''C:\Visual Pinball\VPinMAME\altcolor''"
	tmp := tmp . "`r`nwritelogfile=true|false (optional, create a logfile of processed registry entries)"
	tmp := tmp . "`r`nopennotepad=true|false (optional: open logfile with notepad after processing)"
	tmp := tmp . "`r`nshowconclusion=true|false Show conclusion after processing"
	tmp := tmp . "`r`nwritecsv=true|false (optional, create a csvfile of all registry entries)"
    ;tmp := "28.12.2021 Stefan Lorei stelopin@gmail.com`r`n`r`nProgram to set registery values for key dmd_colorize if altcolor exists or is missing.`r`n`r`Possible parameter: `r`n`r`nPath to altcolor directory e.g. "C:\Visual Pinball\VPinMAME\altcolor"`r`nwritelogfile=true|false (optional, create a logfile of processed registry entries) `r`nopennotepad=true|false (optional: open logfile with notepad after processing)`r`nshowconclusion=true|false Show conclusion after processing`r`nwritecsv=true|false (optional, create a csvfile of all registry entries)"

	tmp := tmp . "`r`n`r`nDefault values are: writelogfile=true openNotepad=false writecsv=true showconclusion=true" 
	tmp := tmp . "`r`n`r`nStart Program with"
	tmp := tmp . "`r`n`r`nSetReg_altcolor.exe default"
	tmp := tmp . "`r`nor SetReg_altcolor.exe ''C:\Visual Pinball\VPinMAME\altcolor'' writelogfile=false openNotepad=false writecsv=true" 
	msgbox %tmp%
    ExitApp
}

; Set default values
altcolor_path = c:\Visual Pinball\VPinMAME\altcolor ; without \
writelogfile := false
openNotepad := false
showconclusion := false
writecsv := true

if (p1 = "default") {
	; set options for testing
	altcolor_path = c:\Visual Pinball\VPinMAME\altcolor ; without \
	writelogfile := true
	openNotepad := false
	showconclusion := true
	writecsv := true
}
if (p1 = "test") {
	; set options for testing
	altcolor_path = c:\Visual Pinball\VPinMAME\altcolor ; without \
	writelogfile := true
	openNotepad := false
	showconclusion := false
	writecsv := true
}

tmp2 = ""
Loop, %0% {			; process each command line parameter
    If (%A_Index% = "writelogfile=true")
        writelogfile := true
    Else If (%A_Index% = "writelogfile=false")
        writelogfile := false
    Else If (%A_Index% = "showconclusion=true")
        showconclusion := true
    Else If (%A_Index% = "showconclusion=false")
        showconclusion := false
    Else If (%A_Index% = "openNotepad=true")
        openNotepad := true
    Else If (%A_Index% = "openNotepad=false")
        openNotepad := false
    Else If (%A_Index% = "writecsv=true")
        writecsv := true
    Else If (%A_Index% = "writecsv=false")
        writecsv := false
	
	param := %A_Index%  ; get value of parameter id at A_Index
	tmp2 = %tmp2% %param% 
} ; loop

if (writelogfile = true) {
	if FileExist(myScriptName . ".log")		
		tmp := "`r`n" . CurrentDateTime . " Started " . A_ScriptName . " - with parameter " . tmp2 . ""
	else
		tmp := CurrentDateTime . " Started " . A_ScriptName . " - with parameter " . tmp2 . ""
	FileAppend,	%tmp%, %myScriptName%.log
}
if (writecsv = true) {
	if FileExist(myScriptName . ".csv")
		FileRecycle, %myScriptName%.csv
	tmp := "rom;altcolor_file_exist;dmd_colorize_before;dmd_colorize_after;change"
	FileAppend,	%tmp%, %myScriptName%.csv
}

Loop Reg, HKCU\SOFTWARE\Freeware\Visual PinMame, R KV ; Recursively retrieve keys and values.
{
	i ++
	;if (i <> 1590)
    ;    continue ; Skip the below and start a new iteration
	romname := StrSplit(A_LoopRegSubKey, "\")[4]
	if (romname = "")
        continue ; Skip the below and start a new iteration
	if (A_LoopRegName <> "dmd_colorize")
        continue ; Skip the below and start a new iteration

	rom_count ++
	dmd_colorize := ReadReg(romname,"dmd_colorize")
	if FileExist(altcolor_path . "\" . romname . "\pin2dmd.pal")
		altcolor_file_exist := "Y"
	else
		altcolor_file_exist := "N"
	
	if (p1 = "test") {
		MsgBox, 4, , i=%i%`nA_LoopRegName= %A_LoopRegName%`nA_LoopRegType=%A_LoopRegType%`nA_LoopRegKey=%A_LoopRegKey%`nA_LoopRegSubKey=%A_LoopRegSubKey%`nA_LoopRegTimeModified=%A_LoopRegTimeModified%`nromname=%romname%`ndmd_colorize=%dmd_colorize%`naltcolor_file_exist=%altcolor_file_exist%`n`nWeiter?
		IfMsgBox, No
			break
	}		

	If ( altcolor_file_exist = "Y" and dmd_colorize = 0 ) {
		; change at registry needed
		WriteReg(romname,"dmd_colorize",1)
		dmd_colorize_set1_count ++
		if (writelogfile = true) {
			tmp := "`r`n" . CurrentDateTime . " altcolor-file exist and dmd_colorize <> 1 : Set dmd_colorize to 1 for rom " . romname
			FileAppend,	%tmp%, %myScriptName%.log
			;MsgBox %  "" . tmp . ""
		}
		if (writecsv = true) {
			tmp := "`r`n" . romname . ";" . altcolor_file_exist . ";" . dmd_colorize . ";1;Y"
			FileAppend,	%tmp%, %myScriptName%.csv
		}
		
	} else If ( altcolor_file_exist = "N" and dmd_colorize = 1 ) {
		; change at registry needed
		WriteReg(romname,"dmd_colorize",0)
		dmd_colorize_set0_count ++
		if (writelogfile = true) {
			tmp := "`r`n" . CurrentDateTime . " altcolor-file not exist and dmd_colorize <> 0 : Set dmd_colorize to 0 for rom " . romname
			FileAppend,	%tmp%, %myScriptName%.log
			;MsgBox %  "" . tmp . ""
		}
		if (writecsv = true) {
			tmp := "`r`n" . romname . ";" . altcolor_file_exist . ";" . dmd_colorize . ";0;Y"
			FileAppend,	%tmp%, %myScriptName%.csv
		}
	} else {
		; no change at registry needed
		if (writecsv = true) {
			tmp := "`r`n" . romname . ";" . altcolor_file_exist . ";" . dmd_colorize . ";" . dmd_colorize . ";N"
			FileAppend,	%tmp%, %myScriptName%.csv
			;MsgBox % tmp
		}
	}

}
mystring := "Processed " . rom_count . " roms at registery. Set dmd_colorize to 0:" . dmd_colorize_set0_count . " times and to 1:" . dmd_colorize_set1_count . " times."
OutputDebug, %mystring%
if (writelogfile = true) {
	;tmp := "`r`n" . CurrentDateTime . "Conclusion:`r`n`r`n " . mystring
	tmp := "`r`n" . CurrentDateTime . " Conclusion : " . mystring
	FileAppend,	%tmp%, %myScriptName%.log
}
if (openNotepad = true)
{
	Run Notepad %myScriptName%.log
}
if (showconclusion = true) {
	tmp = % "Processed " . rom_count . " roms at registery`r`nSet dmd_colorize to 0 : " . dmd_colorize_set0_count . " times`r`nSet dmd_colorize to 1 : " . dmd_colorize_set1_count . " times"
	MsgBox %  "" . tmp . ""
}
ExitApp

; ######################################################
; Not used !
; Lesen Dateien und schreiben Reg
; ######################################################
Loop Files, %altcolor_path%\*.pal, R,F,D  ; Unterordner rekursiv durchwandern.
{
	i ++
	;if (i <> 3)
    ;    continue ; Skip the below and start a new iteration

	filesize := A_LoopFileSize
	romname := StrSplit(A_LoopFileDir, "\")[5]

	if (A_LoopFileSize >= 0)
	{
		dmd_colorize := ReadReg(romname,"dmd_colorize")
		MsgBox, 4, , i=%i%`nA_LoopFileDir =  %A_LoopFileDir%`nromname=%romname%`ndmd_colorize = %dmd_colorize%`nDateiname = %A_LoopFileFullPath%`n`n mit Größe %filesize% und %A_LoopFileSize%`n`nWeiter?
		IfMsgBox, No
			break

		If ( dmd_colorize != 1) {
				WriteReg(romname,"dmd_colorize",1)
		}

	}
}
 ; MsgBox Ende + %i%
ExitApp


ReadReg(romname,var1) {
		RegRead, regValue, HKEY_CURRENT_USER, Software\Freeware\Visual PinMame\%romname%, %var1%
		Return %regValue%
	}

WriteReg(romname,var1, var2) {
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Freeware\Visual PinMame\%romname%, %var1%, %var2%
	}

