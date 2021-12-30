;----------------------------------------------------------------------------------------------------
; SetReg_altcolor (December 28, 2021)
; https://github.com/SteloPin/SetReg_altcolor
; This script can be edited and compiled with AutoHotKey for make the executable SetReg_altcolor.exe
; Version 1.0 by SteloPin stelopin@gmail.com
;----------------------------------------------------------------------------------------------------
; https://jacks-autohotkey-blog.com/2019/01/13/using-gui-checkbox-controls-to-set-hotstring-options-autohotkey-technique/#more-40161
#SingleInstance force
FormatTime, CurrentDateTime,, yyyy.MM.dd HH:mm:ss
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory
; initial some vars
appversion = 1.0
i = 0
dmd_colorize = 0
rom_count = 0
dmd_colorize_set0_count = 0
dmd_colorize_set1_count = 0
; get Command Line Options
p1=%1%
altcolor_path = %1%
myScriptName := SubStr(A_ScriptName, 1, StrLen(A_ScriptName)-4)  ; Scriptname without .ahk or .exe   
IniFile=%A_ScriptDir%\%myScriptName%.ini
;p1 := "default" ; for debug purpose
;p1 := "test"   ; for debug purpose
;p1 := "runsilent" ; for debug purpose
; show helptext
;if ( (%0% < 1 or p1 = "?" or p1 = "h" or p1 = "help") and p1 <> "default" and p1 <> "test" and p1 <> "runsilent")
if (p1 = "?" or p1 = "h" or p1 = "help")
	{
	showHelp()
;	ExitApp
}

; --------------------------------
; Set default values then read ini
; --------------------------------
if (p1 = "" or p1 = "default") {
	altcolor_path = c:\Visual Pinball\VPinMAME\altcolor
	writelogfile := true
	opennotepad := false
	showconclusion := true
	writecsv := true
	createregbackup := true
	runsilent := false
}
if (p1 = "runsilent") {
	runsilent := true
}

readMyIniFile()

; overwite ini-values for test
if (p1 = "test") {
	altcolor_path = c:\Visual Pinball\VPinMAME\altcolor
	writelogfile := true
	opennotepad := false
	showconclusion := false
	writecsv := true
	createregbackup := false
	runsilent := false
}

; get command-line-arguments and overwrite default-values
cmdparameter := ""
Loop, %0% {
	If (%A_Index% = "writelogfile=true")
		writelogfile := true
	Else If (%A_Index% = "writelogfile=false")
		writelogfile := false
	Else If (%A_Index% = "showconclusion=true")
		showconclusion := true
	Else If (%A_Index% = "showconclusion=false")
		showconclusion := false
	Else If (%A_Index% = "opennotepad=true")
		opennotepad := true
	Else If (%A_Index% = "opennotepad=false")
		opennotepad := false
	Else If (%A_Index% = "writecsv=true")
		writecsv := true
	Else If (%A_Index% = "writecsv=false")
		writecsv := false
	Else If (%A_Index% = "createregbackup=true")
		createregbackup := true
	Else If (%A_Index% = "createregbackup=false")
		createregbackup := false
	Else If (%A_Index% = "runsilent=true")
		runsilent := true
	Else If (%A_Index% = "runsilent=false")
		runsilent := false
	cmdparameter := cmdparameter %A_Index%  ; collect parameters
} 

; remove if last char is / or \
tmp := SubStr(altcolor_path, 0)  ; get last char
if (tmp = "/" or tmp = "\" )
	altcolor_path := SubStr(altcolor_path, 1, StrLen(altcolor_path)-1)

; if needed create ini with default values
ifnotexist,%IniFile% 
	WriteMyIniFile()

; --------------------
; create and fill GUI
; --------------------
createGUI()
myListContent := fill_myListContent()
;msgbox 1:%runsilent%, 2:runsilent

if (runsilent = true) {
	i = 0
	Gui, Show
	Gui, Submit, NoHide ; Save the input from the user to each control's associated variable.
	WinMove, %A_ScriptName%, 1, 1, 1, 1
	;i++ 
	;msgbox %i%
	Gosub, ButtonProcess
	Gui, Destroy
	ExitApp
} else
	Gui, Show
return

; ---------------
; Action handler
; ---------------
MyListView:
if (A_GuiEvent = "DoubleClick")
{
	;LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
	ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"
}
Return

RescanRegistry:
fill_myListContent() 
ToolTip Rescan done
SetTimer, RemoveToolTip, -2000
Return

ButtonWriteIni:
Gui, Submit, NoHide ; Save the input from the user to each control's associated variable.
WriteMyIniFile()
ToolTip Default values written to ini-file
SetTimer, RemoveToolTip, -3000
Return

ButtonHelp:
showHelp()
Return

GuiEscape: ; enables exit on ESC
ButtonQuit:
Gui, Destroy
GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
ExitApp
Return

ButtonProcess:
Gui, Submit, NoHide ; Save the input from the user to each control's associated variable.
UpdateDmdColorize()
if (runsilent = false)
{
	ToolTip Registry has been updated
	SetTimer, RemoveToolTip, -3000
}
return

ExitApp

; ######################################################
; Not used !
; Lesen Dateien und schreiben Reg
; ######################################################
Loop Files, %altcolor_path%\*.pal, R,F,D  ; Unterordner rekursiv durchwandern.
{
	i ++
	;if (i <> 3)
     ;   continue ; Skip the below and start a new iteration
	filesize := A_LoopFileSize
	romname := StrSplit(A_LoopFileDir, "\")[5]
	if (A_LoopFileSize >= 0)
	{
		dmd_colorize := ReadReg(romname,"dmd_colorize")
		MsgBox, 4, , i=%i%`nA_LoopFileDir =  %A_LoopFileDir%`nromname=%romname%`ndmd_colorize = %dmd_colorize%`nDateiname = %A_LoopFileFullPath%`n`n mit Größe %filesize% und %A_LoopFileSize%`n`nWeiter?
		IfMsgBox, No
			break
		
		If (dmd_colorize != 1) {
			WriteReg(romname,"dmd_colorize",1)
		}		
	}
}
 ; MsgBox Ende + %i%
ExitApp

RemoveToolTip:
ToolTip
return

ReadReg(romname,var1) {
	RegRead, regValue, HKEY_CURRENT_USER, Software\Freeware\Visual PinMame\%romname%, %var1%
	Return %regValue%
}

WriteReg(romname,var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Freeware\Visual PinMame\%romname%, %var1%, %var2%
}

readMyIniFile()
{
	global IniFile ; use global var at function
	;msgbox %IniFile%	
	global altcolor_path 
	; value, file section, Key, Default if not available
	IniRead, altcolor_path, %IniFile%, Main, altcolor_path, %altcolor_path%
	;msgbox ini altcolor_path=%altcolor_path%
	global writelogfile
	IniRead, writelogfile, %IniFile%, Main, writelogfile, %writelogfile%
	global showconclusion
	IniRead, showconclusion, %IniFile%, Main, showconclusion, %showconclusion% 
	global opennotepad
	IniRead, opennotepad, %IniFile%, Main, opennotepad, %opennotepad%
	global writecsv
	IniRead, writecsv, %IniFile%, Main, writecsv, %writecsv%
	global createregbackup
	IniRead, createregbackup, %IniFile% ,Main, createregbackup, %createregbackup% 		
}

WriteMyIniFile()
{
	global IniFile ; use global var at function
	;msgbox %IniFile%	
	global altcolor_path
	IniWrite, %altcolor_path%, %IniFile%, Main, altcolor_path ; value, file section, Key
	global writelogfile
	IniWrite, %writelogfile%, %IniFile%, Main, writelogfile 
	global showconclusion
	IniWrite, %showconclusion%, %IniFile%, Main, showconclusion 
	global opennotepad
	IniWrite, %opennotepad%, %IniFile%, Main, opennotepad 
	global writecsv
	IniWrite, %writecsv%, %IniFile%, Main, writecsv 
	global createregbackup
	IniWrite, %createregbackup%, %IniFile%, Main, createregbackup 	
}

createGUI()
{
	global myScriptName ; use global var at function
	global appversion
	global altcolor_path
	global writelogfile
	global showconclusion
	global opennotepad
	global writecsv
	global createregbackup
	myListContent := "Process / Rom|altcolor-file exist|dmd colorize current|dmd colorize after|change proposed| " ; | for empty row
	StringReplace, myListArray, myListContent, `, ,| 
	; ys same row, xs same column
	; The ym option starts a new column of controls
	; xp and xs mean relative to the start position of the last control
	Gui, Add, Text, section, %myScriptName% Version %appversion%
	Gui, Add, Link, ys x+260, Open <a href="https://github.com/SteloPin/SetReg_altcolor">SetReg_altcolor</a> at GitHub
	;Designate the groupbox as a section and then use xs/ys to position controls relative to the upper-left corner of the groupbox
	Gui, Add, GroupBox, xm ym+25 section xm w560 h148, Default values
	Gui, Add, Text, xs+10 ys+20, Path to altcolor directory : 
	Gui, Add, Edit, xs+135  ys+17 r1 w300 Valtcolor_path, %altcolor_path%
	if (writelogfile = 1)
		Gui, Add, CheckBox, section xs+10 y+8 checked Vwritelogfile, Write logfile including the processed changes
	Else
		Gui, Add, CheckBox, section xs+10 y+8 Vwritelogfile , Write logfile including the processed changes
	if (opennotepad = 1)
		Gui, Add, CheckBox, checked xs Vopennotepad, Show logfile with notepad after processing
	Else
		Gui, Add, CheckBox, xs Vopennotepad, Show logfile with notepad after processing
	if (createregbackup = 1)
		Gui, Add, CheckBox, checked Vcreateregbackup , Create a backup of registry 'HKEY_CURRENT_USER\Software\Freeware\Visual PinMame' before processing 
	Else
		Gui, Add, CheckBox, Vcreateregbackup, Create a backup of registry 'HKEY_CURRENT_USER\Software\Freeware\Visual PinMame' before processing 
	if (showconclusion = 1)
		Gui, Add, CheckBox, checked Vshowconclusion, Show conclusion-window after processing
	Else
		Gui, Add, CheckBox, Vshowconclusion, Show conclusion-window after processing
	if (writecsv = 1)
		Gui, Add, CheckBox,checked Vwritecsv, Write csv-file of all registry entries
	Else
		Gui, Add, CheckBox, Vwritecsv, Write csv-file of all registry entries
	Gui, Add, Button, section y+20 gButtonProcess, Update dmd_colorize
	Gui, Add, Button, ys gRescanRegistry, Rescan registry
	Gui, Add, Button, ys gButtonWriteIni, Save default values
	Gui, Add, Button, ys gButtonQuit w80, Quit
	Gui, Add, Button, ys gButtonHelp w80, Help
	Gui, Add, Text,section xs x10 y+8, Roms from registry and proposed changes with button Update dmd_colorize :
	Gui, Add, ListView, Checked r20 w560 gMyListView, %myListArray%	
}

fill_myListContent() {
	global altcolor_path
	LV_Delete() ; delete all rows
	; collect items for ListView
	;i := 0
	myListContent := "" ; "check/Rom|altcolor-file exist|dmd colorize before|dmd colorize after|changeTo"	
	Loop Reg, HKCU\SOFTWARE\Freeware\Visual PinMame, R KV ; Recursively retrieve keys and values.
	{		
		rowchecked := false
		myRowContent := ""	
		romname := StrSplit(A_LoopRegSubKey, "\")[4]
		if (romname = "")
			continue ; Skip the below and start a new iteration
		if (A_LoopRegName <> "dmd_colorize")
			continue ; Skip the below and start a new iteration
		myRowContent := myRowContent . romname
		i ++	
		if FileExist(altcolor_path . "\" . romname . "\pin2dmd.pal")
			altcolor_file_exist := "Y"
		else
			altcolor_file_exist := "N"
		myRowContent := myRowContent . "|" . altcolor_file_exist
		
		dmd_colorize := ReadReg(romname,"dmd_colorize")
		myRowContent := myRowContent . "|" . dmd_colorize ; before
		
		If (altcolor_file_exist = "Y" and dmd_colorize = 0) {
			; change at registry needed
			myRowContent := myRowContent . "|1" ; after
			myRowContent := myRowContent . "|Y" ; change
			rowchecked := true
		} else If (altcolor_file_exist = "N" and dmd_colorize = 1) {
			; change at registry needed
			myRowContent := myRowContent . "|0" ; after
			myRowContent := myRowContent . "|Y" ; change
			rowchecked := true
		} else {
			; no change at registry needed
			myRowContent := myRowContent . "|" . dmd_colorize ; after
			myRowContent := myRowContent . "|N" ; change
			rowchecked := false
		}
		; empty row for auto width needed
		myRowContent := myRowContent . "|" ; empty row
		if (rowchecked = true)
			LV_Add("Check", StrSplit(myRowContent, "|")*) ; split the line into cells by pipes
		else
			LV_Add("-Check", StrSplit(myRowContent, "|")*) ; split the line into cells by pipes
		; add row seperatpor
		myListContent := myListContent . myRowContent . "#" 
		; MsgBox "Iterate" . %i% . " myListContent" . %myListContent%
	} ; Loop Reg	
	
	; remove last #
	myListContent := SubStr(myListContent, 1 ,StrLen(myListContent)-1)
	
	;; ophram - Fill listView from the array:
	;for index, element in StrSplit(myListContent, "#") ; Enumeration is the recommended approach in most cases.
	;{
	    ; Using "Loop", indices must be consecutive numbers from 1 to the number
	    ; of elements in the array (or they must be calculated within the loop).
	    ; MsgBox % "Element number " . A_Index . " is " . Array[A_Index]
	
	    ; Using "for", both the index (or "key") and its associated value
	    ; are provided, and the index can be *any* value of your choosing.
	    ; MsgBox % "Element number " . index . " is " . element
	;	LV_Add("", StrSplit(element, "|")*) ; split the line into cells by pipes	
	;}

	LV_ModifyCol("AutoHdr")  ; Auto-size each column to fit its contents.
	;LV_ModifyCol(1, 120)  ; fix for Rom  width
	LV_ModifyCol(2, "Text Center")  ; altcolor-file exist
	LV_ModifyCol(3, "Integer Center")  ; dmd colorize before
	LV_ModifyCol(4, "Integer Center")  ; dmd colorize after
	LV_ModifyCol(5, "Text Center")  ; changeTo
	;LV_ModifyCol(1,"")  ; Auto-size each column to fit its contents.
	LV_ModifyCol(5, "SortDesc")  ; changeTo -> Y first
	
	Return %myListContent%
}

UpdateDmdColorize()
{
	global writelogfile
	global myScriptName
	global CurrentDateTime
	global cmdparameter
	global altcolor_path ; use global var at function
	global writecsv
	global createregbackup
	global opennotepad
	global showconclusion
	dmd_colorize_set0_count = 0
	dmd_colorize_set1_count = 0
	rom_count = 0

	if (writelogfile = true) {
		tmp := ""
		if FileExist(myScriptName . ".log")		
			tmp := "`r`n"
		tmp := tmp . CurrentDateTime . " Started " . A_ScriptName . " - with parameter " . cmdparameter . ""
		FileAppend,	%tmp%, %myScriptName%.log
	}
	
	if (writecsv = true) {
		if FileExist(myScriptName . ".csv")
			FileRecycle, %myScriptName%.csv
		tmp := "rom;altcolor_file_exist;dmd_colorize_before;dmd_colorize_after;changeTo"
		FileAppend,	%tmp%, %myScriptName%.csv
	}
	
	if (createregbackup = true) {
		tmp2 := ""
		FormatTime, tmp2,, yyyyMMdd_HHmmss
		ExportKey := "HKEY_CURRENT_USER\Software\Freeware\Visual PinMame"
		tmp := "" .  A_ScriptDir . "\" . myScriptName . "_" . tmp2 . "_bak.reg"
		;msgbox % tmp
		RunWait, regedit.exe /e "%tmp%" "%ExportKey%"	
	}
	
	Loop % LV_GetCount()
	{
		dmd_colorize_after := 0
		change_proposed := ""
		rom_count ++		
		LV_GetText(romname, A_Index,1)
		LV_GetText(altcolor_file_exist, A_Index,2)
		LV_GetText(dmd_colorize, A_Index,3)
		LV_GetText(dmd_colorize_after, A_Index,4)
		LV_GetText(change_proposed, A_Index,5)
		
		RowNumber := A_Index           ;get first selected row
		RowChecked := LV_GetNext(RowNumber - 1 , "Checked" )
		If ( RowNumber = RowChecked )	{
			
			;Msgbox row %RowNumber%, rom=%romname%, altcolor_file_exist=%altcolor_file_exist%, dmd_colorize=%dmd_colorize%, dmd_colorize_after=%dmd_colorize_after%, change_proposed=%change_proposed% 
			;continue ; debug Skip the below and start a new iteration
			
			If (change_proposed = "Y") {
				; change to registry needed
				WriteReg(romname,"dmd_colorize",dmd_colorize_after)
				if (dmd_colorize_after = 0)
					dmd_colorize_set0_count ++
				else
					dmd_colorize_set1_count ++
				if (writelogfile = true) {
					tmp := "`r`n" . CurrentDateTime . " Rom " . romname . " - altcolor_file_exist=" . altcolor_file_exist . " Set dmd_colorize from " . dmd_colorize " to " . dmd_colorize_after 
					FileAppend,	%tmp%, %myScriptName%.log
				}
			}
		} ; RowCchecked
		
		; write csv for all roms
		if (writecsv = true) {
			tmp := "`r`n" . romname . ";" . altcolor_file_exist . ";" . dmd_colorize . ";" . dmd_colorize_after . ";" . change_proposed
			FileAppend,	%tmp%, %myScriptName%.csv
		}
	} ; loop Reg
	
	if (writelogfile = true) {
		tmp := "`r`n" . CurrentDateTime . " Conclusion : " . mystring
		tmp := tmp . "`r`n" . CurrentDateTime . " Processed " . rom_count . " roms at registery"
		tmp := tmp . "`r`n" . CurrentDateTime . " Set dmd_colorize to 0 : " . dmd_colorize_set0_count . " times"
		tmp := tmp . "`r`n" . CurrentDateTime . " Set dmd_colorize to 1 : " . dmd_colorize_set1_count . " times"
		mystring := tmp
		FileAppend,	%tmp%, %myScriptName%.log
	}
	
	if (opennotepad = true)
	{
		Run Notepad %myScriptName%.log
	}
	
	if (showconclusion = true) {
		tmp := "Processed " . rom_count . " roms at registery"
		tmp := tmp . "`r`n`r`nSet dmd_colorize to 0 : " . dmd_colorize_set0_count . " times"
		tmp := tmp . "`r`nSet dmd_colorize to 1 : " . dmd_colorize_set1_count . " times"
		MsgBox %  "" . tmp . ""
	}
	; refresh ListView
	myListContent := fill_myListContent()
}

showHelp()
{
	global myScriptName	
	Help =
(

	SetReg_altcolor 28.12.2021 by SteLoPin stelopin@gmail.com

	The program is primily used to maintain registry-key dmd_colorize at HKEY_CURRENT_USER\Software\Freeware\Visual PinMame.
	
	To setup vpinmame with colorized DMDs, file pin2dmd.pal has to be copied to the corresponding rom-folder
	at c:\Visual Pinball\VPinMAME\altcolor\ and VPinMAME has to be configured to use the the colorized DMD.
	The VPinMAME-configuration of each rom is stored in registry key dmd_colorize.

	Here comes SetReg_altcolor into play.

	SetReg_altcolor loops through all rom-registry-entries and checks,
	if the corresponding pin2dmd.pal is available at the altcolor-folder.

	- if the altcolor_file_exist, but key dmd_colorize is unset,
	  then then key will be set, which is equal to set CheckBox 'Colorize DMD (4 colors)' at VPinMAME.
	- if the altcolor_file_does not exist, but key dmd_colorize is set,
	  then then key will be unset, which is equal to unset CheckBox 'Colorize DMD (4 colors)' at VPinMAME.
	  
	Before any change, a backup of registry part HKEY_CURRENT_USER\Software\Freeware\Visual PinMame can be done.
	All changes to the registry can be logged at file SetReg_altcolor.log

	SetReg_altcolor can be used interactive or in silent mode only by using parameters.
	
	Possible parameters are :
	- Path to altcolor folder e.g. ''C:\Visual Pinball\VPinMAME\altcolor''
	- writelogfile=true|false (optional, create a logfile of processed registry entries)
	- opennotepad=true|false (optional: open logfile with notepad after processing)
	- createregbackup=true|false (optional: create a backup of registry part HKEY_CURRENT_USER\Software\Freeware\Visual PinMame)
	- showconclusion=true|false Show conclusion-window after processing
	- writecsv=true|false (optional, create a csv-file of all registry entries)
	- runsilent=true|false (optional, run without user-interaction. Uses values from file SetReg_altcolor.ini
	
	Default values are: writelogfile=true opennotepad=false writecsv=true createregbackup=true showconclusion=true
	
	To start SetReg_altcolor in silent mode use e.g.
	SetReg_altcolor.exe runsilent
	or
	SetReg_altcolor.exe runsilent showconclusion=false createregbackup=true
	or any other parameter-combinations
)
	
	Gui, 1: +LastFound
	WinGetPos, gui1x, gui1y, gui1w, gui1h
	g2w := 750
	g2h := 550
	g2x := gui1x + ((gui1w-g2w)/2)
	g2y := gui1y + ((gui1h-g2h)/2)
	
	Gui, 5: -Caption +Border +Owner1
	;Gui, 1: +Disabled   
	Gui, 5: Add, Text, , %Help%
	Gui, 5: Add, Button, xp+380 yp+5 w80 g5ButtonOk, Ok
	;Gui, 5: Show, x%g2x% y%g2y% w%g2w% h%g2h%
	x := A_ScreenWidth/2  - g2w/2
	y := A_ScreenHeight/2 - g2h/2
	Gui, 5: Show, x%x% y%y% w%g2w% h%g2h%
}
; automatic named by ahk
5ButtonOk:
Gui, 1: -Disabled
Gui, 5: Destroy
return