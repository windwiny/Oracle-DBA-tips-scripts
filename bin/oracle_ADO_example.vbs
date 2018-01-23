' +----------------------------------------------------------------------------+
' |                          Jeffrey M. Hunter                                 |
' |                      jhunter@idevelopment.info                             |
' |                         www.idevelopment.info                              |
' |----------------------------------------------------------------------------|
' |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
' |----------------------------------------------------------------------------|
' | FILE       : oracle_ADO_example.vbs                                        |
' | CLASS      : WINDOWS Shell Scripts                                         |
' | PURPOSE    : Visual Basic script that demonstrate the use of ADO.          |
' |                                                                            |
' | DSNLess    : In most cases, you will create and utilize data provider      |
' |              (DSN) as the mechanism that connects you to a particular type |
' |              of database (Oracle, SQL Server, Active Directory, Access,    |
' |              etc.). This is considered the simplest way to provide all     |
' |              connection information about a particular type of database.   |
' |              Creating a DSN:                                               |
' |                1. Open "Administrative Tools", and then click              |
' |                   "Data Source (ODBC)".                                    |
' |                2. On the "System DSN" tab in the "ODBC Data Source         |
' |                   Administrator" dialog box, click "Add".                  |
' |                3. In the "Create New Data Source" wizard, follow all       |
' |                   prompts to create a DSN for your particular database.    |
' |                   Please note that the steps will vary depending on the    |
' |                   type of database.                                        |
' |                                                                            |
' |              Although not considered good programming practice, I will be  |
' |              creating my connection objects using no DSN. This type of     |
' |              configuration is often called a "DSNLess ADO Connection". In  |
' |              this type of configuration, I can specify the database        |
' |              driver and other connection parameters (database name,        |
' |              user name, password, etc.) without creating a DSN entry.      |
' |                                                                            |
' |              Take note of the name of the driver (the Oracle driver) that  |
' |              you have installed. Use the steps in "Creating a DSN" to      |
' |              determine the actual name of the driver. From the "ODBC Data  |
' |              Source Administrator" dialog box, click the "Drivers" tab,    |
' |              then scroll down to the driver you want to use. For the       |
' |              examples in this document, I will be using                    |
' |              "Oracle in OraDb11g_home1".                                   |
' |                                                                            |
' | ABOUT ADO  : ADO (Active X Data Objects) is a set of objects that provide  |
' |              a mechanism to access information from ODBC-compliant data    |
' |              sources. ADO is part of the Universal Data Access (UDA)       |
' |              technology that provides access to information across an      |
' |              enterprise. Very much like its predecessor, Open Database     |
' |              Connectivity (ODBC), UDA provides a set of common interfaces  |
' |              for working with SQL databases. UDA, however, goes far beyond |
' |              simply database connectivity, allowing access to all types    |
' |              of information that may be part of an email service, LDAP, or |
' |              even a file system.                                           |
' |                                                                            |
' |              ADO is also known as ADO/OLE DB (OLE Database). ADO provides  |
' |              the scripting and application-level programming interface,    |
' |              while OLE DB provides the system-level programming interface. |
' |              While ADO is required when working with scripting languages,  |
' |              lower level (system-level) programming languages like C, and  |
' |              C++ can bypass ADO and work directly with OLE DB.             |
' |                                                                            |
' | TRACING    : Set the WSHTRACE Windows environment variable to the level    |
' |              (1-n) of tracing you would like to capture.                   |
' | USAGE      : cscript oracle_ADO_example.vbs  //NoLogo                      |
' | NOTE       : As with any code, ensure to test this script in a development |
' |              environment before attempting to run it in production.        |
' +----------------------------------------------------------------------------+

Option Explicit


' -----------------------------------------------------------------------------
'   EXPLICIT VARIABLE DECLARATION & STANDARD GLOBALS
' -----------------------------------------------------------------------------

Const g_SCRIPT_VERSION="1.1"
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
    
    RunADOExample1
    
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
' | RunADOExample1
' | ---------------------------------------------------------------------------
' | The examples in this function give in-depth documentation on the following:
' |     1. Cursors -    A database element that controls record navigation,
' |                     updateability of data, and the visibility of changes
' |                     made to the database by other users.
' |     2. Iteration -  Moving through a Resultset
' |     3. Formatted -  Using functions similar to printf() in C.
' |        Output
' //////////////////////////////////////////////////////////////////////////////

Sub RunADOExample1()

    Trace 1, ">  RunADOExample1"
    
    ' -------------------------------------------------------------------------
    ' Recordset.CursorLocation
    ' -------------------------------------------------------------------------
    ' The following three constants will be used to determine where the data
    ' structure that holds the results of any queries (the cursor engine) will
    ' be stored. Cursors can be stored either on the server or on the client.
    ' These constants will be used to set the cursor engine to be on the client
    ' or server by setting the "CursorLocation" property of any Recordset
    ' object. The default setting for CursorLocation is "adUseServer".
    ' 
    ' In general, it is better to store the cursor engine on the client (often
    ' called a local cursor) as this tends to improve performance since the data
    ' can be stored locally (where it will be used) and to place less strain on
    ' the database server. Local cursor services often will allow many features
    ' that driver-supplied cursors may not, so using this setting may provide an
    ' advantage with respect to features that will be enabled.
    ' 
    ' The default setting of "adUseServer" uses data-provider or driver-supplied
    ' cursors. These cursors are sometimes very flexible and allow for additional
    ' sensitivity to changes others make to the data source. However, some
    ' features of the Microsoft Cursor Service for OLE DB (such as disassociated
    ' Recordset objects) cannot be simulated with server-side cursors and these
    ' features will be unavailable with this setting.
    ' -------------------------------------------------------------------------
    Const adUseNone        = 1      ' Does not use cursor services. This constant
                                    ' is obsolete and appears solely For the sake
                                    ' of backward compatibility.
    Const adUseServer      = 2      ' Server cursor location (Default)
    Const adUseClient      = 3      ' Client (local) cursor location


    ' -------------------------------------------------------------------------
    ' Recordset.CursorType
    ' -------------------------------------------------------------------------    
    ' Allows you to browse a Recordset in different ways; some cursors allow
    ' you to move backward and forward in a Recordset, while other cursors
    ' limit you to moving forward only.
    ' 
    ' Note that if you set CursorLocation to "Client", you must set CursorType
    ' to "adOpenStatic (value=3)". This type supports scrolling forward and
    ' backward in the Record set but does not show changes made by other users.
    ' This is because the cursor is operating on data cached on the client
    ' machine rather than directly from the database server.
    ' 
    ' NOTE: If an unsupported value is set, then no error will result; the
    '       closest supported CursorType will be used instead.
    ' -------------------------------------------------------------------------    
    Const adOpenUnspecified     = -1    ' Does not specify the type of cursor.
    Const adOpenForwardOnly     = 0 	' (Default) Uses a forward-only cursor.
                                        ' Identical to a static cursor, except
                                        ' that you can only scroll forward
                                        ' through records. This improves 
                                        ' performance when you need to make 
                                        ' only one pass through a Recordset.
    Const adOpenKeyset          = 1     ' Uses a keyset cursor. Like a dynamic
                                        ' cursor, except that you can't see
                                        ' records that other users add,
                                        ' although records that other users
                                        ' delete are inaccessible from your
                                        ' Recordset. Data changes by other
                                        ' users are still visible.
    Const adOpenDynamic         = 2     ' Uses a dynamic cursor. Additions,
                                        ' changes, and deletions by other users
                                        ' are visible, and all types of
                                        ' movement through the Recordset are
                                        ' allowed, except for bookmarks, if
                                        ' the provider doesn't support them.
    Const adOpenStatic          = 3     ' Uses a static cursor, which is a static
                                        ' copy of a set of records that you can
                                        ' use to find data or generate reports.
                                        ' Additions, changes, or deletions by
                                        ' other users are not visible.


    ' -------------------------------------------------------------------------
    ' Recordset.LockType
    ' -------------------------------------------------------------------------    
    ' The following five constants will be used to determine how (and if) a 
    ' Recordset can be updated. Basically, it specifies the type of lock placed
    ' on records during editing. Recordsets can be set to read-only, or they
    ' can be configured to allow updates.
    ' 
    ' For most scripts, the LocalType property of the Recordset object can be
    ' set to "adLockOptimistic" (value=3). With this setting, the record being
    ' edited is not locked (that is, no restrictions are placed on another user
    ' accessing that record) until you call the "Update" method.
    ' -------------------------------------------------------------------------
    Const adLockUnspecified     = -1 	' Does not specify a type of lock. For
                                        ' clones, the clone is created with
                                        ' the same lock type as the original.
    Const adLockReadOnly        = 1     ' Indicates read-only records. You
                                        ' cannot alter the data.
    Const adLockPessimistic     = 2     ' Indicates pessimistic locking, record
                                        ' by record. The provider does what is
                                        ' necessary to ensure successful
                                        ' editing of the records, usually by
                                        ' locking records at the data source
                                        ' immediately after editing.
    Const adLockOptimistic      = 3     ' Indicates optimistic locking, record by
                                        ' record. The provider uses optimistic
                                        ' locking, locking records only when you
                                        ' call the Update method.
    Const adLockBatchOptimistic = 4     ' Indicates optimistic batch updates.
                                        ' Required For batch update mode.

    ' -------------------------------------------------------------------------
    ' Database Connection Properties
    ' -------------------------------------------------------------------------  
    Dim strDBUserID, strDBUserPassword, strTNSServiceName
    Dim strDriver, strConnectionString
                              
    strDBUserID = "SYSTEM"
    strDBUserPassword = "MANAGER"
    strTNSServiceName = "racdb.idevelopment.info"
    strDriver = "{Oracle in OraDb11g_home1}"
    strConnectionString = "Driver=" & strDriver & ";" & _
                          "DBQ=" & strTNSServiceName & ";" & _
                          "UID=" & strDBUserID & ";" & _
                          "PWD=" & strDBUserPassword
    ' The connection string when using a DSN named RACDB would be
    ' strConnectionString = "DSN=RACDB"

    Trace 2, "D: Connection String = " & strConnectionString
    
    ' -------------------------------------------------------------------------
    ' Create ADO Objects
    ' -------------------------------------------------------------------------
    Dim objADOConnection
    Dim objADORecordSet
    
    Set objADOConnection = CreateObject("ADODB.Connection")
    Set objADORecordSet  = CreateObject("ADODB.RecordSet")

    ' -------------------------------------------------------------------------
    ' Obtain ADO Connection Object
    ' -------------------------------------------------------------------------
    objADOConnection.Open(strConnectionString)

    ' -------------------------------------------------------------------------
    ' Prepare SQL Query
    ' -------------------------------------------------------------------------
    Dim i, strObjectType, strObjectCount, strSQLText
    strSQLText = "SELECT object_type, count(*) count " & _
                 "FROM user_objects " & _
                 "GROUP BY object_type "
                 
    Trace 2, "D: SQL Statement:"
    Trace 2, "D: " & strSQLText


    ' -------------------------------------------------------------------------
    ' Prepare Resultset Object
    ' -------------------------------------------------------------------------
    
    ' [METHOD 1]
    ' objADORecordSet.CursorLocation = adUseClient
    ' objADORecordSet.CursorType = adOpenStatic
    ' objADORecordSet.LockType = adLockOptimistic
    ' Set objADORecordSet = objADOConnection.Execute(strSQLText)
    
    ' [METHOD 2]
    ' objADORecordSet.Open (Source, ActiveConnection, CursorType, LockType, [Options])
    objADORecordSet.CursorLocation = adUseClient
    objADORecordSet.Open strSQLText, objADOConnection, adOpenStatic, adLockOptimistic


    ' -------------------------------------------------------------------------
    ' Print out Header
    ' -------------------------------------------------------------------------    
    WScript.Echo "Object Type               Object Count"
    WScript.Echo "------------------------- ------------"


    ' -------------------------------------------------------------------------
    ' Iterate through Resultset Object
    ' -------------------------------------------------------------------------
    
    Dim intPadding1, intPadding2
    Dim strDisplayObjectType, strDisplayObjectCount
    
    If Not objADORecordSet.EOF Then
        objADORecordSet.MoveFirst
    
        i = 0
        Do While Not (objADORecordSet.EOF Or objADORecordSet.bof)
            
            strObjectType  = objADORecordSet.Fields.Item("OBJECT_TYPE")
            strObjectCount = objADORecordSet.Fields.Item("COUNT")
            
            intPadding1 = 25 - Len(strObjectType)
            intPadding2 = 12 - Len(strObjectCount)
            
            strDisplayObjectType = strObjectType & Space(intPadding1)
            strDisplayObjectCount = strObjectCount & Space(intPadding2)
            
            WScript.Echo strDisplayObjectType & " " & strDisplayObjectCount
            i = i + 1
            objADORecordSet.MoveNext
        Loop

    End If


    ' -------------------------------------------------------------------------
    ' Close and remove all ADO objects
    ' -------------------------------------------------------------------------
    objADORecordSet.Close
    Set objADORecordSet = Nothing
    
    objADOConnection.Close
    Set objADOConnection = Nothing


    ' -------------------------------------------------------------------------
    ' Return from Function
    ' -------------------------------------------------------------------------    
    Trace 1, "<  RunADOExample1"
    
End Sub
