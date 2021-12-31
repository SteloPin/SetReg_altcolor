# SetReg_altcolor
Program to set registery values for key dmd_colorize if altcolor-file exists or is missing.

SetReg_altcolor is primily used to maintain registry key dmd_colorize at HKEY_CURRENT_USER\Software\Freeware\Visual PinMame\

To setup VPinMAME with colorized DMDs, file pin2dmd.pal has to be copied to the corresponding rom-folder at  
C:\Visual Pinball\VPinMAME\altcolor\ and VPinMAME has to be configured to use the the colorized DMD.  
The VPinMAME-configuration of each rom is stored in registry-key dmd_colorize.

Here comes SetReg_altcolor into play. [How it works](https://github.com/SteloPin/SetReg_altcolor/wiki/How-it-works)

<img src="https://user-images.githubusercontent.com/74100604/147820171-9a0b300e-7e24-4372-8312-897de5f51dac.png" width=50% height=50%>

SetReg_altcolor loops through all rom-registry-entries and checks, if the corresponding pin2dmd.pal-file is available at the altcolor-folder.

- if the altcolor-file exist, but key dmd_colorize is unset, then the key will be set, which is equal to set CheckBox 'Colorize DMD (4 colors)' at VPinMAME.

- if the altcolor-file does not exist, but key dmd_colorize is set, then the key will be unset, which is equal to unset CheckBox 'Colorize DMD (4 colors)' at VPinMAME.
	  
Before any change is made, a backup of registry part HKEY_CURRENT_USER\Software\Freeware\Visual PinMame can be done.   
All changes to the registry can be logged at file SetReg_altcolor.log

SetReg_altcolor can be used interactive or in silent mode by using parameters.
	
Possible parameters are :
- Path to altcolor folder (optional if other than "C:\Visual Pinball\VPinMAME\altcolor")
- writelogfile=true|false (optional, create a logfile of processed registry entries)
- opennotepad=true|false (optional: open logfile with notepad after processing)
- createregbackup=true|false (optional: create a backup of registry part HKEY_CURRENT_USER\Software\Freeware\Visual PinMame)
- showconclusion=true|false Show conclusion-window after processing
- writecsv=true|false (optional, create a csv-file of all registry entries)
- runsilent=true|false (optional, run without user-interaction. Uses values from file SetReg_altcolor.ini)
	
To start SetReg_altcolor in silent mode use e.g.   
SetReg_altcolor.exe runsilent   
or   
SetReg_altcolor.exe runsilent showconclusion=false createregbackup=true   
or any other parameter-combinations

 [How it works](https://github.com/SteloPin/SetReg_altcolor/wiki/How-it-works)
