
;= DEFINES
;= ################
!define APP		`HostsMan`
!define APPNAME	`${APP}Portable`
!define APPDIR	`$EXEDIR\App\${APP}`
!define DATA	`$EXEDIR\Data`
!define SET		`${DATA}\settings`
!define DEFDATA	`$EXEDIR\App\DefaultData`
!define DEFSET	`${DEFDATA}\settings`
!define SETINI	`${SET}\${APPNAME}Settings.ini`
!define INI		`${SET}\hm.ini`
!define DEFINI	`${DEFDATA}\settings\hm.ini`
!define CFG		`${DATA}\${APP}\prefs.cfg`
!define DEFCFG	`${DEFDATA}\${APP}\prefs.cfg`
!define BACKUP	`${DATA}\Backups`
!define HOSTS	`$SYSDIR\drivers\etc\HOSTS`
!define BAK		`${BACKUP}\HOSTS.BackupBy${APPNAME}`
!define GETPRC	`kernel32::GetCurrentProcess()i.s`
!define WOW		`kernel32::IsWow64Process(is,*i.r0)`
!define HALTFSR `kernel32::Wow64EnableWow64FsRedirection(i0)`

;= FUNCTIONS
;= ################
Function IsWOW64
	!define IsWOW64 `!insertmacro _IsWOW64`
	!macro _IsWOW64 _RETURN
		Push ${_RETURN}
		Call IsWOW64
		Pop ${_RETURN}
	!macroend
	Exch $0
	System::Call `${GETPRC}`
	System::Call `${WOW}`
	Exch $0
FunctionEnd

;= CUSTOM 
;= ################
${SegmentFile}
${Segment.OnInit}
	Push $0
	${IsWOW64} $0
	StrCmp $0 0 0 +3
	WriteINIStr `${SETINI}` ${APPNAME}Settings Architecture 32
		Goto END
	System::Call ${HALTFSR}
	WriteINIStr `${SETINI}` ${APPNAME}Settings Architecture 64
	END:
	Pop $0
	${If} ${IsNT}
		${If} ${IsWinXP}
			${IfNot} ${AtLeastServicePack} 2
				MessageBox MB_ICONSTOP|MB_TOPMOST `${PORTABLEAPPNAME} requires Service Pack 2 or newer`
				Call Unload
				Quit
			${EndIf}
		${ElseIfNot} ${AtLeastWinXP}
			MessageBox MB_ICONSTOP|MB_TOPMOST `${PORTABLEAPPNAME} requires Windows XP or newer`
			Call Unload
			Quit
		${EndIf}
	${Else}
		MessageBox MB_ICONSTOP|MB_TOPMOST `${PORTABLEAPPNAME} requires Windows XP or newer`
		Call Unload
		Quit
	${EndIf}
	IfFileExists `${INI}` +2
	CopyFiles /SILENT `${DEFINI}` `${INI}`
	IfFileExists `${CFG}` +3
	CreateDirectory `${DATA}\${APP}`
	CopyFiles /SILENT `${DEFCFG}` `${CFG}`
	IfFileExists `${BACKUP}` +2
	CreateDirectory `${BACKUP}`
!macroend
${SegmentPrePrimary}
	IfFileExists `${BAK}` 0 +3
	Delete `${HOSTS}`
	Rename `${BAK}` `${HOSTS}`
!macroend
${SegmentPostPrimary}
	Delete `${BAK}`
	CopyFiles /SILENT `${HOSTS}` `${BAK}`
!macroend
${SegmentUnload}
	Delete `$SYSDIR\drivers\etc\*.bak`
!macroend
