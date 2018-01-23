' +----------------------------------------------------------------------------+
' |                          Jeffrey M. Hunter                                 |
' |                      jhunter@idevelopment.info                             |
' |                         www.idevelopment.info                              |
' |----------------------------------------------------------------------------|
' |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
' |----------------------------------------------------------------------------|
' | FILE       : Template.vbs                                                  |
' | CLASS      : Templates                                                     |
' | PURPOSE    : Used as a general purpose VBS template script.                |
' | PARAMETERS : p1          Description of parameter 1.                       |
' |              p2          Description of parameter 2.                       |
' | TRACING    : Set the WSHTRACE Windows environment variable to the level    |
' |              (1-n) of tracing you would like to capture.                   |
' | USAGE      :                                                               |
' |                                                                            |
' |              cscript Template.vbs "p1" "p2" //NoLogo                       |
' |                                                                            |
' | NOTE       : As with any code, ensure to test this script in a development |
' |              environment before attempting to run it in production.        |
' +----------------------------------------------------------------------------+

Option Explicit


' -----------------------------------------------------------------------------
'   EXPLICIT VARIABLE DECLARATION & STANDARD GLOBALS
' -----------------------------------------------------------------------------

Const g_SCRIPT_VERSION="1.0"
Dim   g_strScriptPath, g_strScriptName, g_strScriptFolder, g_strScriptNameNoExt
Dim   g_bytTraceLevel
Dim   g_objShell, g_objFSO
Dim   strBannerText, strArgValue, i


' -----------------------------------------------------------------------------
'   SET STANDARD GLOBALS & CREATE GLOBAL OBJECTS
' -----------------------------------------------------------------------------

g_strScriptPath = WScript.ScriptFullName
g_strScriptName = WScript.ScriptName
g_strScriptFolder = Left(g_strScriptPath, Len(g_strScriptPath) - Len(g_strScriptName))

i = InStr(g_strScriptName, ".")
If i <> 0 Then
    g_strScriptNameNoExt = Left(g_strScriptName, i - 1)
Else
    g_strScriptNameNoExt = g_strScriptName
End If

Set g_objShell = CreateObject("WScript.Shell")
Set g_objFSO   = CreateObject("Scripting.FileSystemObject")


' -----------------------------------------------------------------------------
'   SHOW SIGNON BANNER
' -----------------------------------------------------------------------------

strBannerText = VbCrLf
strBannerText = strBannerText & g_strScriptName
strBannerText = strBannerText & " - Version " & g_SCRIPT_VERSION & VbCrLf
strBannerText = strBannerText & "Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved."
strBannerText = strBannerText & VbCrLf
WScript.Echo strBannerText


' -----------------------------------------------------------------------------
'   SETUP TRACING CONTROL FROM THE "WSHTRACE" WINDOWS ENVIRONMENT VARIABLE
' -----------------------------------------------------------------------------

i = g_objShell.Environment("Process").Item("WSHTRACE")
If IsNumeric(i) Then
    g_bytTraceLevel = CInt(i)
    WScript.Echo VbCrLf & "DEBUGGING TURNED ON AT LEVEL: " & g_bytTraceLevel & VbCrLf
Else
    g_bytTraceLevel = 0
End If


' -----------------------------------------------------------------------------
'   CHECK IF USER IS ASKING FOR HELP BY CHECKING THE FIRST PARAMETER TO THIS
'   SCRIPT FOR THE FOLLOWING TOKENS:
'       -help    -?    /help    /?
' -----------------------------------------------------------------------------

If WScript.Arguments.Count > 0 Then
    strArgValue = LCase(WScript.Arguments(0))
    If (strArgValue = "-help") Or (strArgValue = "-?") Or _
       (strArgValue = "/help") Or (strArgValue = "/?")    _
    Then
            ShowHelpMessage
            WScript.Quit(1)
    End If
End If


' -----------------------------------------------------------------------------
'   CALL MAIN FUNCTION
' -----------------------------------------------------------------------------

i = Main


' -----------------------------------------------------------------------------
'   CLEAN UP AND EXIT SCRIPT
' -----------------------------------------------------------------------------

Set g_objFSO = Nothing
Set g_objShell = Nothing

Trace 2, "D: Exit Code = " & i
WScript.Quit(i)


' ------------------------------------------------------------------------------
' --------------------------- <  END OF SCRIPT  > ------------------------------
' ------------------------------------------------------------------------------


' //////////////////////////////////////////////////////////////////////////////
' | Main
' | 
' | Main function used to enclose the primary script logic.
' | 
' | Returns
' |     Exit code from primary script logic.
' //////////////////////////////////////////////////////////////////////////////

Function Main

    Trace 1, ">  Main"
    
    Dim g_strParameter1, g_strParameter2
    
    If (VerifyScriptArguments) Then
        Trace 2, "D: Setting Script Global Variables"
        SetScriptArguments g_strParameter1, g_strParameter2
    Else
        ShowHelpMessage
        Main = 1
        Trace 1, "<  Main (1)"
        Exit Function
    End if
    
    PrintStandardGlobalVariables
    printScriptArguments g_strParameter1, g_strParameter2
    
    Main = 0
    
    Trace 1, "<  Main (0)"
        
End Function


' //////////////////////////////////////////////////////////////////////////////
' | ShowHelpMessage
' | 
' | Display help message for this script.
' //////////////////////////////////////////////////////////////////////////////

Sub ShowHelpMessage

    Dim strMessage
    
    Trace 1, ">  ShowHelpMessage"

    strMessage = "Usage: cscript "
    strMessage = strMessage & g_strScriptName
    strMessage = strMessage & " ""p1"" ""p2"" "
    strMessage = strMessage & " //NoLogo"
    WScript.Echo strMessage

    Trace 1, "<  ShowHelpMessage"
    
End Sub


' //////////////////////////////////////////////////////////////////////////////
' | Trace
' | 
' | Debug script tracing by using the g_bytTraceLevel and WSHTRACE environment 
' | variable
' |
' | Parameters
' |     bytLevel    Trace level. Used to control if trace information will be
' |                 printed. Only display if <= WSHTRACE
' |                 nLevel  Tracing Information
' |                 ------  ----------------------------------------------------
' |                   1     Includes sub routine "enter" and "exit" data. Also
' |                         includes sub routine arguments (A[n]:) as well as 
' |                         critical errors (E:).
' |                   2     Includes all nLevel 1 plus debugging and warning
' |                         tracing information.
' |     strText     Text to display
' | 
' | Notes
' |     The following tokens may be used at the beginning of each Trace
' |     line to make reading trace information easier to read:
' |
' |     >  "Sub Routine"    Use at the begining of a sub routine to indicate 
' |                         entering the sub routine code.
' |     <  "Sub Routine"    Use when exiting sub routine code.
' |     A[n]:               Used when tracing sub routine arguments.
' |     D:                  Used to print debugging text to the trace file.
' |     V:                  Used to print out a variable name to the trace file.
' |     W:                  Used to indicate a warning message to the trace file.
' |     E:                  Used to indicate a critical error to the trace file.
' //////////////////////////////////////////////////////////////////////////////

Sub Trace (bytLevel, strText)

    If (g_bytTraceLevel >= bytLevel) Then
        WScript.Echo strText
    End If

End Sub


' //////////////////////////////////////////////////////////////////////////////
' | VerifyScriptArguments
' | 
' | Verify correct number of arguments were passed into this script.
' |
' | Returns
' |     True if the correct number of parameters were passed to this script
' |     False otherwise
' //////////////////////////////////////////////////////////////////////////////

Function VerifyScriptArguments

    Trace 1, ">  VerifyScriptArguments"

    If WScript.Arguments.Length <> 2 Then
        VerifyScriptArguments = 0        ' False
    Else
        VerifyScriptArguments = -1       ' True
    End If

    Trace 2, "D: Number of Arguments = " & WScript.Arguments.Length

    Trace 1, "<  VerifyScriptArguments"
    
End Function


' //////////////////////////////////////////////////////////////////////////////
' | SetScriptArguments
' | 
' | Set arguments that were passed into this script.
' //////////////////////////////////////////////////////////////////////////////

Sub SetScriptArguments (ByRef strParam1, ByRef strParam2)

    Trace 1, ">  SetScriptArguments"

    strParam1 = WScript.Arguments(0)
    strParam2 = WScript.Arguments(1)

    Trace 2, "V: strParam1        = " & strParam1
    Trace 2, "V: strParam2        = " & strParam2

    Trace 1, "<  SetScriptArguments"
    
End Sub


' //////////////////////////////////////////////////////////////////////////////
' | printScriptArguments
' | 
' | Display all script global variables.
' //////////////////////////////////////////////////////////////////////////////

Sub printScriptArguments (p1, p2)

    Trace 1, ">  printScriptArguments"

    WScript.Echo ""
    WScript.Echo "======================="
    WScript.Echo "Script Global Variables"
    WScript.Echo "======================="
    WScript.Echo "  Parameter 1           : " & p1
    WScript.Echo "  Parameter 2           : " & p2
    WScript.Echo VbCrLf

    Trace 1, "<  printScriptArguments"
    
End Sub


' //////////////////////////////////////////////////////////////////////////////
' | PrintStandardGlobalVariables
' | 
' | Display all standard global variables.
' //////////////////////////////////////////////////////////////////////////////

Sub PrintStandardGlobalVariables

    Trace 1, ">  PrintStandardGlobalVariables"

    WScript.Echo ""
    WScript.Echo "========================="
    WScript.Echo "Standard Global Variables"
    WScript.Echo "========================="
    WScript.Echo "  g_strScriptPath       : " & g_strScriptPath
    WScript.Echo "  g_strScriptName       : " & g_strScriptName
    WScript.Echo "  g_strScriptNameNoExt  : " & g_strScriptNameNoExt
    WScript.Echo "  g_strScriptFolder     : " & g_strScriptFolder
    WScript.Echo "  g_SCRIPT_VERSION      : " & g_SCRIPT_VERSION
    WScript.Echo "  g_bytTraceLevel       : " & g_bytTraceLevel
    WScript.Echo VbCrLf

    Trace 1, "<  PrintStandardGlobalVariables"
    
End Sub
