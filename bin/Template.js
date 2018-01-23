/**
 * +----------------------------------------------------------------------------+
 * |                          Jeffrey M. Hunter                                 |
 * |                      jhunter@idevelopment.info                             |
 * |                         www.idevelopment.info                              |
 * |----------------------------------------------------------------------------|
 * |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
 * |----------------------------------------------------------------------------|
 * | FILE       : Template.js                                                   |
 * | CLASS      : Templates                                                     |
 * | PURPOSE    : Used as a general purpose JScript template script.            |
 * | PARAMETERS : p1          Description of parameter 1.                       |
 * |              p2          Description of parameter 2.                       |
 * | TRACING    : Set the WSHTRACE Windows environment variable to the level    |
 * |              (1-n) of tracing you would like to capture.                   |
 * | USAGE      :                                                               |
 * |                                                                            |
 * |               cscript Template.js "p1" "p2" //NoLogo                       |
 * |                                                                            |
 * | NOTE       : As with any code, ensure to test this script in a development |
 * |              environment before attempting to run it in production.        |
 * +----------------------------------------------------------------------------+
 **/

// -----------------------------------------------------------------------------
//   DECLARATION OF STANDARD GLOBALS
// -----------------------------------------------------------------------------

var g_SCRIPT_VERSION="1.0";
var g_strScriptPath, g_strScriptName, g_strScriptFolder, g_strScriptNameNoExt;
var g_bytTraceLevel;
var g_objShell, g_objFSO;
var strBannerText, strArgValue, i;


// -----------------------------------------------------------------------------
//   DECLARATION OF SCRIPT GLOBALS
// -----------------------------------------------------------------------------

var g_strParameter1;
var g_strParameter2;


// -----------------------------------------------------------------------------
//   SET STANDARD GLOBALS & CREATE GLOBAL OBJECTS
// -----------------------------------------------------------------------------

g_strScriptPath = WScript.ScriptFullName;
g_strScriptName = WScript.ScriptName;
g_strScriptFolder = g_strScriptPath.substring(0, g_strScriptPath.length - g_strScriptName.length);
i = g_strScriptName.indexOf('.');

if (i >= 0) {
    g_strScriptNameNoExt = g_strScriptName.substring(0, i);
} else {
    g_strScriptNameNoExt = g_strScriptName;
}

g_objShell = new ActiveXObject("WScript.Shell");
g_objFSO   = new ActiveXObject("Scripting.FileSystemObject");


// -----------------------------------------------------------------------------
//   SHOW SIGNON BANNER
// -----------------------------------------------------------------------------

strBannerText =
        "\n" +
        g_strScriptName + " - Version " + g_SCRIPT_VERSION + "\n" +
        "Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.\n";
WScript.Echo(strBannerText);


// -----------------------------------------------------------------------------
//   SETUP TRACING CONTROL FROM THE "WSHTRACE" WINDOWS ENVIRONMENT VARIABLE
// -----------------------------------------------------------------------------

i = g_objShell.Environment("Process").Item("WSHTRACE");

if (isNumeric(i)) {
    g_bytTraceLevel = parseInt(i);
    WScript.Echo("\n" + "DEBUGGING TURNED ON AT LEVEL: " + g_bytTraceLevel + "\n");
} else {
    g_bytTraceLevel = 0;
}


// -----------------------------------------------------------------------------
//   CHECK IF USER IS ASKING FOR HELP BY CHECKING THE FIRST PARAMETER TO THIS
//   SCRIPT FOR THE FOLLOWING TOKENS:
//       -help    -?    /help    /?
// -----------------------------------------------------------------------------

if (WScript.Arguments.Count() > 0) {
    
    strArgValue = WScript.Arguments(0).toLowerCase();
    
    if ( (strArgValue == "-help") 
         ||
         (strArgValue == "-?")
         ||
         (strArgValue == "/help")
         ||
         (strArgValue == "/?")) {
        
        showHelpMessage();
        WScript.Quit(1);
        
    }
    
}


// -----------------------------------------------------------------------------
//   CALL MAIN FUNCTION
// -----------------------------------------------------------------------------

i = main();


// -----------------------------------------------------------------------------
//   CLEAN UP AND EXIT SCRIPT
// -----------------------------------------------------------------------------

g_objFSO = null;
g_objShell = null;

trace(2, "D: Exit Code = " + i);
WScript.Quit(i);



// ------------------------------------------------------------------------------
// --------------------------- <  END OF SCRIPT  > ------------------------------
// ------------------------------------------------------------------------------



/**
 * -----------------------------------------------------------------------------
 * main
 *
 * Main function used to enclose the primary script logic.
 *
 * Returns
 *      Exit code from primary script logic.
 * -----------------------------------------------------------------------------
 **/

function main() {

    trace(1, ">  Main");

    if (verifyScriptArguments()) {
        trace(2, "D: Setting Script Global Variables");
        setScriptArguments();
    } else {
        showHelpMessage();
        trace(1, "<  Main (1)");
        return(1);
    }

    printStandardGlobalVariables();
    printScriptArguments(g_strParameter1, g_strParameter2);

    trace(1, "<  main(0)");
    
    return(0);
        
}


/**
 * -----------------------------------------------------------------------------
 * showHelpMessage
 *
 * Display help message for this script.
 * -----------------------------------------------------------------------------
 **/

function showHelpMessage() {

    var strMessage;
    
    trace(1, ">  showHelpMessage");

    strMessage =
            "Usage: cscript " + g_strScriptName +
            " \"p1\" \"p2\" //NoLogo";
    WScript.Echo(strMessage);

    trace(1, "<  showHelpMessage");

}


/**
 * -----------------------------------------------------------------------------
 * trace
 * 
 * Debug script tracing by using the g_bytTraceLevel and WSHTRACE environment 
 * variable
 *
 * Parameters
 *     bytLevel    Trace level. Used to control if trace information will be
 *                 printed. Only display if <= WSHTRACE
 *                 nLevel  Tracing Information
 *                 ------  ----------------------------------------------------
 *                   1     Includes sub routine "enter" and "exit" data. Also
 *                         includes sub routine arguments (A[n]:) as well as 
 *                         critical errors (E:).
 *                   2     Includes all nLevel 1 plus debugging and warning
 *                         tracing information.
 *     strText     Text to display
 * 
 * Notes
 *     The following tokens may be used at the beginning of each Trace
 *     line to make reading trace information easier to read:
 *
 *     >  "Sub Routine"    Use at the begining of a sub routine to indicate 
 *                         entering the sub routine code.
 *     <  "Sub Routine"    Use when exiting sub routine code.
 *     A[n]:               Used when tracing sub routine arguments.
 *     D:                  Used to print debugging text to the trace file.
 *     V:                  Used to print out a variable name to the trace file.
 *     W:                  Used to indicate a warning message to the trace file.
 *     E:                  Used to indicate a critical error to the trace file.
 * -----------------------------------------------------------------------------
 **/

function trace(bytLevel, strText) {

    if (g_bytTraceLevel >= bytLevel) {
        WScript.Echo(strText);
    }

}


/**
 * -----------------------------------------------------------------------------
 * | VerifyScriptArguments
 * | 
 * | Verify correct number of arguments were passed into this script.
 * |
 * | Returns
 * |     True if the correct number of parameters were passed to this script
 * |     False otherwise
 * -----------------------------------------------------------------------------
 **/
 
function verifyScriptArguments() {

    trace(1, ">  verifyScriptArguments");

    retValue = 0; // Assume FALSE

    if (WScript.Arguments.Length != 2) {
        retValue = 0;        // False
    } else {
        retValue = 1;        // True
    }

    trace(2, "D: Number of Arguments = " + WScript.Arguments.Length);

    trace(1, "<  verifyScriptArguments");
    
    return(retValue);
}


/**
 * -----------------------------------------------------------------------------
 * | setScriptArguments
 * | 
 * | Set all command-line arguments that were passed into this script to global
 * | variables. Note that this function relies on all variables that are to be
 * | set have to be declared globally as JScript does not support variable pass
 * | by reference. (VBScript does support pass by reference by using the 
 * | 'ByRef' keyword when passing arguments.) JScript is only able to 
 * | change values if they contain Object references because JScript passes all
 * | variables by value, in accordance with the ECMA-262 specification.
 * -----------------------------------------------------------------------------
 **/

function setScriptArguments() {

    trace(1, ">  setScriptArguments");
    
    g_strParameter1 = WScript.Arguments(0);
    g_strParameter2 = WScript.Arguments(1);

    trace(2, "V: g_strParameter1   = " + g_strParameter1);
    trace(2, "V: g_strParameter2   = " + g_strParameter2);
    
    trace(1, "<  setScriptArguments");
    
}


/**
 * -----------------------------------------------------------------------------
 * printScriptArguments
 *
 * Display all script global variables.
 * -----------------------------------------------------------------------------
 **/

function printScriptArguments(p1, p2) {

    trace(1, ">  printScriptArguments");

    WScript.Echo();
    WScript.Echo("=======================");
    WScript.Echo("Script Global Variables");
    WScript.Echo("=======================");
    WScript.Echo("  Parameter 1           : " + p1);
    WScript.Echo("  Parameter 2           : " + p2);
    WScript.Echo("\n");

    trace(1, "<  printScriptArguments");

}


/**
 * -----------------------------------------------------------------------------
 * printStandardGlobalVariables
 *
 * Display all standard global variables.
 * -----------------------------------------------------------------------------
 **/

function printStandardGlobalVariables() {

    trace(1, ">  printStandardGlobalVariables");

    WScript.Echo();
    WScript.Echo("=========================");
    WScript.Echo("Standard Global Variables");
    WScript.Echo("=========================");
    WScript.Echo("  g_strScriptPath       : " + g_strScriptPath);
    WScript.Echo("  g_strScriptName       : " + g_strScriptName);
    WScript.Echo("  g_strScriptNameNoExt  : " + g_strScriptNameNoExt);
    WScript.Echo("  g_strScriptFolder     : " + g_strScriptFolder);
    WScript.Echo("  g_SCRIPT_VERSION      : " + g_SCRIPT_VERSION);
    WScript.Echo("  g_bytTraceLevel       : " + g_bytTraceLevel);
    WScript.Echo("\n");

    trace(1, "<  printStandardGlobalVariables");
    
}


/**
 * -----------------------------------------------------------------------------
 * isNumeric
 *
 * Determines if a value is numeric. This is equivalent to the VBScript
 * IsNumeric function.
 * -----------------------------------------------------------------------------
 **/

function isNumeric(s) {

    trace(1, ">  isNumeric");
    
    if (s == null) {
        return false;
    }
    
    if (s.length == 0) {
        return false;
    }
    
    for (var i=0; i<s.length; ++i) {
        if ("0123456789".indexOf(s.charAt(i)) < 0) {
            return false;
        }
    }
    
    trace(1, "<  isNumeric");
    
    return true;

}


/**
 * -----------------------------------------------------------------------------
 * isAlpha
 *
 * Determines if a value contains only alphabetic (no number) characters.
 * -----------------------------------------------------------------------------
 **/

function isAlpha(s) {

    trace(1, ">  isAlpha");
    
    if (s == null) {
        return false;
    }
    
    if (s.length == 0) {
        return false;
    }
    
    for(var i=0; i<s.length; ++i) {
        if("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".indexOf(s.charAt(i)) < 0) {
            return false;
        }
    }
    
    trace(1, "<  isAlpha");
        
    return true;
	
}
