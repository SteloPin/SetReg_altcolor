# SetReg_altcolor
Program to set registery values for key dmd_colorize if altcolor-file exists or is missing.

The program is primily used to maintain registry key dmd_colorize at HKEY_CURRENT_USER\Software\Freeware\Visual PinMame.
	
To setup VPinMAME with colorized DMDs, file pin2dmd.pal has to be copied to the corresponding rom-folder at  
C:\Visual Pinball\VPinMAME\altcolor\ and VPinMAME has to be configured to use the the colorized DMD.  
The VPinMAME-configuration of each rom is stored in registry-key dmd_colorize.

Here comes SetReg_altcolor into play.

SetReg_altcolor loops through all rom-registry-entries and checks, if the corresponding pin2dmd.pal-file is available at the altcolor-folder.

- if the altcolor-file exist, but key dmd_colorize is unset, then the key will be set, which is equal to set CheckBox 'Colorize DMD (4 colors)' at VPinMAME.

- if the altcolor-file does not exist, but key dmd_colorize is set, then the key will be unset, which is equal to unset CheckBox 'Colorize DMD (4 colors)' at VPinMAME.
	  
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
