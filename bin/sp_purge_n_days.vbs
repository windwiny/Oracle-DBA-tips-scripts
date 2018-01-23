' +----------------------------------------------------------------------------+
' |                          Jeffrey M. Hunter                                 |
' |                      jhunter@idevelopment.info                             |
' |                         www.idevelopment.info                              |
' |----------------------------------------------------------------------------|
' |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
' |----------------------------------------------------------------------------|
' | FILE       : sp_purge_n_days.vbs                                           |
' | CLASS      : WINDOWS Shell Scripts                                         |
' | PURPOSE    : Used to purge expired / obsolete Statspack records from the   |
' |              database.                                                     |
' |                                                                            |
' |              Note that this script makes use of the SQL*Plus executable    |
' |              and thus requires an Oracle client install and TNS            |
' |              configuration.                                                |
' |                                                                            |
' |              Also note that this SHELL script will make use of a text SQL  |
' |              script to perform the actual delete of all obsolete           |
' |              Statspack records. The SQL script is located at               |
' |              ../sql/sp_purge_n_days.sql                                    |
' |                                                                            |
' | PARAMETERS : db_username        Database username for the Statspack schema |
' |                                 owner. This username is named PERFSTAT by  |
' |                                 convention.                                |
' |              db_password        Database password for the Statspack schema |
' |                                 owner.                                     |
' |              db_connect_string  TNS connect string to the target database. |
' |              days_to_purge      Number of days this script will use when   |
' |                                 removing obsolete Statspack records. Any   |
' |                                 records with a timestamp older then "this" |
' |                                 number of days will be deleted from the    |
' |                                 database.                                  |
' | TRACING    : Set the WSHTRACE Windows environment variable to the level    |
' |              (1-n) of tracing you would like to capture.                   |
' | USAGE      : cscript Template.vbs days_to_purge //NoLogo                   |
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
' | Main function used to enclose the primary script logic.
' | 
' | Returns
' |     Exit code from primary script logic.
' //////////////////////////////////////////////////////////////////////////////

Function Main

    Trace 1, ">  Main"
    
    Dim strStatsUserID, strStatsUserPassword, strOracleConnectString, intDaysToPurge
        
    If (VerifyScriptArguments) Then
        Trace 2, "D: Setting Script Variables"
        SetScriptArguments strStatsUserID, strStatsUserPassword, strOracleConnectString, intDaysToPurge
    Else
        ShowHelpMessage
        Main = 1
        Trace 1, "<  Main (1)"
        Exit Function
    End if
    
    ' PrintStandardGlobalVariables
    
    RunSpPurge strStatsUserID, strStatsUserPassword, strOracleConnectString, intDaysToPurge
    
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
    strMessage = strMessage & " ""db_username"" ""db_password"" ""db_connect_string"" ""days_to_purge"" "
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

    If WScript.Arguments.Length <> 4 Then
        Trace 2, "D: Invalid number of arguments"
        VerifyScriptArguments = 0        ' False
    Else
        Trace 2, "D: Correct number of arguments"
        VerifyScriptArguments = -1       ' True
    End If

    Trace 2, "D: Number of Arguments = " & WScript.Arguments.Length

    If VerifyScriptArguments Then

        If IsNumeric(WScript.Arguments(3)) Then
            Trace 2, "D: Argument(3) is Numeric"
            VerifyScriptArguments = -1       ' True
        Else
            Trace 2, "D: Argument(3) is NOT Numeric"
            VerifyScriptArguments = 0        ' False
        End If
        
    End If

    Trace 1, "<  VerifyScriptArguments"
    
End Function


' //////////////////////////////////////////////////////////////////////////////
' | SetScriptArguments
' | 
' | Set arguments that were passed into this script.
' //////////////////////////////////////////////////////////////////////////////

Sub SetScriptArguments (ByRef strUser, ByRef strPassword, ByRef strConnectString, ByRef strDaysToPurge)

    Trace 1, ">  SetScriptArguments"

    strUser              = WScript.Arguments(0)
    strPassword          = WScript.Arguments(1)
    strConnectString     = WScript.Arguments(2)
    strDaysToPurge       = CInt(WScript.Arguments(3))

    Trace 2, "V: strUser          = " & strUser
    Trace 2, "V: strPassword      = " & strPassword
    Trace 2, "V: strConnectString = " & strConnectString
    Trace 2, "V: strDaysToPurge   = " & strDaysToPurge

    Trace 1, "<  SetScriptArguments"
    
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


' //////////////////////////////////////////////////////////////////////////////
' | RunSpPurge
' | 
' | Run the SQL Script using SQL*Plus given the passed in parameters
' //////////////////////////////////////////////////////////////////////////////

Sub RunSpPurge(strUser, strPassword, strConnectString, intDaysToPurge)

    Trace 1, ">  RunSpPurge"
    
    Dim errRetValue, strSQLText

    strSQLText = "sqlplus -s """
    strSQLText = strSQLText & strUser & "/" & strPassword & "@" & strConnectString & " as sysdba"" "
    strSQLText = strSQLText & " @..\sql\sp_purge_n_days.sql " & intDaysToPurge

    Trace 2, "D: " & strSQLText

    WScript.Echo "Logging into SQL*Plus: " & strUser & "/xxxx@" & strConnectString & " for " & intDaysToPurge & " days."
    WScript.Echo "Please wait..."
    errRetValue = g_objShell.Run(strSQLText, 0, True)
    WScript.Echo "Exited SQL*Plus with code (" & errRetValue & ")."
        
    Trace 2, "D: sErrorReturned = " & errRetValue

    Trace 1, "<  RunSpPurge"
    
End Sub
