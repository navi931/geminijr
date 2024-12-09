#TEMPLATE(ClarioNET, 'ClarioNET Thin Client Templates V1.3'),FAMILY('ABC'),FAMILY('CW20')
#!
#SYSTEM
#EQUATE(%ClarioNETVersion      ,'Version 1.3,  1-Dec-2002')
#EQUATE(%ClarioNETVerCpnyName  ,'ClarioNET for Clarion 5.5' )
#EQUATE(%ClarioNETVerSlogan    ,'Thin Client Deployment System')
#EQUATE(%ClarioNETVerCpyRght   ,'Copyright 2001-2002 by Michael D. Brooks, All rights reserved.')
#EQUATE(%ClarioNETWeb          ,'www.ClarioNET.com'  )
#!
#EXTENSION (ClarioNET, 'ClarioNET (Server) Internet Application Extension'),APPLICATION(ClarioNETProcedure(ClarioNET)),FIRST,SINGLE
#!
#BOXED(%ClarioNETVersion),AT(,0,,60)
    #DISPLAY   (%ClarioNETVerCpnyName),AT(10,10)
    #DISPLAY   (%ClarioNETVerSlogan  ),AT(10,19)
    #DISPLAY   (%ClarioNETVerCpyRght ),AT(10,28)
    #DISPLAY   (%ClarioNETWeb),AT(10,37)
#ENDBOXED
#!
#PROMPT('Enable ClarioNET ',CHECK),%ClarioNETEnabled,DEFAULT(1),AT(10,49)
#ENABLE(%ClarioNETEnabled)
#SHEET
  #TAB('&General'),WHERE(%ProgramExtension = 'EXE')
#PROMPT ('License Password', @s27), %LicensePassword,AT(75,,115,)
#DISPLAY ('     "xxxxxx-xxxxxx-xxxxxx-xxxxxx" (include dashes!)')
#DISPLAY ('     Valid password removes demo messages')
#DISPLAY('')
#PROMPT ('Application Visible on Server (EXE Broker Only)',CHECK),%ViewAppScreen,DEFAULT(0),AT(10)
#PROMPT ('Windows HELP sent to client', CHECK), %HelpMode,DEFAULT(1),AT(10)
#PROMPT ('INI Files Default to Client', CHECK), %INIMode,DEFAULT(0),AT(10)
#PROMPT ('Reports use a progress bar (slower)', CHECK), %ReportProgBar,DEFAULT(0),AT(10)
#PROMPT ('Use 56 bit Blowfish Encryption', CHECK), %BlowfishKey, DEFAULT(1),AT(10)
#DISPLAY('')
#PROMPT ('Implement as continuous connection', CHECK), %Continuous,DEFAULT(0),AT(10)
#ENABLE(%Continuous)
#PROMPT ('Client refresh interval (min)', SPIN(@n5, 0, 9999)), %RefreshInterval,DEFAULT(5),AT(140,,30,)
#ENDENABLE
#ENABLE(NOT %Continuous)
#PROMPT ('CLIENT Auto Shutdown', SPIN(@n5, 0, 9999)), %ClientAppTimeOut,DEFAULT(15),AT(140,,30,)
#DISPLAY('      Minutes. "0" will disable inactivity check.')
#DISPLAY('      See documentation for details!')
#ENDENABLE
#DISPLAY('')
#PROMPT ('SERVER Auto Shutdown', SPIN(@n5, 0, 9999)), %ServerAppTimeOut,DEFAULT(20),AT(140,,30,)
#DISPLAY('      Minutes. "0" will disable inactivity check.')
#DISPLAY('      See documentation for details!')
#DISPLAY('')
#PROMPT ('USE ABC Toolbar', CHECK), %UseToolbars,DEFAULT(0),AT(10)
#DISPLAY('      ABC application toolbar will be')
#DISPLAY('      duplicated on each window with a browse.')
#DISPLAY('')
  #ENDTAB
  #TAB('&Advanced')
#PROMPT('CPCS Report Generation Compatability ',CHECK),%CPCSCompatibility,DEFAULT(0),AT(10)
#PROMPT('LodeStar RPM (tm) Templates Compatibility ',CHECK),%RPMCompatibility,DEFAULT(0),AT(10)
#!*****************************************************************************
#! Fomin Report Builder compatibility prompts
#! supplied by Oleg Fomin <fomin@mail.com>
#!*****************************************************************************
#DISPLAY('')
#PROMPT('Fomin Report Builder Compatibility ',CHECK),%FRBCompatibility,DEFAULT(0),AT(10)
#ENABLE(%FRBCompatibility)
  #PROMPT('Response on EDIT request during remote session',OPTION),%FRBEditActionResponse,AT(10,,175)
  #PROMPT('No action',RADIO)
  #PROMPT('Display a warning message',RADIO)
  #ENABLE(%FRBEditActionResponse = 'Display a warning message')
    #BOXED('Warning Message Text'),AT(10,,175),SECTION
      #PROMPT('',TEXT),%FRBEditWarningText,AT(10,2,165,20),DEFAULT('The Report Formatter is not available during remote session yet.')
    #ENDBOXED
  #ENDENABLE
  #DISPLAY('NOTE: in order to show icons in ReportManager remotely')
  #DISPLAY('you need to ship following files with this server program:')
  #DISPLAY('"Rmroot.ico",  "Rmfolder.ico",  "Rmreport.ico".')
#ENDENABLE
#!*****************************************************************************
  #ENDTAB
#ENDSHEET
#ENDENABLE   #! ClarioNETEnabled
#!
#!
#ATSTART
  #IF(%ClarioNETEnabled)
    #DECLARE(%FrameControlInstance), UNIQUE
    #DECLARE(%FrameControlCopyCode, %FrameControlInstance)
    #EQUATE(%FrameManagerName, %GetFrameManagerName())
    #EQUATE(%DisplayReportWindow,0)
    #EQUATE(%CPCSUsesProgressWindow,0)
  #ENDIF #! ClarioNETEnabled
#END
#!
#!
#AT (%BeforeGenerateApplication),WHERE(%ClarioNETEnabled)
    #IF (NOT %Target32)
      #ERROR ('Internet templates only work in 32bit mode')
    #END
#END
#!
#!           #COMPILE
#AT (%CustomGlobalDeclarations),WHERE(%ClarioNETEnabled)
  #! %CWVersion = 2003 for C2003, 5002 for C5b, and 5500 for C55b2
  #PDEFINE('ClarioNETUsed',1)
   #IF (%AppTemplateFamily = 'ABC')
     #PROJECT('clrnt55s.lib')
   #ELSE
     #CASE(%CWTemplateVersion)
     #OF('v5.5')
     #OROF('v5.5 beta 2')
       #PROJECT('clrnt55s.lib')
     #OF('v5b')
     #OROF('v5a')
       #PROJECT('clrnt50s.lib')
     #OF('v2.003')
       #CASE(%CWVersion)
       #OF(5002)
         #PROJECT('clrnt50s.lib')
       #OF(5500)
       #OROF(5501)
       #OROF(5502)
       #OROF(5503)
       #OROF(5504)
       #OROF(5505)
       #OROF(5506)
       #OROF(5507)
       #OROF(5508)
         #PROJECT('clrnt55s.lib')
       #ENDCASE
     #ELSE
       #PROJECT('!CWTemplateVersion =' & %CWTemplateVersion)
       #PROJECT('!CWVersion =' & %CWVersion)
       #PROJECT('!AppTemplateFamily = ' & %AppTemplateFamily)
     #ENDCASE
   #ENDIF
#ENDAT
#!
#!
#AT(%GlobalData),WHERE(%ClarioNETEnabled)
#! ClarioNET:Global   LIKE(ClarioNET:GlobalClass),EXTERNAL,DLL(dll_mode)  #<!--- ClarioNET ???
    #IF (%UseToolbars)
WebActiveFrame       &ClarioNETToolBarClass                                    #<!--- ClarioNET 2
    #END
#ENDAT
#!
#!
#AT(%GlobalMap),WHERE(%ClarioNETEnabled),PRIORITY(4000)
INCLUDE('CLARIONET.CLW')                                                  #<!--- ClarioNET 3
ClarioNET:GetPrintFileName(SIGNED PageNo),STRING                          #<!--- ClarioNET 4
ClarioNET:HandleClientQuery,STRING                                        #<!--- ClarioNET 4a
#ENDAT
#!
#!
#! This pragma was not reliable.
#! We switched to defining "ClarioNETUsed" in the Project, Properties, Defines area of the APP
#! #AT(%Beforeglobalincludes),PRIORITY(1),WHERE(%ClarioNETEnabled)
#!    PRAGMA('define(ClarioNetUsed=>%(%ClarioNETEnabled+0))')            #<!--- ClarioNET 7 --- Use COMPILE/OMIT('!***',ClarioNetUsed)
#! #ENDAT
#!
#!
#AT(%afterglobalincludes),WHERE(%ClarioNETEnabled),PRIORITY(3800)
   INCLUDE('CLARIONET.INC')                                                    #<!--- ClarioNET 8
#END
#!
#!
#AT(%ProgramProcedures),WHERE(%ClarioNETEnabled),PRIORITY(4000)

!------------------------------------------------------------------------------------------
ClarioNET:GetPrintFileName    PROCEDURE(SIGNED PageNo)
!------------------------------------------------------------------------------------------
    CODE
    RETURN( ClarioNET:GeneratePrintFileName(PageNo) )


!------------------------------------------------------------------------------------------
ClarioNET:HandleClientQuery PROCEDURE
!------------------------------------------------------------------------------------------
Response    STRING(500)     ! Can be any length
    CODE
#EMBED(%ClarioNETHandleClientQuery,'ClarioNET : Handle a query request from client')
! Add your code here to respond to the client query in ClarioNET:Global.ClientQueryRequest

    RETURN(Response)

#ENDAT
#!
#!
#!
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),PRIORITY(6050),WHERE(%ClarioNETEnabled AND (%CWTemplateVersion >= 'v3'))
  #IF (EXTRACT(%WindowStatement, 'APPLICATION') AND (%UseToolbars))
IF ClarioNETServer:Active()                                                 #<!--- ClarioNET 9
  WebActiveFrame  &=ClarioNETTBar
  ClarioNETTBar.ApplicationWindow &= %Window
END
  #END
#ENDAT
#!
#!
#AT (%LocalProcedures),WHERE(%ClarioNETEnabled)
  #IF (EXTRACT(%WindowStatement, 'APPLICATION') AND  (%UseToolbars))
    #CALL(%CalculateFrameControls)
#!
#!
!---------------------------------------------------------------------------------------------------------
ClarioNETTBar.CopyControlsToWindow PROCEDURE(ClarioNETWindowClass CW)
!---------------------------------------------------------------------------------------------------------
XStart      SIGNED(9999)
Height      SIGNED
    CODE
    IF NOT ClarioNETServer:Active() THEN RETURN END
    Height = ClarioNETTBar.ApplicationWindow $ %(%ControlFeq()){PROP:Height}
    SELF.MoveWindowControlsDown(CW, Height)
    #FOR (%FrameControlInstance)
      #SELECT(%Control, %FrameControlInstance)
      #IF (%ControlTool)
    IF XStart > ClarioNETTBar.ApplicationWindow $ %(%ControlFeq()){PROP:XPos}
      XStart = ClarioNETTBar.ApplicationWindow $ %(%ControlFeq()){PROP:XPos}
    END
      #END
    #END

    #FOR (%FrameControlInstance)
      #SELECT(%Control, %FrameControlInstance)
      #IF (%ControlTool)
    SELF.CopyControlToWindow(XStart, %(%ControlFeq()))
      #END
    #END
  #END
#ENDAT
#!
#!
#!
#AT(%GlobalData),WHERE(%ClarioNETEnabled)
  #DECLARE (%IsExternal)
  #DECLARE (%IsDll)
  #IF (%GlobalExternal)
    #SET (%IsDll,      ',DLL(dll_mode)')
    #SET (%IsExternal, ',EXTERNAL,DLL(dll_mode)')
  #END
#END
#!
#!
#!
#AT (%ProgramSetup),WHERE(%ClarioNETEnabled AND %ProgramExtension='EXE'),PRIORITY(1)
  #IF (%ProgramExtension<>'DLL')
    #FOR (%ActiveTemplate)
      #IF (%ActiveTemplate = 'InterProc(Internet)')
!-----------------------------------------------------------------------------------------------
! NOTE : TopSpeed Internet Connect Detected, ClarioNET Disabled BUT calls still placed in code
ClarioNETServer:Disable
!-----------------------------------------------------------------------------------------------
        #BREAK
      #END
    #ENDFOR
!- ClarioNET -----------------------------------------------------------------------------
! You MUST now set the "server" parameters for the client BEFORE the ClarioNETServer:Init call.
! These are ClarioNET:Global.ServerString1 -> 3, defined as STRING(128)
! NOTE: Only "ServerString3" is passed if the system is unlicensed and in "demo" mode.
!-----------------------------------------------------------------------------------------
#EMBED(%ClarioNETSetServerParametersForCLient,'ClarioNET : Set Server Strings Sent to Client')

     #IF (NOT %Continuous)
IF ClarioNETServer:Init('%LicensePassword', %ServerAppTimeOut*60, %ClientAppTimeOut*60, %ViewAppScreen, '%BlowfishKey')  #<!---ClarioNET 15
  ClarioNETServer:SendClientQueryResponse(ClarioNET:HandleClientQuery())
  RETURN
END
     #ELSE
IF ClarioNETServer:Init('%LicensePassword', %ServerAppTimeOut*60, -%RefreshInterval*60, %ViewAppScreen, '%BlowfishKey')  #<!---ClarioNET 16
  ClarioNETServer:SendClientQueryResponse(ClarioNET:HandleClientQuery())
  RETURN
END
     #END

!- ClarioNET -----------------------------------------------------------------------------
! You may now inspect the command line variables received from the "client" by inspecting
! ClarioNET:Global.Param1 -> 5,  defined as STRING(200)
!-----------------------------------------------------------------------------------------
#EMBED(%ClarioNETInspectClientParameters,'ClarioNET : Client Parameters Available for Inspection')
    #IF (%INIMode = 1)
ClarioNET:INIMode(INI_TO_CLIENT)        ! Param=1 to direct all Clarion GETINI & PUTINI to client
                                        ! Param=0 to direct all to server
    #ELSE
ClarioNET:INIMode(INI_TO_SERVER)        ! Param=1 to direct all Clarion GETINI & PUTINI to client
                                        ! Param=0 to direct all to server
    #ENDIF

ClarioNET:EnableHelp(%HelpMode)          ! Param=1 to enable files specified with HELP(..) to be sent to
                                 ! to client, thus making [F1] help availabie.
                                 ! Param=0 turns off sending HELP(..) files to client.
  #ENDIF
#END
#!
#!
#!
#AT (%ProgramEnd),WHERE(%ProgramExtension <> 'DLL'),WHERE(%ClarioNETEnabled)
ClarioNETServer:Kill                                                        #<!---ClarioNET 18
#END
#!
#!
#!
#!
#!--------------------------- Extension added to each procedure -------------------------
#!
#EXTENSION (ClarioNETProcedure, 'ClarioNET (Server) Procedure Extension'),PROCEDURE,FIRST,SINGLE
#BOXED(%ClarioNETVersion),AT(,0,,55)
    #DISPLAY   (%ClarioNETVerCpnyName),AT(10,10)
    #DISPLAY   (%ClarioNETVerSlogan  ),AT(10,20)
    #DISPLAY   (%ClarioNETVerCpyRght ),AT(10,30)
#ENDBOXED
#ENABLE(%ClarioNETEnabled)
#BOXED ('Individual control options'),AT(,85)
  #BUTTON ('Individual Override for ' & %Control), FROM(%Control, %Control), WHERE(%Control), INLINE,AT(,,,80)
    #INSERT (%IndividualControlPrompts)
  #END
#END
#BOXED,WHERE(%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport'),HIDE
  #DISPLAY('ClarioNET does not support PROGRESS windows for')
  #DISPLAY('CPCS Reports. Only the "Generating Report..."')
  #DISPLAY('window on the client will be displayed.')
#ENDBOXED
#ENDENABLE
#!
#!
#!-----------------------------------------------------
#! ClarioNETWindowClass, ALL PROCEDURES, ABC
#!-----------------------------------------------------
#AT(%LocalDataAfterClasses),WHERE(%ClarioNETEnabled AND (%CWTemplateVersion >= 'v3'))
  #IF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
    #IF ((%ProcedureTemplate <> 'Process') AND (%ProcedureTemplate <> 'UnivAbcProcess'))
ClarioNETWindow        ClarioNETWindowClass                                    #<!---ClarioNET 19
    #ELSE
LastPctValue        LONG(0)                                                      #<!---ClarioNET 20
ClarioNET:PW:UserString   STRING(40)
ClarioNET:PW:PctText      STRING(40)
ClarioNET:PW WINDOW('Progress...'),AT(,,142,59),CENTER,TIMER(1),GRAY,DOUBLE
               PROGRESS,USE(Progress:Thermometer,,?ClarioNET:Progress:Thermometer),AT(15,15,111,12),RANGE(0,100)
               STRING(''),AT(0,3,141,10),USE(ClarioNET:PW:UserString),CENTER
               STRING(''),AT(0,30,141,10),USE(ClarioNET:PW:PctText),CENTER
             END
    #ENDIF
  #ELSIF ((%ProcedureTemplate = 'Report') AND %DisplayReportWindow)
ClarioNETWindow        ClarioNETWindowClass                                    #<!---ClarioNET 21
  #ENDIF
  #IF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
  #ENDIF
  #IF (%ProcedureTemplate = 'Report')
TempNameFunc_Flag    SHORT(0)                                                  #<!---ClarioNET 22
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
TempNameFunc_Flag    SHORT(0)                                                  #<!---ClarioNET 23
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNETWindowClass, ALL PROCEDURES, LEGACY
#!-----------------------------------------------------
#!AT(%DataSectionBeforeReport),WHERE(%ClarioNETEnabled AND ((%CWTemplateVersion < 'v3') OR UPPER(SUB(%ProcedureTemplate,1,4))='UNIV'))
#AT(%DataSectionBeforeReport),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR UPPER(SUB(%ProcedureTemplate,1,4))='UNIV'))
#!  #IF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
#!ClarioNETWindow        ClarioNETWindowClass                                    #<!---ClarioNET 24
  #IF ((%ProcedureTemplate = 'Report') AND %DisplayReportWindow)
ClarioNETWindow        ClarioNETWindowClass                                    #<!---ClarioNET 25
  #ENDIF
  #IF (%ProcedureTemplate = 'Report')
TempNameFunc_Flag    SHORT(0)                                                  #<!---ClarioNET 26
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
TempNameFunc_Flag    SHORT(0)                                                  #<!---ClarioNET 27
  #ENDIF
#ENDAT
#!
#!

#AT(%DataSectionBeforeWindow),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR UPPER(SUB(%ProcedureTemplate,1,4))='UNIV'))
  #IF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport') AND (%ProcedureTemplate <> 'UnivAbcProcess'))
ClarioNETWindow        ClarioNETWindowClass                                    #<!---ClarioNET 28
  #ELSIF ((%ProcedureTemplate = 'Report') AND %DisplayReportWindow)
ClarioNETWindow        ClarioNETWindowClass                                    #<!---ClarioNET 29
  #ENDIF
  #IF (%ProcedureTemplate = 'Report')
TempNameFunc_Flag    SHORT(0)                                                  #<!---ClarioNET 30
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
TempNameFunc_Flag    SHORT(0)                                                  #<!---ClarioNET 31
  #ENDIF
#ENDAT
#!
#!
#!
#AT (%DataSectionAfterWindow),WHERE(%ClarioNETEnabled)
  #IF (EXTRACT(%WindowStatement, 'APPLICATION'))
    #IF (%UseToolbars)
      #CALL(%CalculateFrameControls)
ClarioNETTBar        CLASS(ClarioNETToolBarClass)                              #<!---ClarioNET 32
CopyControlsToWindow   PROCEDURE(ClarioNETWindowClass),VIRTUAL
ApplicationWindow      &WINDOW
                     END
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#!
#AT(%WindowManagerMethodCodeSection,'Init','(),BYTE'),PRIORITY(9999),WHERE(%ClarioNETEnabled AND (%ProcedureTemplate = 'Report'))
  #IF(%RPMCompatibility)
RETURN ReturnValue          ! avoid RPM code
  #ENDIF
#ENDAT
#!
#!
#!
#AT(%WindowManagerMethodCodeSection,'Ask'),WHERE(%ClarioNETEnabled),PRIORITY(4999)
  #IF(%ProcedureCategory = 'Form')        #! Fix for DeleteRecord
  #ENDIF
  #IF (%ProcedureTemplate='Splash')
    #FOR (%Control),WHERE(%Control)
      #IF (%HideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '1'; END
      #ELSIF (%UNHideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '0'; END
      #END
      #IF (%DisableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '1'; END
      #ELSIF (%EnableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '0'; END
      #END
    #END
ClarioNET:InitWindow(ClarioNETWindow, %Window, 1, %DisplayTime*100)         #<!---ClarioNET 33
  #ELSIF (%ProcedureTemplate = 'Report' OR ((%ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility))
IF ClarioNETServer:Active() THEN SYSTEM{PROP:PrintMode} = 2 END             #<!---ClarioNET 34
  #IF (%DisplayReportWindow)
ClarioNET:InitWindow(ClarioNETWindow, %Window, 5)                    #<!---ClarioNET 35
  #END
  #ELSIF (EXTRACT(%WindowStatement, 'APPLICATION'))
    #FOR (%Control),WHERE(%Control)
      #IF (%HideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '1'; END
      #ELSIF (%UNHideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '0'; END
      #END
      #IF (%DisableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '1'; END
      #ELSIF (%EnableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '0'; END
      #END
    #END
ClarioNET:InitWindow(ClarioNETWindow, %Window, 3)                           #<!---ClarioNET 36
  #ELSE
    #IF ((%ProcedureTemplate = 'Process') OR (%ProcedureTemplate = 'UnivAbcProcess'))
LastPctValue = 0                                                            #<!---ClarioNET 37
ClarioNET:PW:PctText = ?Progress:PctText{Prop:Text}
ClarioNET:PW:UserString{Prop:Text} = ?Progress:UserString{Prop:Text}
ClarioNET:OpenPushWindow(ClarioNET:PW)
    #ELSE
      #FOR (%Control),WHERE(%Control)
        #IF (%HideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '1'; END
        #ELSIF (%UNHideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '0'; END
        #END
        #IF (%DisableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '1'; END
        #ELSIF (%EnableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '0'; END
        #END
      #END
ClarioNET:InitWindow(ClarioNETWindow, %Window, 1)                           #<!---ClarioNET 38
    #ENDIF
  #ENDIF
  #IF(%ProcedureCategory = 'Form')        #! Fix for DeleteRecord
  #ENDIF
#ENDAT
#!
#!
#AT(%BrowseInit),WHERE(%ClarioNETEnabled),PRIORITY(9999)
  #IF (%CWTemplateVersion >= 'v3')
    #IF (%UseToolbars)
IF ClarioNETServer:Active() AND ClarioNETWindow.ControlsCopied = 0             #<!---ClarioNET 39
  ClarioNETWindow.ThisWindow &= %Window
  WebActiveFrame.CopyControlsToWindow(ClarioNETWindow)
  ClarioNETWindow.ControlsCopied = 1
  ClarioNETWindow.ChangeControl = %ManagerName.ChangeControl
  ClarioNETWindow.InsertControl = %ManagerName.InsertControl
  ClarioNETWindow.DeleteControl = %ManagerName.DeleteControl
END
    #ENDIF
  #ENDIF
#END
#!
#!
#AT(%BrowseInit),WHERE(%ClarioNETEnabled AND %CWTemplateVersion >= 'v3'),LAST
! EIP Not supported by ClarioNET. If Active, turn it off.
IF ClarioNETServer:Active()
  IF %ManagerName.AskProcedure = 0
    CLEAR(%ManagerName.AskProcedure, 1)
  END
END
#END
#!
#!
#AT(%WindowManagerMethodCodeSection,'TakeCloseEvent','(),BYTE'),WHERE(%ClarioNETEnabled AND (%ProcedureCategory = 'Form')),PRIORITY(1)
IF ClarioNETServer:Active()
  IF SELF.Response <> RequestCompleted AND ~SELF.Primary &= NULL
    IF SELF.CancelAction <> Cancel:Cancel AND ( SELF.Request = InsertRecord OR SELF.Request = ChangeRecord )
      IF ~SELF.Primary.Me.EqualBuffer(SELF.Saved)
        IF BAND(SELF.CancelAction,Cancel:Save)
          IF BAND(SELF.CancelAction,Cancel:Query)
            CASE SELF.Errors.Message(Msg:SaveRecord,Button:Yes+Button:No,Button:No)
            OF Button:Yes
              POST(Event:Accepted,SELF.OKControl)
              RETURN Level:Notify
            !OF BUTTON:Cancel
            !  SELECT(SELF.FirstField)
            !  RETURN Level:Notify
            END
          ELSE
            POST(Event:Accepted,SELF.OKControl)
            RETURN Level:Notify
          END
        ELSE
          IF SELF.Errors.Throw(Msg:ConfirmCancel) = Level:Cancel
            SELECT(SELF.FirstField)
            RETURN Level:Notify
          END
        END
      END
    END
    IF SELF.OriginalRequest = InsertRecord AND SELF.Response = RequestCancelled
      IF SELF.Primary.CancelAutoInc() THEN
        SELECT(SELF.FirstField)
        RETURN Level:Notify
      END
    END
    !IF SELF.LastInsertedPosition
    !  SELF.Response = RequestCompleted
    !  SELF.Primary.Me.TryReget(SELF.LastInsertedPosition)
    !END
  END
#!MDB OLD CODE REMOVED 7-25-01 Follows ----------------------------------
#!  RETURN Level:Benign ! OLD CODE                                                                  !---ClarioNET ??
#!END                   ! OLD CODE                                                                  !---ClarioNET ??
#!#ENDAT
#!MDB OLD CODE REMOVED 7-25-01 Preceeds ---------------------------------

#!MDB REPLACEMENT CODE Added 7-25-01 Follows ----------------------------------
  RETURNValue = Level:Benign                                                                        !---ClarioNET ??
ELSE                                                                                                !---ClarioNET ??
#ENDAT
#!
#AT(%WindowManagerMethodCodeSection,'TakeCloseEvent','(),BYTE'),WHERE(%ClarioNETEnabled AND (%ProcedureCategory = 'Form')),PRIORITY(5001)
END                                                                                                 !---ClarioNET ??
#ENDAT
#!MDB REPLACEMENT CODE Added 7-25-01 Preceeds ----------------------------------
#!
#!
#!
#AT(%WindowManagerMethodCodeSection,'TakeEvent','(),BYTE'),WHERE(%ClarioNETEnabled),PRIORITY(4100)
  #IF (%DisplayReportWindow AND (%ProcedureTemplate = 'Report'))
IF ClarioNET:TakeEvent(ClarioNETWindow)                                    #<!---ClarioNET 41
  BREAK
END
  #ELSIF (%DisplayReportWindow AND ((%ProcedureTemplate = 'UnivAbcProcess') AND %CPCSCompatibility))
  #ELSIF (%DisplayReportWindow AND ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility))
IF ClarioNET:TakeEvent(ClarioNETWindow)                                    #<!---ClarioNET 42
  BREAK
END
  #ELSIF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport') AND (%ProcedureTemplate <> 'UnivAbcProcess'))
    #IF (%ProcedureTemplate <> 'Process')
IF ClarioNET:TakeEvent(ClarioNETWindow)                                    #<!---ClarioNET 43
  BREAK
END
    #ENDIF
  #ENDIF
#END
#!
#!
#!
#!
#!-----------------------------------------------------
#! %Report{PROP:TempNameFunc}, REPORT PROCEDURES, ABC
#!-----------------------------------------------------
#AT(%ProcessManagerMethodCodeSection,'TakeRecord','(),BYTE'),PRIORITY(1),WHERE(%ClarioNETEnabled)
  #IF (%ProcedureTemplate = 'Report')
  IF ClarioNETServer:Active()                                                #<!---ClarioNET 44
    IF TempNameFunc_Flag = 0
      TempNameFunc_Flag = 1
      %Report{PROP:TempNameFunc} = ADDRESS(ClarioNET:GetPrintFileName)
    END
  #IF (%ReportProgBar = 1)
    ClarioNET:UpdateReportProgress(Progress:Thermometer)
  #END
  END
  #ELSIF ((%ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
  IF ClarioNETServer:Active()                                                #<!---ClarioNET 45
    IF TempNameFunc_Flag = 0
      TempNameFunc_Flag = 1
      %Report{PROP:TempNameFunc} = ADDRESS(ClarioNET:GetPrintFileName)
    END
  #IF (%ReportProgBar = 1)
    ClarioNET:UpdateReportProgress(Progress:Thermometer)
  #END
  END
  #ENDIF
#ENDAT
#!
#!
#AT(%GetNextRecordNextSucceeds),WHERE((UPPER(SUB(%ProcedureTemplate,1,4))='UNIV') AND %ClarioNETEnabled)
  #IF (%ReportProgBar = 1)
    #IF((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
IF ClarioNETServer:Active()
  ClarioNET:UpdateReportProgress(Progress:Thermometer)
END
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:AddMetafileName, REPORT PROCEDURES, ABC
#!-----------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'AskPreview'),PRIORITY(1),WHERE(%ClarioNETEnabled)
  #IF (%ProcedureTemplate = 'Report')
IF ClarioNETServer:Active()                                                #<!---ClarioNET 46
  IF ~SELF.Preview &= NULL AND SELF.Response = RequestCompleted
    ENDPAGE(SELF.Report)
    LOOP TempNameFunc_Flag = 1 TO RECORDS(SELF.PreviewQueue)
      GET(SELF.PreviewQueue, TempNameFunc_Flag)
      ClarioNET:AddMetafileName(SELF.PreviewQueue.Filename)
    END
    ClarioNET:SetReportProperties(%Report)
    FREE(SELF.PreviewQueue)
    TempNameFunc_Flag = 0
  END
ELSE
  #INDENT(2)
  #ELSIF  ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
IF ClarioNETServer:Active()                                                #<!---ClarioNET 47
  IF ~SELF.Preview &= NULL AND SELF.Response = RequestCompleted
    ENDPAGE(SELF.Report)
    LOOP TempNameFunc_Flag = 1 TO RECORDS(SELF.PreviewQueue)
      GET(SELF.PreviewQueue, TempNameFunc_Flag)
      ClarioNET:AddMetafileName(SELF.PreviewQueue.Filename)
    END
    ClarioNET:SetReportProperties(%Report)
    FREE(SELF.PreviewQueue)
    TempNameFunc_Flag = 0
  END
ELSE
  #INDENT(2)
  #ENDIF
#ENDAT
#!
#!
#AT(%WindowManagerMethodCodeSection,'AskPreview'),LAST,WHERE(%ClarioNETEnabled)
  #IF (%ProcedureTemplate = 'Report')
    #INDENT(-2)
END                                                                        #<!---ClarioNET 48
  #ELSIF  ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
    #INDENT(-2)
END                                                                        #<!---ClarioNET 49
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:AddMetafileName, REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT(%BeforePrintPreview),WHERE((%AppTemplateFamily = 'CLARION') AND %ClarioNETEnabled)
  #IF(%ProcedureTemplate = 'Report')
IF ClarioNETServer:Active()                                             #<!---ClarioNET 50
  IF LocalResponse = RequestCompleted
    ENDPAGE(%Report)
    LOOP TempNameFunc_Flag = 1 TO RECORDS(PrintPreviewQueue)
      GET(PrintPreviewQueue, TempNameFunc_Flag)
      ClarioNET:AddMetafileName(PrintPreviewQueue)
    END
    ClarioNET:SetReportProperties(%Report)
    TempNameFunc_Flag = 0
  END
ELSE
  #ENDIF
#ENDAT
#!
#!
#!
#AT(%CPCSCNetCapture),WHERE((UPPER(SUB(%ProcedureTemplate,1,4))='UNIV') AND %ClarioNETEnabled)
  #IF((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
IF ClarioNETServer:Active()                                                                     #<!---ClarioNET 51
  ClarioNET:PutIni('ClarioNET','CPCSDesiredInitZoom'   ,%DesiredInitZoomPct,'.\CPCSCNET.INI')
  ClarioNET:PutIni('ClarioNET','CPCSIniFileToUse'      ,CLIP(INIFileToUse), '.\CPCSCNET.INI')
  ClarioNET:PutIni('ClarioNET','CPCSPreviewOptions'    ,PreviewOptions,'.\CPCSCNET.INI')
  ClarioNET:PutIni('ClarioNET','CPCSWmf2AsciiName'     ,Wmf2AsciiName,'.\CPCSCNET.INI')
  ClarioNET:PutIni('ClarioNET','CPCSAsciiLineOption'   ,AsciiLineOption,'.\CPCSCNET.INI')
  ClarioNET:PutIni('ClarioNET','CPCSPreviewHelpFile'   ,'%PreviewHelpFile','.\CPCSCNET.INI')
  ClarioNET:PutIni('ClarioNET','CPCSPreviewHelpContext','%PreviewHelpContext','.\CPCSCNET.INI')
  BackupGlobalResponse# = GlobalResponse
  LocalResponse = RequestCancelled
  GlobalResponse = RequestCancelled
  LOOP TempNameFunc_Flag = 1 TO RECORDS(PrintPreviewQueue)
    GET(PrintPreviewQueue, TempNameFunc_Flag)
    ClarioNET:AddMetafileName(PrintPreviewQueue)
  END
  ClarioNET:SetReportProperties(%Report)
  TempNameFunc_Flag = 0
ELSE
  #ENDIF
#ENDAT
#!
#!
#!
#AT(%BeforeClosingReport),WHERE(((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')) AND %ClarioNETEnabled)
  #IF (%ProcedureTemplate = 'Report')
END !IF ClarioNETServer:Active()                                           #<!---ClarioNET 52
  #ENDIF
#ENDAT
#!
#!
#AT(%AfterPrintPreview),WHERE(((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')) AND %ClarioNETEnabled)
  #IF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
END                                                                        #<!---ClarioNET 53
  #ENDIF
#ENDAT
#!
#!
#!
#!-----------------------------------------------------
#! ClarioNET:OpenWindowInit, NON REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT (%AfterWindowOpening),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF (%ProcedureTemplate = 'Report')
    #! DO NOTHING
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport' OR %ProcedureTemplate = 'UnivAbcProcess') AND %CPCSCompatibility)
    #! DO NOTHING
  #ELSE
ClarioNET:OpenWindowInit(ClarioNETWindow)                                   #<!---ClarioNET 54
    #IF (%ProcedureTemplate='Splash')
      #FOR (%Control),WHERE(%Control)
        #IF (%HideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '1'; END
        #ELSIF (%UNHideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '0'; END
        #END
        #IF (%DisableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '1'; END
        #ELSIF (%EnableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '0'; END
        #END
      #END
ClarioNET:InitWindow(ClarioNETWindow, %Window, 1, %DisplayTime*100)         #<!---ClarioNET 55
    #ELSIF (EXTRACT(%WindowStatement, 'APPLICATION'))
      #FOR (%Control),WHERE(%Control)
        #IF (%HideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '1'; END
        #ELSIF (%UNHideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '0'; END
        #END
        #IF (%DisableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '1'; END
        #ELSIF (%EnableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '0'; END
        #END
      #END
ClarioNET:InitWindow(ClarioNETWindow, %Window, 3)                           #<!---ClarioNET 56
    #ELSE
      #FOR (%Control),WHERE(%Control)
        #IF (%HideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '1'; END
        #ELSIF (%UNHideControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Hide} = '0'; END
        #END
        #IF (%DisableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '1'; END
        #ELSIF (%EnableControlDuringClarioNET)
IF ClarioNETServer:Active(); %Control{PROP:Disable} = '0'; END
        #END
      #END
ClarioNET:InitWindow(ClarioNETWindow, %Window, 1)                           #<!---ClarioNET 57
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:KillWindow, NON REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT (%AfterWindowClosing),WHERE(%ClarioNETEnabled AND %AppTemplateFamily = 'CLARION')
  #IF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
IF WindowOpened                                                              #<!---ClarioNET 58
  ClarioNET:KillWindow(ClarioNETWindow)
END
  #ENDIF
#ENDAT
#!
#!
#!
#!-----------------------------------------------------
#! BackupGlobalResponse#, REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT(%BeforeClosingReport),WHERE(((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')) AND %ClarioNETEnabled)
  #IF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
IF ClarioNETServer:Active()                                                #<!---ClarioNET 59
  GlobalResponse = BackupGlobalResponse#
END
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! SendReport, REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT(%EndOfProcedure),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF (%ProcedureTemplate = 'Report')
IF ClarioNETServer:Active()                                                #<!---ClarioNET 60
    #IF (%DisplayReportWindow)
  ClarioNET:KillWindow(ClarioNETWindow)                                    #<!---ClarioNET 61
  ClarioNET:SendReport
    #ELSE
  ClarioNET:EndReport                                                      #<!---ClarioNET 62
    #ENDIF
END                                                                        #<!---ClarioNET 63
  #ELSIF  ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
IF ClarioNETServer:Active()                                                #<!---ClarioNET 64
    #IF (%DisplayReportWindow)
  ClarioNET:KillWindow(ClarioNETWindow)                                    #<!---ClarioNET 65
  ClarioNET:SendReport
    #ELSE
  ClarioNET:EndReport                                                      #<!---ClarioNET 66
    #ENDIF
END                                                                        #<!---ClarioNET 67
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:OpenWindowInit, REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT (%AfterOpeningWindow),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION' AND %ProcedureTemplate<>'Process' AND %ProcedureTemplate<>'UnivProcess') OR (%ProcedureTemplate='UnivReport') OR (%ProcedureTemplate='UnivAbcReport')))
IF ClarioNETServer:Active() THEN SYSTEM{PROP:PrintMode} = 2 END            #<!---ClarioNET 68
  #IF (%DisplayReportWindow AND (%ProcedureTemplate = 'Report'))
ClarioNET:OpenWindowInit(ClarioNETWindow)                                  #<!---ClarioNET 69
ClarioNET:InitWindow(ClarioNETWindow, ProgressWindow, 5)
  #ELSIF ((%DisplayReportWindow) AND ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility))
ClarioNET:OpenWindowInit(ClarioNETWindow)                                  #<!---ClarioNET 70
ClarioNET:InitWindow(ClarioNETWindow, ProgressWindow, 5)
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:TakeEvent, NOT REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT(%AcceptLoopBeforeEventHandling),PRIORITY(4000),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport') AND (%ProcedureTemplate <> 'UnivAbcProcess'))
IF ClarioNET:TakeEvent(ClarioNETWindow)                                    #<!---ClarioNET 71
  BREAK
END
  #ENDIF
#END
#!
#!
#!
#!-----------------------------------------------------
#! ClarioNET:TakeEvent, REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT(%BeginningOfAcceptLoop),PRIORITY(4000),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF (%DisplayReportWindow AND (%ProcedureTemplate = 'Report'))
IF ClarioNET:TakeEvent(ClarioNETWindow)                                    #<!---ClarioNET 72
  BREAK
END
  #ELSIF (%DisplayReportWindow AND ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility))
IF ClarioNET:TakeEvent(ClarioNETWindow)                                    #<!---ClarioNET 73
  BREAK
END
  #ENDIF
#ENDAT
#!
#!  
#!-----------------------------------------------------
#! ClarioNET:StartReport, REPORT PROCEDURES, LEGACY
#!-----------------------------------------------------
#AT(%WindowEventOpenWindowBefore),PRIORITY(1),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF ((%ProcedureTemplate = 'Report') AND (NOT %DisplayReportWindow))
ClarioNET:StartReport                                                      #<!---ClarioNET 74
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
    #IF (NOT %DisplayReportWindow)
ClarioNET:StartReport                                                      #<!---ClarioNET 75
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
!---------------------------
! Supplied by Larry Teames
!---------------------------
#AT(%HandCodeEventOpnWin),PRIORITY(1),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
    #IF (NOT %DisplayReportWindow)
ClarioNET:StartReport                                                      !--- ClarioNET 75A
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#AT(%BeforeOpeningWindow),PRIORITY(9999),WHERE(%ClarioNETEnabled AND UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')
  #IF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
 OMIT('(0)',ClarioNETUsed)                                                      !--- ClarioNET 75B
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:CloseWindow, ALL PROCEDURES LEGACY
#!-----------------------------------------------------
#AT(%WithinEventProcessing),PRIORITY(4000),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF ((%ProcedureTemplate = 'Report') AND %DisplayReportWindow)
OF Event:CloseWindow
  ClarioNET:CloseWindow(ClarioNETWindow)                                   #<!---ClarioNET 76
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
    #IF (%DisplayReportWindow)
OF Event:CloseWindow
  ClarioNET:CloseWindow(ClarioNETWindow)                                   #<!---ClarioNET 77
    #ENDIF
  #ELSIF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
OF Event:CloseWindow
  ClarioNET:CloseWindow(ClarioNETWindow)                                   #<!---ClarioNET 78
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:OpenWindow, ALL PROCEDURES LEGACY
#!-----------------------------------------------------
#AT(%BeforeOpeningReport),PRIORITY(1),WHERE(%ClarioNETEnabled AND ((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')))
  #IF ((%ProcedureTemplate = 'Report') AND %DisplayReportWindow)
ClarioNET:OpenWindow(ClarioNETWindow)                                      #<!---ClarioNET 79
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
    #IF (%DisplayReportWindow)
ClarioNET:OpenWindow(ClarioNETWindow)                                      #<!---ClarioNET 80
    #ENDIF
  #ELSIF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
ClarioNET:OpenWindow(ClarioNETWindow)                                      #<!---ClarioNET 81
  #ENDIF
#ENDAT
#!
#!
#!
#AT(%BeforePreviewReq),WHERE(%ClarioNETEnabled)
  #IF (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')
IF ClarioNETServer:Active()                                                 #<!---ClarioNET 82
  PreviewReq = True
ELSE
  #ENDIF
#ENDAT
#!
#!
#!
#AT(%AfterPreviewReq),WHERE(%ClarioNETEnabled)
  #IF (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')
END                                                                         #<!---ClarioNET 83
  #ENDIF
#ENDAT
#!
#!
#!
#!-----------------------------------------------------
#! %Report{PROP:TempNameFunc}, REPORT PROCEDURES LEGACY
#!-----------------------------------------------------
#AT(%AfterOpeningReport),WHERE(((%AppTemplateFamily = 'CLARION') OR (UPPER(SUB(%ProcedureTemplate,1,4))='UNIV')) AND %ClarioNETEnabled)
  #IF (%ProcedureTemplate = 'Report')
IF ClarioNETServer:Active()                                                #<!---ClarioNET 84
  IF TempNameFunc_Flag = 0
    TempNameFunc_Flag = 1
    %Report{PROP:TempNameFunc} = ADDRESS(ClarioNET:GetPrintFileName)
  END
#IF (%ReportProgBar = 1)
  ClarioNET:UpdateReportProgress(Progress:Thermometer)
#END
END
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
IF ClarioNETServer:Active()                                                #<!---ClarioNET 85
  IF TempNameFunc_Flag = 0
    TempNameFunc_Flag = 1
    %Report{PROP:TempNameFunc} = ADDRESS(ClarioNET:GetPrintFileName)
  END
#IF (%ReportProgBar = 1)
  ClarioNET:UpdateReportProgress(Progress:Thermometer)
#END
END
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:CloseWindow, ALL PROCEDURES, ABC
#!-----------------------------------------------------
#AT (%WindowEventHandling, 'CloseWindow'), WHERE(%ClarioNETEnabled)
  #IF (%DisplayReportWindow AND (%ProcedureTemplate = 'Report'))
ClarioNET:CloseWindow(ClarioNETWindow)                                     #<!---ClarioNET 86
  #ELSIF (%DisplayReportWindow AND ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility))
ClarioNET:CloseWindow(ClarioNETWindow)                                  #<!---ClarioNET 87
  #ELSIF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
    #IF ((%ProcedureTemplate = 'Process') OR (%ProcedureTemplate = 'UnivAbcProcess'))
ClarioNET:ClosePushWindow(ClarioNET:PW)                                 #<!---ClarioNET 88
    #ELSE
ClarioNET:CloseWindow(ClarioNETWindow)                                  #<!---ClarioNET 89
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:OpenWindow, ALL PROCEDURES, ABC
#!-----------------------------------------------------
#AT (%WindowEventHandling, 'OpenWindow'),WHERE(%ClarioNETEnabled)
  #IF (%ProcedureTemplate = 'Report')
    #IF (%DisplayReportWindow)
ClarioNET:OpenWindow(ClarioNETWindow)                                      #<!---ClarioNET 90
    #ELSE
ClarioNET:StartReport                                                  #<!---ClarioNET 91
    #ENDIF
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
    #IF (%DisplayReportWindow)
ClarioNET:OpenWindow(ClarioNETWindow)                                      #<!---ClarioNET 92
    #ELSE
ClarioNET:StartReport                                                      #<!---ClarioNET 93
    #ENDIF
  #ELSE
    #IF ((%ProcedureTemplate <> 'Process') AND (%ProcedureTemplate <> 'UnivAbcProcess'))
ClarioNET:OpenWindow(ClarioNETWindow)                                   #<!---ClarioNET 94
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:OpenWindowInit, ALL PROCEDURES, ABC
#!-----------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Run','(),BYTE'),PRIORITY(1),WHERE(%ClarioNETEnabled)
  #IF (%DisplayReportWindow AND (%ProcedureTemplate = 'Report'))
ClarioNET:OpenWindowInit(ClarioNETWindow)                                  #<!---ClarioNET 95
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
    #IF (%DisplayReportWindow)
ClarioNET:OpenWindowInit(ClarioNETWindow)                                  #<!---ClarioNET 96
    #END
  #ELSIF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
    #IF ((%ProcedureTemplate <> 'Process') AND (%ProcedureTemplate <> 'UnivAbcProcess'))
ClarioNET:OpenWindowInit(ClarioNETWindow)                                  #<!---ClarioNET 97
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:KillWindow, NOT REPORTS, ABC
#!-----------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Run','(),BYTE'),PRIORITY(9999),WHERE(%ClarioNETEnabled)
  #IF ((%ProcedureTemplate <> 'Report') AND (%ProcedureTemplate <> 'UnivReport') AND (%ProcedureTemplate <> 'UnivAbcReport'))
    #IF ((%ProcedureTemplate <> 'Process') AND (%ProcedureTemplate <> 'UnivAbcProcess'))
ClarioNET:KillWindow(ClarioNETWindow)                                      #<!---ClarioNET 98
    #ENDIF
  #ENDIF
#ENDAT
#!
#!
#AT(%ProcessManagerMethodCodeSection,'TakeRecord','(),BYTE'),PRIORITY(1),WHERE(%ClarioNETEnabled AND ((%ProcedureTemplate = 'Process') OR (%ProcedureTemplate = 'UnivAbcProcess')))
IF LastPctValue <> Progress:Thermometer                                     #<!---ClarioNET 99
  IF INLIST(Progress:Thermometer,'5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90','95')
    LastPctValue = Progress:Thermometer
    ClarioNET:UpdatePushWindow(ClarioNET:PW)
  END
END
#ENDAT
#!
#!
#!-----------------------------------------------------
#! ClarioNET:SendReport, ALL PROCEDURES, ABC
#!-----------------------------------------------------
#AT(%WindowManagerMethodCodeSection,'Run','(),BYTE'),PRIORITY(9999),WHERE(%ClarioNETEnabled)
  #IF (%ProcedureTemplate = 'Report')
IF ClarioNETServer:Active()
    #IF (%DisplayReportWindow)
  ClarioNET:KillWindow(ClarioNETWindow)                                    #<!---ClarioNET 100
  ClarioNET:SendReport
    #ELSE
  ClarioNET:EndReport                                                      #<!---ClarioNET 101
    #ENDIF
END                                                                        #<!---ClarioNET 102
  #ELSIF ((%ProcedureTemplate = 'UnivReport' OR %ProcedureTemplate = 'UnivAbcReport') AND %CPCSCompatibility)
IF ClarioNETServer:Active()
    #IF (%DisplayReportWindow)
  ClarioNET:KillWindow(ClarioNETWindow)                                    #<!---ClarioNET 103
  ClarioNET:SendReport
    #ELSE
  ClarioNET:EndReport                                                      #<!---ClarioNET 104
    #ENDIF
END                                                                        #<!---ClarioNET 105
FREE(SELF.PreviewQueue)
  #ENDIF
#ENDAT
#!*****************************************************************************
#! Fomin Report Builder compatibility code
#! supplied by Oleg Fomin <fomin@mail.com>
#!*****************************************************************************
  #AT(%DataSection),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled)
TempNameFunc_Flag    SHORT(0)                   !---ClarioNET-FRB 010
  #ENDAT
#!*****************************************************************************
  #AT(%BeforeOpenView),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled)
IF ClarioNETServer:Active()
  SYSTEM{PROP:PrintMode} = 2
  ClarioNET:StartReport                         !---ClarioNET-FRB 020
END
  #ENDAT
#!*****************************************************************************
  #AT(%AfterOpeningReport),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled)
IF ClarioNETServer:Active()                     !---ClarioNET-FRB 030
  IF TempNameFunc_Flag = 0
    TempNameFunc_Flag = 1
    SELF.report{PROP:TempNameFunc} = ADDRESS(ClarioNET:GetPrintFileName)
  END
END
  #ENDAT
#!*****************************************************************************
  #AT(%BeforeNEXT),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled)
    #IF (%ReportProgBar = 1)
IF ClarioNETServer:Active()                     !---ClarioNET-FRB 040
  IF Progress:Thermometer <> ROUND(SELF.RecordCounter / SELF.MaxProcessedRecords * 20,1)
    Progress:Thermometer = ROUND(SELF.RecordCounter / SELF.MaxProcessedRecords * 20,1)
    ClarioNET:UpdateReportProgress(Progress:Thermometer * 5) !Update progress bar every fifth percent
    SETTARGET(SELF.Report)
  END
END
    #ENDIF
  #ENDAT
#!*****************************************************************************
  #AT(%BeforePrintReport),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled),LAST
IF NOT ClarioNETServer:Active()                 !---ClarioNET-FRB 050
  #ENDAT
#!*****************************************************************************
  #AT(%AfterSetPrintPreviewFlag),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled),FIRST
END!IF NOT ClarioNETServer:Active()             !---ClarioNET-FRB 060
  #ENDAT
#!*****************************************************************************
  #AT(%BeforePrintPreview),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled),LAST
IF ClarioNETServer:Active()                     !---ClarioNET-FRB 070
  IF LocalResponse = RequestCompleted
    LOOP TempNameFunc_Flag = 1 TO RECORDS(PrintPreviewQueue)
      GET(PrintPreviewQueue, TempNameFunc_Flag)
      ClarioNET:AddMetafileName(PrintPreviewQueue)
    END
    ClarioNET:SetReportProperties(SELF.Report)
    TempNameFunc_Flag = 0
  END
ELSE
  #ENDAT
#!*****************************************************************************
  #AT(%BeforeClosingReport),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled),FIRST
END !IF ClarioNETServer:Active()                !---ClarioNET-FRB 080
  #ENDAT
#!*****************************************************************************
  #AT(%AfterClosingReport),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled)
IF ClarioNETServer:Active()                     !---ClarioNET-FRB 090
  ClarioNET:EndReport
END
  #ENDAT
#!*****************************************************************************
  #AT(%BeforeEditReport),WHERE(%ProcedureTemplate = 'RunTimeReport' AND %FRBCompatibility AND %ClarioNETEnabled)
IF ClarioNETServer:Active()                     !---ClarioNET-FRB 100
    #IF (%FRBEditActionResponse = 'Display a warning message')
  IF MESSAGE('%'FRBEditWarningText','Warning',Icon:Hand)
    EXIT
  END
    #ELSE
  EXIT
    #ENDIF
END
  #ENDAT
#!*****************************************************************************
#!
#!
#!======================================================================================
#GROUP (%CalculateFrameControls),AUTO
#PURGE (%FrameControlInstance)
#PURGE (%FrameControlCopyCode)
#!
  #FOR (%Control), WHERE(%ControlTool AND (%ControlType='BUTTON'))
    #IF (%HasGoodStdAttr())
      #IF (%GetIsStandardToolbarButton())
        #ADD (%FrameControlInstance, INSTANCE(%Control))
      #END
    #END
  #END
#!
#!
#GROUP (%HasGoodStdAttr), AUTO
#EQUATE (%StdAttr, UPPER(EXTRACT(%ControlUnsplitStatement, 'STD', 1)))
#IF ((%StdAttr='') OR (%StdAttr='STD:CLOSE'))
  #RETURN %True
#END
#RETURN %False
#!
#!
#!
#GROUP (%GetIsStandardToolbarButton)
#IF (%AppTemplateFamily = 'CLARION')
#RETURN (SUB(UPPER(%Control), 1, 8)='?TBARBRW')
#ELSE
#RETURN (SUB(UPPER(%Control), 1, 8)='?TOOLBAR')
#END
#!
#!
#!
#!
#GROUP (%ControlFeq)
#IF (%Control)
  #RETURN (%Control)
#END
#RETURN ('?Anon:' & INSTANCE(%Control))
#!
#!
#GROUP (%GetFrameManagerName)
#RETURN (%Procedure & 'Frame')
#!
#!
#!=============================================================================
#!-KBE-09/09/00 (BGN) - Client Side Templates
#!
#EXTENSION (ClarioNETClient, 'ClarioNET (Client) Internet Application Extension'),APPLICATION(ClarioNETProcedureClient(ClarioNET)),FIRST,SINGLE
#!
#BOXED(%ClarioNETVersion),AT(,0,,55)
#!    #IMAGE     (%ClarioNETVerLogo    ),AT(,10,50,40)
    #DISPLAY   (%ClarioNETVerCpnyName),AT(65,10)
    #DISPLAY   (%ClarioNETVerSlogan  ),AT(65,20)
    #DISPLAY   (%ClarioNETVerCpyRght ),AT(65,30)
#ENDBOXED
#PROMPT('Enable ClarioNET ',CHECK),%ClarioNETEnabled,DEFAULT(1),AT(10)
#ENABLE(%ClarioNETEnabled)
    #BOXED('') 
        #DISPLAY('ClarioNET Client Side (Global) Template')
    #ENDBOXED   
    #BOXED('') 
        #PROMPT('Use CPCS ClarioNET Previewer?'    ,CHECK),%ClarioNETUseCPCSPrvw,DEFAULT(%False),AT(10)  
        #PROMPT('Auto-Generate Support Procedures?',CHECK),%ClarioNETAutoGenProcs,DEFAULT(%TRUE),AT(10)
        #BOXED(''),WHERE(%ClarioNETAutoGenProcs)
            #PROMPT('ClarioNET:ClientProcedure?'             ,CHECK),%ClarioNETAutoGenProc1,DEFAULT(%TRUE),AT(10)
            #PROMPT('ClarioNET:ClientFilesReceivedFromServer',CHECK),%ClarioNETAutoGenProc2,DEFAULT(%TRUE),AT(10)
            #PROMPT('ClarioNET:SendClientFilesToServer'      ,CHECK),%ClarioNETAutoGenProc3,DEFAULT(%TRUE),AT(10)
        #ENDBOXED
        #DISPLAY('See Global EMBEDs to insert your own code where')
        #DISPLAY('needed.')
    #ENDBOXED
#ENDENABLE   #! ClarioNETEnabled
#!
#AT(%afterglobalincludes),WHERE(%ClarioNETEnabled),PRIORITY(3800)
   INCLUDE('CLIENT.INC')                                   #<!---ClarioNET 106
#END
#!
#AT(%GlobalData),WHERE(%ClarioNETEnabled)
!---
CLRNT_C     LIKE(ClarioNETSession),EXTERNAL,DLL(dll_mode)  #<!---ClarioNET 107
!---
#ENDAT
#!
#AT (%CustomGlobalDeclarations),WHERE(%ClarioNETEnabled)
    #IF(%ClarioNETUseCPCSPrvw=%True)
      #IF(SUB(%CWVersion,1,2)='55')
  #PROJECT('CPC55CN.LIB')
      #ELSIF(SUB(%CWVersion,1,2)='50')
  #PROJECT('CPCS5CN.LIB')
      #ENDIF
    #ELSE
  #PROJECT('PrntPrvw.lib')
    #ENDIF  
  #! %CWVersion = 2003 for C2003, 5002 for C5b, and 5500 for C55b2
  #CASE(%CWTemplateVersion)
  #OF('v5.5')
  #OROF('v5.5 beta 2')
    #PROJECT('clrnt55c.lib')
    #PROJECT('C55DOSXL.LIB')
  #OF('v5b')
  #OROF('v5a')
    #PROJECT('clrnt50c.lib')
    #PROJECT('C5DOSXL.LIB')
  #OF('v2.003')
    #CASE(%CWVersion)
    #OF(5002)
      #PROJECT('clrnt50c.lib')
      #PROJECT('C5DOSXL.LIB')
    #OF(5500)
    #OROF(5501)
    #OROF(5502)
    #OROF(5503)
    #OROF(5504)
    #OROF(5505)
    #OROF(5506)
    #OROF(5507)
    #OROF(5508)
      #PROJECT('clrnt55c.lib')
      #PROJECT('C55DOSXL.LIB')
    #ENDCASE
  #ELSE
    #PROJECT('!CWTemplateVersion =' & %CWTemplateVersion)
    #PROJECT('!CWVersion =' & %CWVersion)
  #ENDCASE
#ENDAT
#!
#AT(%GlobalMap),WHERE(%ClarioNETEnabled),PRIORITY(4000)
    INCLUDE('CLIENT.CLW')                                  #<!---ClarioNET 108
    MODULE('win32.lib')                                    #<!---ClarioNET 109
      GetTempPath(UNSIGNED, *CSTRING),UNSIGNED,RAW,PASCAL,NAME('GetTempPathA') #<!---ClarioNET 110
    END                                                    #<!---ClarioNET 111
#ENDAT
#!=============================================================================
#AT (%GlobalMap),PRIORITY(5000),WHERE(%ClarioNETEnabled AND %ClarioNETAutoGenProcs)
!---                                  
!--- Auto-Generated By ClarioNET Global Client Template
!---
#IF(%ClarioNETAutoGenProc1)
ClarioNET:ClientProcedure               (*WINDOW W1, STRING P1,<STRING P2> ,<STRING P3 >,|
                                                               <STRING P4> ,<STRING P5 >,|
                                                               <STRING P6> ,<STRING P7 >,|
                                                               <STRING P8> ,<STRING P9 >,|
                                                               <STRING P10>,<STRING P11>,|
                                                               <STRING P12>,<STRING P13>,|
                                                               <STRING P14>,<STRING P15>),STRING
#ENDIF
#IF(%ClarioNETAutoGenProc2)
ClarioNET:ClientFilesReceivedFromServer (SIGNED Value),STRING
#ENDIF
#IF(%ClarioNETAutoGenProc3)
ClarioNET:SendClientFilesToServer       (SHORT Flag, STRING ServerFileInfo),STRING
#ENDIF
!---                                  
#ENDAT
#!=============================================================================
#AT(%ProgramProcedures),WHERE(%ClarioNETEnabled AND %ClarioNETAutoGenProcs AND %ClarioNETAutoGenProc1)
!---                                  
!--- Auto-Generated By ClarioNET Global Client Template
!---                                  
!--- You can Override the default behavior by using the EMBED points
!--- in the Global EMBEDs section
!---                                  
ClarioNET:ClientProcedure               PROCEDURE(*WINDOW W1 , |
                                                  STRING P1  , |
                                                 <STRING P2 >, |
                                                 <STRING P3 >, |
                                                 <STRING P4 >, |
                                                 <STRING P5 >, |
                                                 <STRING P6 >, |
                                                 <STRING P7 >, |
                                                 <STRING P8 >, |
                                                 <STRING P9 >, |
                                                 <STRING P10>, |
                                                 <STRING P11>, |
                                                 <STRING P12>, |
                                                 <STRING P13>, |
                                                 <STRING P14>, |
                                                 <STRING P15>)
!---
#EMBED(%ClarioNETClientProcedureDATA,'ClarioNET:ClientProcedure - DATA'),DATA
!---
!--- Place an OMIT('!END of ClarioNET') in your EMBED code (above) if you do not
!--- want the Default Behavior
!---
LOC:ReturnString    STRING(256)
!END of ClarioNET
!---
 CODE
!---
#EMBED(%ClarioNETClientProcedureCODE,'ClarioNET:ClientProcedure - CODE')
!---
!--- Place an OMIT('!END of ClarioNET') in your EMBED code (above) if you do not
!--- want the Default Behavior
!---
 LOC:ReturnString = 'Successful'
 RETURN(LOC:ReturnString)
!END of ClarioNET
!------------------------------------------------------------------------------
#ENDAT
#!=============================================================================
#AT(%ProgramProcedures),WHERE(%ClarioNETEnabled AND %ClarioNETAutoGenProcs AND %ClarioNETAutoGenProc2)
!---                                  
!--- Auto-Generated By ClarioNET Global Client Template
!---                                  
!--- You can Override the default behavior by using the EMBED points
!--- in the Global EMBEDs section
!---                                  
ClarioNET:ClientFilesReceivedFromServer PROCEDURE(SIGNED Value)
!---
#EMBED(%ClarioNETClientFilesReceivedFromServerDATA,'ClarioNET:ClientFilesReceivedFromServer - DATA'),DATA
!---
!--- Place an OMIT('!END of ClarioNET') in your EMBED code (above) if you do not
!--- want the Default Behavior
!---
LOC:ReturnString    STRING(256)
LOC:Value1          SIGNED
!---
window WINDOW('List of Files Received'),AT(,,251,124),FONT('MS Sans Serif',8,,FONT:regular,CHARSET:ANSI), |
         GRAY,DOUBLE
       STRING('Flag Received fromServer = '),AT(4,4,94,10),USE(?String1)
       STRING(@n12),AT(100,4),USE(LOC:Value1),LEFT
       LIST,AT(4,16,244,88),USE(?List1),FORMAT('20L(2)~Files Received~@s50@'),FROM(FileListQueue)
       BUTTON('OK'),AT(204,108,45,14),USE(?OK)
     END
!END of ClarioNET
 CODE
#EMBED(%ClarioNETClientFilesReceivedFromServerCODE,'ClarioNET:ClientFilesReceivedFromServer - CODE')
!---
!--- Place an OMIT('!END of ClarioNET') in your EMBED code (above) if you do not
!--- want the Default Behavior
!---
 LOC:ReturnString = 'DONE: ClarioNET:ClientFilesReceivedFromServer'
 LOC:Value1       = Value
!---
 OPEN(window)
 ACCEPT
     IF EVENT() = EVENT:Accepted
        BREAK
     END
 END
 CLOSE(window)
 RETURN(LOC:ReturnString)
!END of ClarioNET
!------------------------------------------------------------------------------
#ENDAT
#!=============================================================================
#AT(%ProgramProcedures),WHERE(%ClarioNETEnabled AND %ClarioNETAutoGenProcs AND %ClarioNETAutoGenProc3)
!---                                  
!--- Auto-Generated By ClarioNET Global Client Template
!---                                  
!--- You can Override the default behavior by using the EMBED points
!--- in the Global EMBEDs section
!---                                  
ClarioNET:SendClientFilesToServer       PROCEDURE(SHORT Flag, STRING ServerFileInfo)
!---
!--- This procedure should load FileListQueue with the full drive/directory/name of the files
!--- to send to the server.
!--- The following is SAMPLE CODE ONLY to help you with using FILEDIALOG to load filenames
!--- into the ClarioNET "FileListQueue".
!---
!--- The only requirement of this procedure is that is have a RETURN('') after the CODE statement.
!---
#EMBED(%ClarioNETSendClientFilesToServerDATA,'ClarioNET:SendClientFilesToServer - DATA'),DATA
!---
!--- Place an OMIT('!END of ClarioNET') in your EMBED code (above) if you do not
!--- want the Default Behavior
!---
LocalVars       GROUP,PRE(LOC)
ReturnString        STRING(256)
FileList            STRING(5000)
Extension           STRING('*.*')
PathName            CSTRING(FILE:MaxFilePath)
Pos1                SHORT
Pos2                SHORT
RetVal              SHORT
                END
!END of ClarioNET
!---
 CODE
!---
#EMBED(%ClarioNETSendClientFilesToServerCODE,'ClarioNET:SendClientFilesToServer - CODE')
!---
!--- Place an OMIT('!END of ClarioNET') in your EMBED code (above) if you do not
!--- want the Default Behavior
!---
   LOC:ReturnString = 'ok'
!---
   FREE(FileListQueue)

   LOC:RetVal = FILEDIALOG('Select Files To Send', LOC:FileList, LOC:Extension, 11000b)
   IF LOC:RetVal = 0
      RETURN('no files selected')
   END

   LOC:Pos1 = INSTRING('<124>', LOC:FileList, 1, 1)
   IF LOC:Pos1 = 0
     FLQ:Filename = CLIP(LOC:FileList)
     ADD(FileListQueue)
   ELSE
     LOC:PathName = LOC:FileList[1 : LOC:Pos1-1] & '\'
     LOOP
       LOC:Pos2 = INSTRING('<124>', LOC:FileList, 1, LOC:Pos1+1)
       IF LOC:Pos2 <> 0
         FLQ:Filename = LOC:PathName & LOC:FileList[LOC:Pos1+1 : LOC:Pos2 - 1]
         ADD(FileListQueue)
         LOC:Pos1 = LOC:Pos2
       ELSE
         LOC:Pos2 = LEN(CLIP(LOC:FileList))
         FLQ:Filename = LOC:PathName & LOC:FileList[LOC:Pos1+1 : LOC:Pos2]
         ADD(FileListQueue)
         BREAK
       END
     END
   END
   !LOOP I# = 1 TO RECORDS(FileListQueue)
   !  GET(FileListQueue, I#)
   !  MESSAGE('File ' & i# & ' : ' & CLIP(FLQ:Filename))
   !END
 RETURN(LOC:ReturnString)
!END of ClarioNET
!------------------------------------------------------------------------------
#ENDAT
#!=============================================================================
#!
#EXTENSION (ClarioNETProcedureClient, 'ClarioNET (Client) Procedure Extension'),PROCEDURE,FIRST,SINGLE
#!
#BOXED(%ClarioNETVersion),AT(,0,,55)
#!    #IMAGE     (%ClarioNETVerLogo    ),AT(,10,50,40)
    #DISPLAY   (%ClarioNETVerCpnyName),AT(65,10)
    #DISPLAY   (%ClarioNETVerSlogan  ),AT(65,20)
    #DISPLAY   (%ClarioNETVerCpyRght ),AT(65,30)
#ENDBOXED
#ENABLE(%ClarioNETEnabled)
    #BOXED('') 
        #DISPLAY('ClarioNET Client Side (Procedure) Template')
    #ENDBOXED   
    #BOXED('') 
        #DISPLAY('This is currently a place holder.' )
        #DISPLAY('')
        #DISPLAY('Additions and Options to be added.')
    #ENDBOXED
#ENDENABLE   #! ClarioNETEnabled
#!
#!-KBE-09/09/00 (END)
#!
#!=============================================================================
#!

#!--------------------------- Prompt Groups ------------------------------
#!
#GROUP (%IndividualControlPrompts)
#SHEET
  #TAB ('&Display')
    #BOXED ('General')
      #PROMPT ('HIDE during ClarioNET session', CHECK), %HideControlDuringClarioNET,AT(10)
      #PROMPT ('UNHIDE during ClarioNET session', CHECK), %UNHideControlDuringClarioNET,AT(10)
      #DISPLAY('')
      #PROMPT ('DISABLE during ClarioNET session', CHECK), %DisableControlDuringClarioNET,AT(10)
      #PROMPT ('ENABLE during ClarioNET session', CHECK), %EnableControlDuringClarioNET,AT(10)
    #END
  #END
#END
