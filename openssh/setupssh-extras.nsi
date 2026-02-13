Section
	;bail immediately if we are client only
	StrCmp $SSHCLIENTONLY "1" ClientOnly

	SetOutPath $INSTDIR\etc
	File etc\fstab

	SetOutPath $INSTDIR\etc\pki\tls\certs
	File ca-bundle.crt

	;Set the output to the bin directory
	SetOutPath $INSTDIR\bin

	;Extract the files to the above directory
	StrCmp $X86FORCE 1 force3
	${If} ${RunningX64}
		File bin64\cyg*.dll
		File bin64\curl.exe
		File /oname=tar.exe bin64\bsdtar.exe
	${Else}
force3:
		File bin32\cyg*.dll
		File bin32\curl.exe
		File /oname=tar.exe bin32\bsdtar.exe
	${EndIf}
	
ClientOnly:
SectionEnd
