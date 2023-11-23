; CPack install script designed for a nmake build

;--------------------------------
; You must define these values

  !define VERSION "0.1.1"
  !define PATCH  "1"
  !define INST_DIR "C:/Users/emiba/Desktop/SnakeGameSFML/build/_CPack_Packages/win32/NSIS/SNAKE_GAME-0.1.1-win32"

;--------------------------------
;Variables

  Var MUI_TEMP
  Var STARTMENU_FOLDER
  Var SV_ALLUSERS
  Var START_MENU
  Var DO_NOT_ADD_TO_PATH
  Var ADD_TO_PATH_ALL_USERS
  Var ADD_TO_PATH_CURRENT_USER
  Var INSTALL_DESKTOP
  Var IS_DEFAULT_INSTALLDIR
;--------------------------------
;Include Modern UI

  !include "MUI.nsh"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\SNAKE_GAME 0.1.1"

;--------------------------------
;General

  ;Name and file
  Name "SNAKE_GAME 0.1.1"
  OutFile "C:/Users/emiba/Desktop/SnakeGameSFML/build/_CPack_Packages/win32/NSIS/SNAKE_GAME-0.1.1-win32.exe"

  ;Set compression
  SetCompressor lzma

  ;Require administrator access
  RequestExecutionLevel admin





  !include Sections.nsh

;--- Component support macros: ---
; The code for the add/remove functionality is from:
;   https://nsis.sourceforge.io/Add/Remove_Functionality
; It has been modified slightly and extended to provide
; inter-component dependencies.
Var AR_SecFlags
Var AR_RegFlags
Var Unspecified_selected
Var Unspecified_was_installed
Var devel_selected
Var devel_was_installed


; Loads the "selected" flag for the section named SecName into the
; variable VarName.
!macro LoadSectionSelectedIntoVar SecName VarName
 SectionGetFlags ${${SecName}} $${VarName}
 IntOp $${VarName} $${VarName} & ${SF_SELECTED}  ;Turn off all other bits
!macroend

; Loads the value of a variable... can we get around this?
!macro LoadVar VarName
  IntOp $R0 0 + $${VarName}
!macroend

; Sets the value of a variable
!macro StoreVar VarName IntValue
  IntOp $${VarName} 0 + ${IntValue}
!macroend

!macro InitSection SecName
  ;  This macro reads component installed flag from the registry and
  ;changes checked state of the section on the components page.
  ;Input: section index constant name specified in Section command.

  ClearErrors
  ;Reading component status from registry
  ReadRegDWORD $AR_RegFlags HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1\Components\${SecName}" "Installed"
  IfErrors "default_${SecName}"
    ;Status will stay default if registry value not found
    ;(component was never installed)
  IntOp $AR_RegFlags $AR_RegFlags & ${SF_SELECTED} ;Turn off all other bits
  SectionGetFlags ${${SecName}} $AR_SecFlags  ;Reading default section flags
  IntOp $AR_SecFlags $AR_SecFlags & 0xFFFE  ;Turn lowest (enabled) bit off
  IntOp $AR_SecFlags $AR_RegFlags | $AR_SecFlags      ;Change lowest bit

  ; Note whether this component was installed before
  !insertmacro StoreVar ${SecName}_was_installed $AR_RegFlags
  IntOp $R0 $AR_RegFlags & $AR_RegFlags

  ;Writing modified flags
  SectionSetFlags ${${SecName}} $AR_SecFlags

 "default_${SecName}:"
 !insertmacro LoadSectionSelectedIntoVar ${SecName} ${SecName}_selected
!macroend

!macro FinishSection SecName
  ;  This macro reads section flag set by user and removes the section
  ;if it is not selected.
  ;Then it writes component installed flag to registry
  ;Input: section index constant name specified in Section command.

  SectionGetFlags ${${SecName}} $AR_SecFlags  ;Reading section flags
  ;Checking lowest bit:
  IntOp $AR_SecFlags $AR_SecFlags & ${SF_SELECTED}
  IntCmp $AR_SecFlags 1 "leave_${SecName}"
    ;Section is not selected:
    ;Calling Section uninstall macro and writing zero installed flag
    !insertmacro "Remove_${${SecName}}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1\Components\${SecName}" \
  "Installed" 0
    Goto "exit_${SecName}"

 "leave_${SecName}:"
    ;Section is selected:
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1\Components\${SecName}" \
  "Installed" 1

 "exit_${SecName}:"
!macroend

!macro RemoveSection_CPack SecName
  ;  This macro is used to call section's Remove_... macro
  ;from the uninstaller.
  ;Input: section index constant name specified in Section command.

  !insertmacro "Remove_${${SecName}}"
!macroend

; Determine whether the selection of SecName changed
!macro MaybeSelectionChanged SecName
  !insertmacro LoadVar ${SecName}_selected
  SectionGetFlags ${${SecName}} $R1
  IntOp $R1 $R1 & ${SF_SELECTED} ;Turn off all other bits

  ; See if the status has changed:
  IntCmp $R0 $R1 "${SecName}_unchanged"
  !insertmacro LoadSectionSelectedIntoVar ${SecName} ${SecName}_selected

  IntCmp $R1 ${SF_SELECTED} "${SecName}_was_selected"
  !insertmacro "Deselect_required_by_${SecName}"
  goto "${SecName}_unchanged"

  "${SecName}_was_selected:"
  !insertmacro "Select_${SecName}_depends"

  "${SecName}_unchanged:"
!macroend
;--- End of Add/Remove macros ---

;--------------------------------
;Interface Settings

  !define MUI_HEADERIMAGE
  !define MUI_ABORTWARNING

;----------------------------------------
; based upon a script of "Written by KiCHiK 2003-01-18 05:57:02"
;----------------------------------------
!verbose 3
!include "WinMessages.NSH"
!verbose 4
;====================================================
; get_NT_environment
;     Returns: the selected environment
;     Output : head of the stack
;====================================================
!macro select_NT_profile UN
Function ${UN}select_NT_profile
   StrCmp $ADD_TO_PATH_ALL_USERS "1" 0 environment_single
      DetailPrint "Selected environment for all users"
      Push "all"
      Return
   environment_single:
      DetailPrint "Selected environment for current user only."
      Push "current"
      Return
FunctionEnd
!macroend
!insertmacro select_NT_profile ""
!insertmacro select_NT_profile "un."
;----------------------------------------------------
!define NT_current_env 'HKCU "Environment"'
!define NT_all_env     'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'

!ifndef WriteEnvStr_RegKey
  !ifdef ALL_USERS
    !define WriteEnvStr_RegKey \
       'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
  !else
    !define WriteEnvStr_RegKey 'HKCU "Environment"'
  !endif
!endif

; AddToPath - Adds the given dir to the search path.
;        Input - head of the stack
;        Note - Win9x systems requires reboot

Function AddToPath
  Exch $0
  Push $1
  Push $2
  Push $3

  # don't add if the path doesn't exist
  IfFileExists "$0\*.*" "" AddToPath_done

  ReadEnvStr $1 PATH
  ; if the path is too long for a NSIS variable NSIS will return a 0
  ; length string.  If we find that, then warn and skip any path
  ; modification as it will trash the existing path.
  StrLen $2 $1
  IntCmp $2 0 CheckPathLength_ShowPathWarning CheckPathLength_Done CheckPathLength_Done
    CheckPathLength_ShowPathWarning:
    Messagebox MB_OK|MB_ICONEXCLAMATION "Warning! PATH too long installer unable to modify PATH!"
    Goto AddToPath_done
  CheckPathLength_Done:
  Push "$1;"
  Push "$0;"
  Call StrStr
  Pop $2
  StrCmp $2 "" "" AddToPath_done
  Push "$1;"
  Push "$0\;"
  Call StrStr
  Pop $2
  StrCmp $2 "" "" AddToPath_done
  GetFullPathName /SHORT $3 $0
  Push "$1;"
  Push "$3;"
  Call StrStr
  Pop $2
  StrCmp $2 "" "" AddToPath_done
  Push "$1;"
  Push "$3\;"
  Call StrStr
  Pop $2
  StrCmp $2 "" "" AddToPath_done

  Call IsNT
  Pop $1
  StrCmp $1 1 AddToPath_NT
    ; Not on NT
    StrCpy $1 $WINDIR 2
    FileOpen $1 "$1\autoexec.bat" a
    FileSeek $1 -1 END
    FileReadByte $1 $2
    IntCmp $2 26 0 +2 +2 # DOS EOF
      FileSeek $1 -1 END # write over EOF
    FileWrite $1 "$\r$\nSET PATH=%PATH%;$3$\r$\n"
    FileClose $1
    SetRebootFlag true
    Goto AddToPath_done

  AddToPath_NT:
    StrCmp $ADD_TO_PATH_ALL_USERS "1" ReadAllKey
      ReadRegStr $1 ${NT_current_env} "PATH"
      Goto DoTrim
    ReadAllKey:
      ReadRegStr $1 ${NT_all_env} "PATH"
    DoTrim:
    StrCmp $1 "" AddToPath_NTdoIt
      Push $1
      Call Trim
      Pop $1
      StrCpy $0 "$1;$0"
    AddToPath_NTdoIt:
      StrCmp $ADD_TO_PATH_ALL_USERS "1" WriteAllKey
        WriteRegExpandStr ${NT_current_env} "PATH" $0
        Goto DoSend
      WriteAllKey:
        WriteRegExpandStr ${NT_all_env} "PATH" $0
      DoSend:
      SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  AddToPath_done:
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd


; RemoveFromPath - Remove a given dir from the path
;     Input: head of the stack

Function un.RemoveFromPath
  Exch $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6

  IntFmt $6 "%c" 26 # DOS EOF

  Call un.IsNT
  Pop $1
  StrCmp $1 1 unRemoveFromPath_NT
    ; Not on NT
    StrCpy $1 $WINDIR 2
    FileOpen $1 "$1\autoexec.bat" r
    GetTempFileName $4
    FileOpen $2 $4 w
    GetFullPathName /SHORT $0 $0
    StrCpy $0 "SET PATH=%PATH%;$0"
    Goto unRemoveFromPath_dosLoop

    unRemoveFromPath_dosLoop:
      FileRead $1 $3
      StrCpy $5 $3 1 -1 # read last char
      StrCmp $5 $6 0 +2 # if DOS EOF
        StrCpy $3 $3 -1 # remove DOS EOF so we can compare
      StrCmp $3 "$0$\r$\n" unRemoveFromPath_dosLoopRemoveLine
      StrCmp $3 "$0$\n" unRemoveFromPath_dosLoopRemoveLine
      StrCmp $3 "$0" unRemoveFromPath_dosLoopRemoveLine
      StrCmp $3 "" unRemoveFromPath_dosLoopEnd
      FileWrite $2 $3
      Goto unRemoveFromPath_dosLoop
      unRemoveFromPath_dosLoopRemoveLine:
        SetRebootFlag true
        Goto unRemoveFromPath_dosLoop

    unRemoveFromPath_dosLoopEnd:
      FileClose $2
      FileClose $1
      StrCpy $1 $WINDIR 2
      Delete "$1\autoexec.bat"
      CopyFiles /SILENT $4 "$1\autoexec.bat"
      Delete $4
      Goto unRemoveFromPath_done

  unRemoveFromPath_NT:
    StrCmp $ADD_TO_PATH_ALL_USERS "1" unReadAllKey
      ReadRegStr $1 ${NT_current_env} "PATH"
      Goto unDoTrim
    unReadAllKey:
      ReadRegStr $1 ${NT_all_env} "PATH"
    unDoTrim:
    StrCpy $5 $1 1 -1 # copy last char
    StrCmp $5 ";" +2 # if last char != ;
      StrCpy $1 "$1;" # append ;
    Push $1
    Push "$0;"
    Call un.StrStr ; Find `$0;` in $1
    Pop $2 ; pos of our dir
    StrCmp $2 "" unRemoveFromPath_done
      ; else, it is in path
      # $0 - path to add
      # $1 - path var
      StrLen $3 "$0;"
      StrLen $4 $2
      StrCpy $5 $1 -$4 # $5 is now the part before the path to remove
      StrCpy $6 $2 "" $3 # $6 is now the part after the path to remove
      StrCpy $3 $5$6

      StrCpy $5 $3 1 -1 # copy last char
      StrCmp $5 ";" 0 +2 # if last char == ;
        StrCpy $3 $3 -1 # remove last char

      StrCmp $ADD_TO_PATH_ALL_USERS "1" unWriteAllKey
        WriteRegExpandStr ${NT_current_env} "PATH" $3
        Goto unDoSend
      unWriteAllKey:
        WriteRegExpandStr ${NT_all_env} "PATH" $3
      unDoSend:
      SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  unRemoveFromPath_done:
    Pop $6
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Uninstall stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

###########################################
#            Utility Functions            #
###########################################

;====================================================
; IsNT - Returns 1 if the current system is NT, 0
;        otherwise.
;     Output: head of the stack
;====================================================
; IsNT
; no input
; output, top of the stack = 1 if NT or 0 if not
;
; Usage:
;   Call IsNT
;   Pop $R0
;  ($R0 at this point is 1 or 0)

!macro IsNT un
Function ${un}IsNT
  Push $0
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  StrCmp $0 "" 0 IsNT_yes
  ; we are not NT.
  Pop $0
  Push 0
  Return

  IsNT_yes:
    ; NT!!!
    Pop $0
    Push 1
FunctionEnd
!macroend
!insertmacro IsNT ""
!insertmacro IsNT "un."

; StrStr
; input, top of stack = string to search for
;        top of stack-1 = string to search in
; output, top of stack (replaces with the portion of the string remaining)
; modifies no other variables.
;
; Usage:
;   Push "this is a long ass string"
;   Push "ass"
;   Call StrStr
;   Pop $R0
;  ($R0 at this point is "ass string")

!macro StrStr un
Function ${un}StrStr
Exch $R1 ; st=haystack,old$R1, $R1=needle
  Exch    ; st=old$R1,haystack
  Exch $R2 ; st=old$R1,old$R2, $R2=haystack
  Push $R3
  Push $R4
  Push $R5
  StrLen $R3 $R1
  StrCpy $R4 0
  ; $R1=needle
  ; $R2=haystack
  ; $R3=len(needle)
  ; $R4=cnt
  ; $R5=tmp
  loop:
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 done
    StrCmp $R5 "" done
    IntOp $R4 $R4 + 1
    Goto loop
done:
  StrCpy $R1 $R2 "" $R4
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1
FunctionEnd
!macroend
!insertmacro StrStr ""
!insertmacro StrStr "un."

Function Trim ; Added by Pelaca
	Exch $R1
	Push $R2
Loop:
	StrCpy $R2 "$R1" 1 -1
	StrCmp "$R2" " " RTrim
	StrCmp "$R2" "$\n" RTrim
	StrCmp "$R2" "$\r" RTrim
	StrCmp "$R2" ";" RTrim
	GoTo Done
RTrim:
	StrCpy $R1 "$R1" -1
	Goto Loop
Done:
	Pop $R2
	Exch $R1
FunctionEnd

Function ConditionalAddToRegistry
  Pop $0
  Pop $1
  StrCmp "$0" "" ConditionalAddToRegistry_EmptyString
    WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1" \
    "$1" "$0"
    ;MessageBox MB_OK "Set Registry: '$1' to '$0'"
    DetailPrint "Set install registry entry: '$1' to '$0'"
  ConditionalAddToRegistry_EmptyString:
FunctionEnd

;--------------------------------

!ifdef CPACK_USES_DOWNLOAD
Function DownloadFile
    IfFileExists $INSTDIR\* +2
    CreateDirectory $INSTDIR
    Pop $0

    ; Skip if already downloaded
    IfFileExists $INSTDIR\$0 0 +2
    Return

    StrCpy $1 ""

  try_again:
    NSISdl::download "$1/$0" "$INSTDIR\$0"

    Pop $1
    StrCmp $1 "success" success
    StrCmp $1 "Cancelled" cancel
    MessageBox MB_OK "Download failed: $1"
  cancel:
    Return
  success:
FunctionEnd
!endif

;--------------------------------
; Define some macro setting for the gui






;--------------------------------
;Pages
  
  
  !insertmacro MUI_PAGE_WELCOME

  !insertmacro MUI_PAGE_LICENSE "C:/Program Files/CMake/share/cmake-3.28/Templates/CPack.GenericLicense.txt"

  Page custom InstallOptionsPage
  !insertmacro MUI_PAGE_DIRECTORY

  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "SHCTX"
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Humanity\SNAKE_GAME 0.1.1"
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER

  !insertmacro MUI_PAGE_COMPONENTS

  !insertmacro MUI_PAGE_INSTFILES
  
  
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English" ;first language is the default language
  !insertmacro MUI_LANGUAGE "Afrikaans"
  !insertmacro MUI_LANGUAGE "Albanian"
  !insertmacro MUI_LANGUAGE "Arabic"
  !insertmacro MUI_LANGUAGE "Asturian"
  !insertmacro MUI_LANGUAGE "Basque"
  !insertmacro MUI_LANGUAGE "Belarusian"
  !insertmacro MUI_LANGUAGE "Bosnian"
  !insertmacro MUI_LANGUAGE "Breton"
  !insertmacro MUI_LANGUAGE "Bulgarian"
  !insertmacro MUI_LANGUAGE "Catalan"
  !insertmacro MUI_LANGUAGE "Corsican"
  !insertmacro MUI_LANGUAGE "Croatian"
  !insertmacro MUI_LANGUAGE "Czech"
  !insertmacro MUI_LANGUAGE "Danish"
  !insertmacro MUI_LANGUAGE "Dutch"
  !insertmacro MUI_LANGUAGE "Esperanto"
  !insertmacro MUI_LANGUAGE "Estonian"
  !insertmacro MUI_LANGUAGE "Farsi"
  !insertmacro MUI_LANGUAGE "Finnish"
  !insertmacro MUI_LANGUAGE "French"
  !insertmacro MUI_LANGUAGE "Galician"
  !insertmacro MUI_LANGUAGE "German"
  !insertmacro MUI_LANGUAGE "Greek"
  !insertmacro MUI_LANGUAGE "Hebrew"
  !insertmacro MUI_LANGUAGE "Hungarian"
  !insertmacro MUI_LANGUAGE "Icelandic"
  !insertmacro MUI_LANGUAGE "Indonesian"
  !insertmacro MUI_LANGUAGE "Irish"
  !insertmacro MUI_LANGUAGE "Italian"
  !insertmacro MUI_LANGUAGE "Japanese"
  !insertmacro MUI_LANGUAGE "Korean"
  !insertmacro MUI_LANGUAGE "Kurdish"
  !insertmacro MUI_LANGUAGE "Latvian"
  !insertmacro MUI_LANGUAGE "Lithuanian"
  !insertmacro MUI_LANGUAGE "Luxembourgish"
  !insertmacro MUI_LANGUAGE "Macedonian"
  !insertmacro MUI_LANGUAGE "Malay"
  !insertmacro MUI_LANGUAGE "Mongolian"
  !insertmacro MUI_LANGUAGE "Norwegian"
  !insertmacro MUI_LANGUAGE "NorwegianNynorsk"
  !insertmacro MUI_LANGUAGE "Pashto"
  !insertmacro MUI_LANGUAGE "Polish"
  !insertmacro MUI_LANGUAGE "Portuguese"
  !insertmacro MUI_LANGUAGE "PortugueseBR"
  !insertmacro MUI_LANGUAGE "Romanian"
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "ScotsGaelic"
  !insertmacro MUI_LANGUAGE "Serbian"
  !insertmacro MUI_LANGUAGE "SerbianLatin"
  !insertmacro MUI_LANGUAGE "SimpChinese"
  !insertmacro MUI_LANGUAGE "Slovak"
  !insertmacro MUI_LANGUAGE "Slovenian"
  !insertmacro MUI_LANGUAGE "Spanish"
  !insertmacro MUI_LANGUAGE "SpanishInternational"
  !insertmacro MUI_LANGUAGE "Swedish"
  !insertmacro MUI_LANGUAGE "Tatar"
  !insertmacro MUI_LANGUAGE "Thai"
  !insertmacro MUI_LANGUAGE "TradChinese"
  !insertmacro MUI_LANGUAGE "Turkish"
  !insertmacro MUI_LANGUAGE "Ukrainian"
  !insertmacro MUI_LANGUAGE "Uzbek"
  !insertmacro MUI_LANGUAGE "Vietnamese"
  !insertmacro MUI_LANGUAGE "Welsh"

;--------------------------------
;Reserve Files

  ;These files should be inserted before other files in the data block
  ;Keep these lines before any File command
  ;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)

  ReserveFile "NSIS.InstallOptions.ini"
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

  ; for UserInfo::GetName and UserInfo::GetAccountType
  ReserveFile /plugin 'UserInfo.dll'

;--------------------------------
; Installation types


;--------------------------------
; Component sections
Section "-Unspecified" Unspecified
  SectionIn RO
  SetOutPath "$INSTDIR"
  File /r "${INST_DIR}\Unspecified\*.*"
SectionEnd
Section "devel" devel
  SetOutPath "$INSTDIR"
  File /r "${INST_DIR}\devel\*.*"
SectionEnd
!macro Remove_${Unspecified}
  IntCmp $Unspecified_was_installed 0 noremove_Unspecified
  Delete "$INSTDIR\assets"
  Delete "$INSTDIR\assets\fonts"
  Delete "$INSTDIR\assets\fonts\Cute Egg.ttf"
  Delete "$INSTDIR\assets\fonts\CuteFont-Regular.otf"
  Delete "$INSTDIR\assets\levels"
  Delete "$INSTDIR\assets\levels\levels.txt"
  Delete "$INSTDIR\assets\levels\lvl1.txt"
  Delete "$INSTDIR\assets\levels\lvl2.txt"
  Delete "$INSTDIR\assets\textures"
  Delete "$INSTDIR\assets\textures\grass.png"
  Delete "$INSTDIR\assets\textures\honguito.png"
  Delete "$INSTDIR\assets\textures\manzanita.png"
  Delete "$INSTDIR\assets\textures\snekbody1.png"
  Delete "$INSTDIR\assets\textures\snekbody2.png"
  Delete "$INSTDIR\assets\textures\snekbody3.png"
  Delete "$INSTDIR\assets\textures\snekhead.png"
  Delete "$INSTDIR\bin"
  Delete "$INSTDIR\bin\SNAKE_GAME.exe"
  Delete "$INSTDIR\bin\openal32.dll"
  Delete "$INSTDIR\lib"
  Delete "$INSTDIR\lib\cmake"
  Delete "$INSTDIR\lib\cmake\SFML"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLStaticTargets-noconfig.cmake"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLStaticTargets.cmake"
  Delete "$INSTDIR\lib\libFLAC.a"
  Delete "$INSTDIR\lib\libfreetype.a"
  Delete "$INSTDIR\lib\libogg.a"
  Delete "$INSTDIR\lib\libopenal32.a"
  Delete "$INSTDIR\lib\libvorbis.a"
  Delete "$INSTDIR\lib\libvorbisenc.a"
  Delete "$INSTDIR\lib\libvorbisfile.a"
  Delete "$INSTDIR\share"
  Delete "$INSTDIR\share\doc"
  Delete "$INSTDIR\share\doc\SFML"
  Delete "$INSTDIR\share\doc\SFML\license.md"
  Delete "$INSTDIR\share\doc\SFML\readme.md"
  RMDir "$INSTDIR\assets\fonts"
  RMDir "$INSTDIR\assets\levels"
  RMDir "$INSTDIR\assets\textures"
  RMDir "$INSTDIR\assets"
  RMDir "$INSTDIR\bin"
  RMDir "$INSTDIR\lib\cmake\SFML"
  RMDir "$INSTDIR\lib\cmake"
  RMDir "$INSTDIR\lib"
  RMDir "$INSTDIR\share\doc\SFML"
  RMDir "$INSTDIR\share\doc"
  RMDir "$INSTDIR\share"
  noremove_Unspecified:
!macroend
!macro Select_Unspecified_depends
!macroend
!macro Deselect_required_by_Unspecified
!macroend
!macro Remove_${devel}
  IntCmp $devel_was_installed 0 noremove_devel
  Delete "$INSTDIR\include"
  Delete "$INSTDIR\include\SFML"
  Delete "$INSTDIR\include\SFML\Audio"
  Delete "$INSTDIR\include\SFML\Audio.hpp"
  Delete "$INSTDIR\include\SFML\Audio\AlResource.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Export.hpp"
  Delete "$INSTDIR\include\SFML\Audio\InputSoundFile.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Listener.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Music.hpp"
  Delete "$INSTDIR\include\SFML\Audio\OutputSoundFile.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Sound.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundBuffer.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundBufferRecorder.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileFactory.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileFactory.inl"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileReader.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileWriter.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundRecorder.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundSource.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundStream.hpp"
  Delete "$INSTDIR\include\SFML\Config.hpp"
  Delete "$INSTDIR\include\SFML\GpuPreference.hpp"
  Delete "$INSTDIR\include\SFML\Graphics"
  Delete "$INSTDIR\include\SFML\Graphics.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\BlendMode.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\CircleShape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Color.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\ConvexShape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Drawable.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Export.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Font.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Glsl.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Glsl.inl"
  Delete "$INSTDIR\include\SFML\Graphics\Glyph.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Image.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\PrimitiveType.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Rect.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Rect.inl"
  Delete "$INSTDIR\include\SFML\Graphics\RectangleShape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderStates.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderTarget.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderTexture.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderWindow.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Shader.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Shape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Sprite.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Text.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Texture.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Transform.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Transformable.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Vertex.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\VertexArray.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\VertexBuffer.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\View.hpp"
  Delete "$INSTDIR\include\SFML\Main.hpp"
  Delete "$INSTDIR\include\SFML\Network"
  Delete "$INSTDIR\include\SFML\Network.hpp"
  Delete "$INSTDIR\include\SFML\Network\Export.hpp"
  Delete "$INSTDIR\include\SFML\Network\Ftp.hpp"
  Delete "$INSTDIR\include\SFML\Network\Http.hpp"
  Delete "$INSTDIR\include\SFML\Network\IpAddress.hpp"
  Delete "$INSTDIR\include\SFML\Network\Packet.hpp"
  Delete "$INSTDIR\include\SFML\Network\Socket.hpp"
  Delete "$INSTDIR\include\SFML\Network\SocketHandle.hpp"
  Delete "$INSTDIR\include\SFML\Network\SocketSelector.hpp"
  Delete "$INSTDIR\include\SFML\Network\TcpListener.hpp"
  Delete "$INSTDIR\include\SFML\Network\TcpSocket.hpp"
  Delete "$INSTDIR\include\SFML\Network\UdpSocket.hpp"
  Delete "$INSTDIR\include\SFML\OpenGL.hpp"
  Delete "$INSTDIR\include\SFML\System"
  Delete "$INSTDIR\include\SFML\System.hpp"
  Delete "$INSTDIR\include\SFML\System\Clock.hpp"
  Delete "$INSTDIR\include\SFML\System\Err.hpp"
  Delete "$INSTDIR\include\SFML\System\Export.hpp"
  Delete "$INSTDIR\include\SFML\System\FileInputStream.hpp"
  Delete "$INSTDIR\include\SFML\System\InputStream.hpp"
  Delete "$INSTDIR\include\SFML\System\Lock.hpp"
  Delete "$INSTDIR\include\SFML\System\MemoryInputStream.hpp"
  Delete "$INSTDIR\include\SFML\System\Mutex.hpp"
  Delete "$INSTDIR\include\SFML\System\NativeActivity.hpp"
  Delete "$INSTDIR\include\SFML\System\NonCopyable.hpp"
  Delete "$INSTDIR\include\SFML\System\Sleep.hpp"
  Delete "$INSTDIR\include\SFML\System\String.hpp"
  Delete "$INSTDIR\include\SFML\System\String.inl"
  Delete "$INSTDIR\include\SFML\System\Thread.hpp"
  Delete "$INSTDIR\include\SFML\System\Thread.inl"
  Delete "$INSTDIR\include\SFML\System\ThreadLocal.hpp"
  Delete "$INSTDIR\include\SFML\System\ThreadLocalPtr.hpp"
  Delete "$INSTDIR\include\SFML\System\ThreadLocalPtr.inl"
  Delete "$INSTDIR\include\SFML\System\Time.hpp"
  Delete "$INSTDIR\include\SFML\System\Utf.hpp"
  Delete "$INSTDIR\include\SFML\System\Utf.inl"
  Delete "$INSTDIR\include\SFML\System\Vector2.hpp"
  Delete "$INSTDIR\include\SFML\System\Vector2.inl"
  Delete "$INSTDIR\include\SFML\System\Vector3.hpp"
  Delete "$INSTDIR\include\SFML\System\Vector3.inl"
  Delete "$INSTDIR\include\SFML\Window"
  Delete "$INSTDIR\include\SFML\Window.hpp"
  Delete "$INSTDIR\include\SFML\Window\Clipboard.hpp"
  Delete "$INSTDIR\include\SFML\Window\Context.hpp"
  Delete "$INSTDIR\include\SFML\Window\ContextSettings.hpp"
  Delete "$INSTDIR\include\SFML\Window\Cursor.hpp"
  Delete "$INSTDIR\include\SFML\Window\Event.hpp"
  Delete "$INSTDIR\include\SFML\Window\Export.hpp"
  Delete "$INSTDIR\include\SFML\Window\GlResource.hpp"
  Delete "$INSTDIR\include\SFML\Window\Joystick.hpp"
  Delete "$INSTDIR\include\SFML\Window\Keyboard.hpp"
  Delete "$INSTDIR\include\SFML\Window\Mouse.hpp"
  Delete "$INSTDIR\include\SFML\Window\Sensor.hpp"
  Delete "$INSTDIR\include\SFML\Window\Touch.hpp"
  Delete "$INSTDIR\include\SFML\Window\VideoMode.hpp"
  Delete "$INSTDIR\include\SFML\Window\Vulkan.hpp"
  Delete "$INSTDIR\include\SFML\Window\Window.hpp"
  Delete "$INSTDIR\include\SFML\Window\WindowBase.hpp"
  Delete "$INSTDIR\include\SFML\Window\WindowHandle.hpp"
  Delete "$INSTDIR\include\SFML\Window\WindowStyle.hpp"
  Delete "$INSTDIR\lib"
  Delete "$INSTDIR\lib\cmake"
  Delete "$INSTDIR\lib\cmake\SFML"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLConfig.cmake"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLConfigDependencies.cmake"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLConfigVersion.cmake"
  Delete "$INSTDIR\lib\libsfml-audio.a"
  Delete "$INSTDIR\lib\libsfml-graphics.a"
  Delete "$INSTDIR\lib\libsfml-main.a"
  Delete "$INSTDIR\lib\libsfml-network.a"
  Delete "$INSTDIR\lib\libsfml-system.a"
  Delete "$INSTDIR\lib\libsfml-window.a"
  RMDir "$INSTDIR\include\SFML\Audio"
  RMDir "$INSTDIR\include\SFML\Graphics"
  RMDir "$INSTDIR\include\SFML\Network"
  RMDir "$INSTDIR\include\SFML\System"
  RMDir "$INSTDIR\include\SFML\Window"
  RMDir "$INSTDIR\include\SFML"
  RMDir "$INSTDIR\include"
  RMDir "$INSTDIR\lib\cmake\SFML"
  RMDir "$INSTDIR\lib\cmake"
  RMDir "$INSTDIR\lib"
  noremove_devel:
!macroend
!macro Select_devel_depends
!macroend
!macro Deselect_required_by_devel
!macroend

!define MUI_COMPONENTSPAGE_NODESC
;--------------------------------
;Installer Sections

Section "-Core installation"
  ;Use the entire tree produced by the INSTALL target.  Keep the
  ;list of directories here in sync with the RMDir commands below.
  SetOutPath "$INSTDIR"
  
  

  ;Store installation folder
  WriteRegStr SHCTX "Software\Humanity\SNAKE_GAME 0.1.1" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  Push "DisplayName"
  Push "SNAKE_GAME 0.1.1"
  Call ConditionalAddToRegistry
  Push "DisplayVersion"
  Push "0.1.1"
  Call ConditionalAddToRegistry
  Push "Publisher"
  Push "Humanity"
  Call ConditionalAddToRegistry
  Push "UninstallString"
  Push "$\"$INSTDIR\Uninstall.exe$\""
  Call ConditionalAddToRegistry
  Push "NoRepair"
  Push "1"
  Call ConditionalAddToRegistry

  !ifdef CPACK_NSIS_ADD_REMOVE
  ;Create add/remove functionality
  Push "ModifyPath"
  Push "$INSTDIR\AddRemove.exe"
  Call ConditionalAddToRegistry
  !else
  Push "NoModify"
  Push "1"
  Call ConditionalAddToRegistry
  !endif

  ; Optional registration
  Push "DisplayIcon"
  Push "$INSTDIR\"
  Call ConditionalAddToRegistry
  Push "HelpLink"
  Push ""
  Call ConditionalAddToRegistry
  Push "URLInfoAbout"
  Push ""
  Call ConditionalAddToRegistry
  Push "Contact"
  Push ""
  Call ConditionalAddToRegistry
  !insertmacro MUI_INSTALLOPTIONS_READ $INSTALL_DESKTOP "NSIS.InstallOptions.ini" "Field 5" "State"
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application

  ;Create shortcuts
  CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"


  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

  ;Read a value from an InstallOptions INI file
  !insertmacro MUI_INSTALLOPTIONS_READ $DO_NOT_ADD_TO_PATH "NSIS.InstallOptions.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADD_TO_PATH_ALL_USERS "NSIS.InstallOptions.ini" "Field 3" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADD_TO_PATH_CURRENT_USER "NSIS.InstallOptions.ini" "Field 4" "State"

  ; Write special uninstall registry entries
  Push "StartMenu"
  Push "$STARTMENU_FOLDER"
  Call ConditionalAddToRegistry
  Push "DoNotAddToPath"
  Push "$DO_NOT_ADD_TO_PATH"
  Call ConditionalAddToRegistry
  Push "AddToPathAllUsers"
  Push "$ADD_TO_PATH_ALL_USERS"
  Call ConditionalAddToRegistry
  Push "AddToPathCurrentUser"
  Push "$ADD_TO_PATH_CURRENT_USER"
  Call ConditionalAddToRegistry
  Push "InstallToDesktop"
  Push "$INSTALL_DESKTOP"
  Call ConditionalAddToRegistry

  !insertmacro MUI_STARTMENU_WRITE_END



SectionEnd

Section "-Add to path"
  Push $INSTDIR\bin
  StrCmp "" "ON" 0 doNotAddToPath
  StrCmp $DO_NOT_ADD_TO_PATH "1" doNotAddToPath 0
    Call AddToPath
  doNotAddToPath:
SectionEnd

;--------------------------------
; Create custom pages
Function InstallOptionsPage
  !insertmacro MUI_HEADER_TEXT "Install Options" "Choose options for installing SNAKE_GAME 0.1.1"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "NSIS.InstallOptions.ini"

FunctionEnd

;--------------------------------
; determine admin versus local install
Function un.onInit

  ClearErrors
  UserInfo::GetName
  IfErrors noLM
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  StrCmp $1 "Admin" 0 +3
    SetShellVarContext all
    ;MessageBox MB_OK 'User "$0" is in the Admin group'
    Goto done
  StrCmp $1 "Power" 0 +3
    SetShellVarContext all
    ;MessageBox MB_OK 'User "$0" is in the Power Users group'
    Goto done

  noLM:
    ;Get installation folder from registry if available

  done:

FunctionEnd

;--- Add/Remove callback functions: ---
!macro SectionList MacroName
  ;This macro used to perform operation on multiple sections.
  ;List all of your components in following manner here.
  !insertmacro "${MacroName}" "Unspecified"
  !insertmacro "${MacroName}" "devel"

!macroend

Section -FinishComponents
  ;Removes unselected components and writes component status to registry
  !insertmacro SectionList "FinishSection"

!ifdef CPACK_NSIS_ADD_REMOVE
  ; Get the name of the installer executable
  System::Call 'kernel32::GetModuleFileNameA(i 0, t .R0, i 1024) i r1'
  StrCpy $R3 $R0

  ; Strip off the last 13 characters, to see if we have AddRemove.exe
  StrLen $R1 $R0
  IntOp $R1 $R0 - 13
  StrCpy $R2 $R0 13 $R1
  StrCmp $R2 "AddRemove.exe" addremove_installed

  ; We're not running AddRemove.exe, so install it
  CopyFiles $R3 $INSTDIR\AddRemove.exe

  addremove_installed:
!endif
SectionEnd
;--- End of Add/Remove callback functions ---

;--------------------------------
; Component dependencies
Function .onSelChange
  !insertmacro SectionList MaybeSelectionChanged
FunctionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  ReadRegStr $START_MENU SHCTX \
   "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1" "StartMenu"
  ;MessageBox MB_OK "Start menu is in: $START_MENU"
  ReadRegStr $DO_NOT_ADD_TO_PATH SHCTX \
    "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1" "DoNotAddToPath"
  ReadRegStr $ADD_TO_PATH_ALL_USERS SHCTX \
    "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1" "AddToPathAllUsers"
  ReadRegStr $ADD_TO_PATH_CURRENT_USER SHCTX \
    "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1" "AddToPathCurrentUser"
  ;MessageBox MB_OK "Add to path: $DO_NOT_ADD_TO_PATH all users: $ADD_TO_PATH_ALL_USERS"
  ReadRegStr $INSTALL_DESKTOP SHCTX \
    "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1" "InstallToDesktop"
  ;MessageBox MB_OK "Install to desktop: $INSTALL_DESKTOP "



  ;Remove files we installed.
  ;Keep the list of directories here in sync with the File commands above.
  Delete "$INSTDIR\devel"
  Delete "$INSTDIR\include"
  Delete "$INSTDIR\include\SFML"
  Delete "$INSTDIR\include\SFML\Audio"
  Delete "$INSTDIR\include\SFML\Audio\AlResource.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Export.hpp"
  Delete "$INSTDIR\include\SFML\Audio\InputSoundFile.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Listener.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Music.hpp"
  Delete "$INSTDIR\include\SFML\Audio\OutputSoundFile.hpp"
  Delete "$INSTDIR\include\SFML\Audio\Sound.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundBuffer.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundBufferRecorder.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileFactory.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileFactory.inl"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileReader.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundFileWriter.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundRecorder.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundSource.hpp"
  Delete "$INSTDIR\include\SFML\Audio\SoundStream.hpp"
  Delete "$INSTDIR\include\SFML\Audio.hpp"
  Delete "$INSTDIR\include\SFML\Config.hpp"
  Delete "$INSTDIR\include\SFML\GpuPreference.hpp"
  Delete "$INSTDIR\include\SFML\Graphics"
  Delete "$INSTDIR\include\SFML\Graphics\BlendMode.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\CircleShape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Color.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\ConvexShape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Drawable.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Export.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Font.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Glsl.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Glsl.inl"
  Delete "$INSTDIR\include\SFML\Graphics\Glyph.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Image.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\PrimitiveType.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Rect.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Rect.inl"
  Delete "$INSTDIR\include\SFML\Graphics\RectangleShape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderStates.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderTarget.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderTexture.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\RenderWindow.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Shader.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Shape.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Sprite.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Text.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Texture.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Transform.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Transformable.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\Vertex.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\VertexArray.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\VertexBuffer.hpp"
  Delete "$INSTDIR\include\SFML\Graphics\View.hpp"
  Delete "$INSTDIR\include\SFML\Graphics.hpp"
  Delete "$INSTDIR\include\SFML\Main.hpp"
  Delete "$INSTDIR\include\SFML\Network"
  Delete "$INSTDIR\include\SFML\Network\Export.hpp"
  Delete "$INSTDIR\include\SFML\Network\Ftp.hpp"
  Delete "$INSTDIR\include\SFML\Network\Http.hpp"
  Delete "$INSTDIR\include\SFML\Network\IpAddress.hpp"
  Delete "$INSTDIR\include\SFML\Network\Packet.hpp"
  Delete "$INSTDIR\include\SFML\Network\Socket.hpp"
  Delete "$INSTDIR\include\SFML\Network\SocketHandle.hpp"
  Delete "$INSTDIR\include\SFML\Network\SocketSelector.hpp"
  Delete "$INSTDIR\include\SFML\Network\TcpListener.hpp"
  Delete "$INSTDIR\include\SFML\Network\TcpSocket.hpp"
  Delete "$INSTDIR\include\SFML\Network\UdpSocket.hpp"
  Delete "$INSTDIR\include\SFML\Network.hpp"
  Delete "$INSTDIR\include\SFML\OpenGL.hpp"
  Delete "$INSTDIR\include\SFML\System"
  Delete "$INSTDIR\include\SFML\System\Clock.hpp"
  Delete "$INSTDIR\include\SFML\System\Err.hpp"
  Delete "$INSTDIR\include\SFML\System\Export.hpp"
  Delete "$INSTDIR\include\SFML\System\FileInputStream.hpp"
  Delete "$INSTDIR\include\SFML\System\InputStream.hpp"
  Delete "$INSTDIR\include\SFML\System\Lock.hpp"
  Delete "$INSTDIR\include\SFML\System\MemoryInputStream.hpp"
  Delete "$INSTDIR\include\SFML\System\Mutex.hpp"
  Delete "$INSTDIR\include\SFML\System\NativeActivity.hpp"
  Delete "$INSTDIR\include\SFML\System\NonCopyable.hpp"
  Delete "$INSTDIR\include\SFML\System\Sleep.hpp"
  Delete "$INSTDIR\include\SFML\System\String.hpp"
  Delete "$INSTDIR\include\SFML\System\String.inl"
  Delete "$INSTDIR\include\SFML\System\Thread.hpp"
  Delete "$INSTDIR\include\SFML\System\Thread.inl"
  Delete "$INSTDIR\include\SFML\System\ThreadLocal.hpp"
  Delete "$INSTDIR\include\SFML\System\ThreadLocalPtr.hpp"
  Delete "$INSTDIR\include\SFML\System\ThreadLocalPtr.inl"
  Delete "$INSTDIR\include\SFML\System\Time.hpp"
  Delete "$INSTDIR\include\SFML\System\Utf.hpp"
  Delete "$INSTDIR\include\SFML\System\Utf.inl"
  Delete "$INSTDIR\include\SFML\System\Vector2.hpp"
  Delete "$INSTDIR\include\SFML\System\Vector2.inl"
  Delete "$INSTDIR\include\SFML\System\Vector3.hpp"
  Delete "$INSTDIR\include\SFML\System\Vector3.inl"
  Delete "$INSTDIR\include\SFML\System.hpp"
  Delete "$INSTDIR\include\SFML\Window"
  Delete "$INSTDIR\include\SFML\Window\Clipboard.hpp"
  Delete "$INSTDIR\include\SFML\Window\Context.hpp"
  Delete "$INSTDIR\include\SFML\Window\ContextSettings.hpp"
  Delete "$INSTDIR\include\SFML\Window\Cursor.hpp"
  Delete "$INSTDIR\include\SFML\Window\Event.hpp"
  Delete "$INSTDIR\include\SFML\Window\Export.hpp"
  Delete "$INSTDIR\include\SFML\Window\GlResource.hpp"
  Delete "$INSTDIR\include\SFML\Window\Joystick.hpp"
  Delete "$INSTDIR\include\SFML\Window\Keyboard.hpp"
  Delete "$INSTDIR\include\SFML\Window\Mouse.hpp"
  Delete "$INSTDIR\include\SFML\Window\Sensor.hpp"
  Delete "$INSTDIR\include\SFML\Window\Touch.hpp"
  Delete "$INSTDIR\include\SFML\Window\VideoMode.hpp"
  Delete "$INSTDIR\include\SFML\Window\Vulkan.hpp"
  Delete "$INSTDIR\include\SFML\Window\Window.hpp"
  Delete "$INSTDIR\include\SFML\Window\WindowBase.hpp"
  Delete "$INSTDIR\include\SFML\Window\WindowHandle.hpp"
  Delete "$INSTDIR\include\SFML\Window\WindowStyle.hpp"
  Delete "$INSTDIR\include\SFML\Window.hpp"
  Delete "$INSTDIR\lib"
  Delete "$INSTDIR\lib\cmake"
  Delete "$INSTDIR\lib\cmake\SFML"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLConfig.cmake"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLConfigDependencies.cmake"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLConfigVersion.cmake"
  Delete "$INSTDIR\lib\libsfml-audio.a"
  Delete "$INSTDIR\lib\libsfml-graphics.a"
  Delete "$INSTDIR\lib\libsfml-main.a"
  Delete "$INSTDIR\lib\libsfml-network.a"
  Delete "$INSTDIR\lib\libsfml-system.a"
  Delete "$INSTDIR\lib\libsfml-window.a"
  Delete "$INSTDIR\Unspecified"
  Delete "$INSTDIR\assets"
  Delete "$INSTDIR\assets\fonts"
  Delete "$INSTDIR\assets\fonts\Cute Egg.ttf"
  Delete "$INSTDIR\assets\fonts\CuteFont-Regular.otf"
  Delete "$INSTDIR\assets\levels"
  Delete "$INSTDIR\assets\levels\levels.txt"
  Delete "$INSTDIR\assets\levels\lvl1.txt"
  Delete "$INSTDIR\assets\levels\lvl2.txt"
  Delete "$INSTDIR\assets\textures"
  Delete "$INSTDIR\assets\textures\grass.png"
  Delete "$INSTDIR\assets\textures\honguito.png"
  Delete "$INSTDIR\assets\textures\manzanita.png"
  Delete "$INSTDIR\assets\textures\snekbody1.png"
  Delete "$INSTDIR\assets\textures\snekbody2.png"
  Delete "$INSTDIR\assets\textures\snekbody3.png"
  Delete "$INSTDIR\assets\textures\snekhead.png"
  Delete "$INSTDIR\bin"
  Delete "$INSTDIR\bin\openal32.dll"
  Delete "$INSTDIR\bin\SNAKE_GAME.exe"
  Delete "$INSTDIR\lib"
  Delete "$INSTDIR\lib\cmake"
  Delete "$INSTDIR\lib\cmake\SFML"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLStaticTargets-noconfig.cmake"
  Delete "$INSTDIR\lib\cmake\SFML\SFMLStaticTargets.cmake"
  Delete "$INSTDIR\lib\libFLAC.a"
  Delete "$INSTDIR\lib\libfreetype.a"
  Delete "$INSTDIR\lib\libogg.a"
  Delete "$INSTDIR\lib\libopenal32.a"
  Delete "$INSTDIR\lib\libvorbis.a"
  Delete "$INSTDIR\lib\libvorbisenc.a"
  Delete "$INSTDIR\lib\libvorbisfile.a"
  Delete "$INSTDIR\share"
  Delete "$INSTDIR\share\doc"
  Delete "$INSTDIR\share\doc\SFML"
  Delete "$INSTDIR\share\doc\SFML\license.md"
  Delete "$INSTDIR\share\doc\SFML\readme.md"

  RMDir "$INSTDIR\include\SFML\Audio"
  RMDir "$INSTDIR\include\SFML\Graphics"
  RMDir "$INSTDIR\include\SFML\Network"
  RMDir "$INSTDIR\include\SFML\System"
  RMDir "$INSTDIR\include\SFML\Window"
  RMDir "$INSTDIR\include\SFML"
  RMDir "$INSTDIR\include"
  RMDir "$INSTDIR\lib\cmake\SFML"
  RMDir "$INSTDIR\lib\cmake"
  RMDir "$INSTDIR\lib"
  RMDir "$INSTDIR\devel"
  RMDir "$INSTDIR\assets\fonts"
  RMDir "$INSTDIR\assets\levels"
  RMDir "$INSTDIR\assets\textures"
  RMDir "$INSTDIR\assets"
  RMDir "$INSTDIR\bin"
  RMDir "$INSTDIR\lib\cmake\SFML"
  RMDir "$INSTDIR\lib\cmake"
  RMDir "$INSTDIR\lib"
  RMDir "$INSTDIR\share\doc\SFML"
  RMDir "$INSTDIR\share\doc"
  RMDir "$INSTDIR\share"
  RMDir "$INSTDIR\Unspecified"


!ifdef CPACK_NSIS_ADD_REMOVE
  ;Remove the add/remove program
  Delete "$INSTDIR\AddRemove.exe"
!endif

  ;Remove the uninstaller itself.
  Delete "$INSTDIR\Uninstall.exe"
  DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1"

  ;Remove the installation directory if it is empty.
  RMDir "$INSTDIR"

  ; Remove the registry entries.
  DeleteRegKey SHCTX "Software\Humanity\SNAKE_GAME 0.1.1"

  ; Removes all optional components
  !insertmacro SectionList "RemoveSection_CPack"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP

  Delete "$SMPROGRAMS\$MUI_TEMP\Uninstall.lnk"



  ;Delete empty start menu parent directories
  StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"

  startMenuDeleteLoop:
    ClearErrors
    RMDir $MUI_TEMP
    GetFullPathName $MUI_TEMP "$MUI_TEMP\.."

    IfErrors startMenuDeleteLoopDone

    StrCmp "$MUI_TEMP" "$SMPROGRAMS" startMenuDeleteLoopDone startMenuDeleteLoop
  startMenuDeleteLoopDone:

  ; If the user changed the shortcut, then uninstall may not work. This should
  ; try to fix it.
  StrCpy $MUI_TEMP "$START_MENU"
  Delete "$SMPROGRAMS\$MUI_TEMP\Uninstall.lnk"


  ;Delete empty start menu parent directories
  StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"

  secondStartMenuDeleteLoop:
    ClearErrors
    RMDir $MUI_TEMP
    GetFullPathName $MUI_TEMP "$MUI_TEMP\.."

    IfErrors secondStartMenuDeleteLoopDone

    StrCmp "$MUI_TEMP" "$SMPROGRAMS" secondStartMenuDeleteLoopDone secondStartMenuDeleteLoop
  secondStartMenuDeleteLoopDone:

  DeleteRegKey /ifempty SHCTX "Software\Humanity\SNAKE_GAME 0.1.1"

  Push $INSTDIR\bin
  StrCmp $DO_NOT_ADD_TO_PATH_ "1" doNotRemoveFromPath 0
    Call un.RemoveFromPath
  doNotRemoveFromPath:
SectionEnd

;--------------------------------
; determine admin versus local install
; Is install for "AllUsers" or "JustMe"?
; Default to "JustMe" - set to "AllUsers" if admin or on Win9x
; This function is used for the very first "custom page" of the installer.
; This custom page does not show up visibly, but it executes prior to the
; first visible page and sets up $INSTDIR properly...
; Choose different default installation folder based on SV_ALLUSERS...
; "Program Files" for AllUsers, "My Documents" for JustMe...

Function .onInit
  StrCmp "" "ON" 0 inst

  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SNAKE_GAME 0.1.1" "UninstallString"
  StrCmp $0 "" inst

  MessageBox MB_YESNOCANCEL|MB_ICONEXCLAMATION \
  "SNAKE_GAME 0.1.1 is already installed. $\n$\nDo you want to uninstall the old version before installing the new one?" \
  /SD IDYES IDYES uninst IDNO inst
  Abort

;Run the uninstaller
uninst:
  ClearErrors
  # $0 should _always_ be quoted, however older versions of CMake did not
  # do this.  We'll conditionally remove the begin/end quotes.
  # Remove first char if quote
  StrCpy $2 $0 1 0      # copy first char
  StrCmp $2 "$\"" 0 +2  # if char is quote
  StrCpy $0 $0 "" 1     # remove first char
  # Remove last char if quote
  StrCpy $2 $0 1 -1     # copy last char
  StrCmp $2 "$\"" 0 +2  # if char is quote
  StrCpy $0 $0 -1       # remove last char

  StrLen $2 "\Uninstall.exe"
  StrCpy $3 $0 -$2 # remove "\Uninstall.exe" from UninstallString to get path
  ExecWait '"$0" /S _?=$3' ;Do not copy the uninstaller to a temp file

  IfErrors uninst_failed inst
uninst_failed:
  MessageBox MB_OK|MB_ICONSTOP "Uninstall failed."
  Abort


inst:
  ; Reads components status for registry
  !insertmacro SectionList "InitSection"

  ; check to see if /D has been used to change
  ; the install directory by comparing it to the
  ; install directory that is expected to be the
  ; default
  StrCpy $IS_DEFAULT_INSTALLDIR 0
  StrCmp "$INSTDIR" "$PROGRAMFILES\SNAKE_GAME 0.1.1" 0 +2
    StrCpy $IS_DEFAULT_INSTALLDIR 1

  StrCpy $SV_ALLUSERS "JustMe"
  ; if default install dir then change the default
  ; if it is installed for JustMe
  StrCmp "$IS_DEFAULT_INSTALLDIR" "1" 0 +2
    StrCpy $INSTDIR "$DOCUMENTS\SNAKE_GAME 0.1.1"

  ClearErrors
  UserInfo::GetName
  IfErrors noLM
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  StrCmp $1 "Admin" 0 +4
    SetShellVarContext all
    ;MessageBox MB_OK 'User "$0" is in the Admin group'
    StrCpy $SV_ALLUSERS "AllUsers"
    Goto done
  StrCmp $1 "Power" 0 +3
    SetShellVarContext all
    ;MessageBox MB_OK 'User "$0" is in the Power Users group'
    StrCpy $SV_ALLUSERS "AllUsers"
    Goto done

  noLM:
    StrCpy $SV_ALLUSERS "AllUsers"
    ;Get installation folder from registry if available

  done:
  StrCmp $SV_ALLUSERS "AllUsers" 0 +3
    StrCmp "$IS_DEFAULT_INSTALLDIR" "1" 0 +2
      StrCpy $INSTDIR "$PROGRAMFILES\SNAKE_GAME 0.1.1"

  StrCmp "" "ON" 0 noOptionsPage
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "NSIS.InstallOptions.ini"

  noOptionsPage:
FunctionEnd
