// ********************************************************************************************************************************************************************************
//  Multi-Language Support Script
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  This script handles the language support for all emotes and dialog menus.  It is designed consolidate emote and dialog menus in a central script.  The script upon a link 
//  message request, will handle looking up at run time, the appropriate text and buttons for the request and handle all communication, time outs and other overhead  for the menu.
//  Multiple language template files can be used and if supported by your application, can be dynamically switched.  
//  
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  License
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  This script is released under the MIT license.  Full details are at the end of this script
//
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Setup and Usage Information:
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//  At the heart of the system is the language notecard.  This notecard should be named "Language-EN" where the last two letters is the standard two letter language code.  The 
//  language notecard contains templates for all emotes or menus for your application.  Each row of the notecard defines an individual emote or menu. Below is a summary chart
//  of the different notecard row formats:
//
//     Language Notecard Format                                  sParam Data Format                          Request Type
//     ------------------------------------------------------    ----------------------------------------    -------------------------------------------------------------------
//     xxyyy|0|<volume>       |<msg>                             <CSV: Msg Sub Params>                       Emote Request
//     xxyyy|1|<return msg ID>|<msg>|<value>|<button>            <CSV: Msg Sub Params>|<CSV: Return Data>    Menu-Buttons Request (All buttons go to same link msg)
//     xxyyy|2|0              |<msg>|<return msg ID>|<button>    <CSV: Msg Sub Params>|<CSV: Return Data>    Menu-Buttons Request (Each button triggers different link msg) 
//     xxyyy|3|<return msg ID>|<msg>                             <CSV: Msg Sub Params>|<CSV: Button Keys>    Menu-Names Request
//     xxxyy|4|<return msg ID>|<msg>                             <CSV: Msg Sub Params>|<CSV: Return Data>    Menu-TextBox Request
//
//     xxyyy|7|<return msg ID>|<msg>|<value>|<button>            <CSV Msg Sub Params>|<CSV: Return Data>     Orgasm Menu Request: Dialog to Female
//     xxyyy|8|<return msg ID>|<msg>|<value>|<button>            <CSV Msg Sub Params>|<CSV: Return Data>     Orgasm Menu Request: Dialog to Male, timeout fallback to female
//     xxyyy|9|<return msg ID>|<msg>|<value>|<button>            <CSV Msg Sub Params>|<CSV: Return Data>     Orgasm Menu Request: Dialog to operator, timeout fallback to female
//
//  Language Notecard Details   
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  The general format is ID|type|volume/return msg id|message|additional parameters.  
//
//  ID
//  ---------------------------------------------------------------------------
//  The first item in the format is the ID number.  The ID number is in an xxyyy format where the xx is a two digit grouping number.  The grouping number is at the user's 
//  descretion.  One possibility is to assign an individual script a number for all of its emotes and menus. In multi script objects, this is a way of organizing them so
//  that script changes in one script doesn't require renumbering the emote/menus from other scripts.  The yyy portion of the ID is a squential number starting from 1 within
//  the xx block.  The full number is used when requesting the emote/menu.  
//
//  Important Note: The xx portion should fall within the range of 10 to 99.  Do not use single digit numbers! Similarly the yyy should always be three digits and include leading
//  zeros.  
//
//  Type
//  ---------------------------------------------------------------------------
//  The Type parameter determnes how the script responds to requests.  It indicates if the row is an emote or a menu, and if a menu, what kind of menu.  Types 0-4 are predefinied
//  but this script can be modified to provide custom handling of other user definited types. The predefined types will be discussed below.
//
//  Volume/Return Message ID
//  ---------------------------------------------------------------------------
//  The Volume/Return Message ID parameter use varies depending on the Type.  For emotes it is used to determine which LSL function is used to play the emote.  The volumes are:
//
//      Volume    Function used     
//      ------    ------------------ 
//        1       llOwnerSay            
//        2       llWhisper             
//        3       llSay                  
//        4       llShout               
//        5       llInstantMessage      
//
//  For menu requests, the parameter is used to designate a Return Message ID (llLinkMessage number) that this script will send back once the user has made a menu selection.  
//
//  Message
//  ---------------------------------------------------------------------------
//  The message is the emote or menu text. The script can do text substituions based upon parameters passed in the calling link message sParam. For a list of substituions, see the
//  StringSubstitutions function.  
//
//  Type 0 - Emote
//  ---------------------------------------------------------------------------
//  Emote requests play an emote.  The sParam in the calling link message is a CSV of string substitution parameters.
//
//  Type 1 - Button Menu (All responses go to the same Return Message ID)
//  ---------------------------------------------------------------------------
//  Type 1 menus have a series of value|button pairs as additional parameters in the notecard row.  Once the user makes a selection, the script will respond with a link mesaage
//  using the Return Message ID along with the value selected as the sParam.  When requesting a Type 1 menu, the callling link message can have an optional set of parameters that 
//  is returned in the sParam when after the user makes their selection.  
//
//  Type 2 - Button Menu (Each button has a separate Return Message ID)
//  ---------------------------------------------------------------------------
//  Type 2 menus have a series of value|button pairs as additional parameters in the notecard row.  The Return Message ID is 0 initially, but once the user makes a selection, the
//  script will respond with a link message using the button's value as the Return Message ID. When requesting a Type 2 menu, the callling link message can have an optional set of 
//  parameters that is returned in the sParam when after the user makes their selection.  
//
//  Type 3 - Name Button Menu
//  ---------------------------------------------------------------------------
//  Type 3 menus do not have additional parameters in the notecard row.  When requesting a type 3 menu, the sParam in the calling link message must include after any string 
//  substitution parameters, a csv list of keys for the names to be used as buttons.  
//
//  Type 4 - Textbox
//  ---------------------------------------------------------------------------
//  Type 4 menus do not have additional parameters in the notecard row. Once the user has responded with the text, the script will send a response link message using the Return 
//  Message ID and the user's response will be in the sParam. When requesting a Type 4 menu, the callling link message can have an optional set of parameters that is appended in the 
//  sParam when after the user makes their selection.  
//
//     Note: For most calls to 90xxyyy, the sParam is optional. The only exception is for Type 4 Name Button menus. The second sParam CSV is mandatory, since it is the list of 
//           keys used to generate the button names.  The kParam should be the person to received the emote or dialog menu.  However, in the case of NULL_KEY or of an invalid 
//           key, the script will default to sending to the object's owner.  For emotes such as llSay, the kParam is ignored.
//
//     Note: Info only dialog boxes, use a <return msg ID> of 0.
//
//     Note: For dialog menus, this script does not handle menu timeout notifications to the user.  The calling script is responsible for providing any warnings that the menu has 
//           timed out.  Currently this script will time out menus in 60 seconds. 
//  
//  Type 5 - Website Menu
//  ---------------------------------------------------------------------------
//  Type 5 menus have an additoina parameter in the notecard row for the URL.
//  
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Technical Information:
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//  Main Queue
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  This queue is used to store the intial requests for emotes or menus for processing. Each request is processed in order received and when processing the request, it will look
//  up the correct language string, then if it is an emote, will play the emote, or if it is a menu request, will add it to the Menu queue for further procesing.
//
//  Format (implemented as a strided list):   
//
//      Element 0 = Emote ID    Element 1 = Send To Key    Element 2 = Optional <CSV: Msg Sub Params>|<CSV: Extra Data> 
// 
//  Menu Queue
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  This queue is a more specialized queue of in progress menu requests.
//
//  Format (implmented as a set of lists):
//
//      Menu Queue Element   Type  Notes          
//      -------------------  ----  ------------------------------------------------------------------------------------------------------------------------------------------------
//      Channel              int
//      Channel Handle       int
//      Menu ID              int   Store to be able to know which timeout message to call, menus should be paired with an approprate timeout message x, x+1
//      Menu Type            int   Used for menu specific logic
//      Menu Time            int   Unix time, used to time out the menu)
//      Return Msg ID        int
//      Buttons              str   CSV of value, button text -or- CSV of key, button text
//      Male Key             key
//      Paramenters          str   Stores parameters that need to be passed along with the Return Message
//
//      Button Menu (Shared Return ID) Parameters      (1): none
//      Button Menu (Indivudual Return ID) Parameters  (2): none
//      Key Menu Parameters                            (3): none
//      TextBox Menu Parameters                        (4): none
//
//
//  Button Queue
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  This queue is used for name menu requests to convert the UUIDs to display names (truncated to fit a dialog button)
//
//  Format (implmented as a set of lists):
//
//      Menu Queue Element   Type  Notes          
//      -------------------  ----  ------------------------------------------------------------------------------------------------------------------------------------------------
//      Button Query ID      key
//      Button Keys          key
//      Button Name          str
//
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Linkset Data Storage
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//    Key          Standard Variable Name          Notes                                                                                                                    Default
//    -----------  ------------------------------  -----------------------------------------------------------------------------------------------------------------------  -------
//    90_LC        sLanguageCode                                                                                                                                            EN
//    90_PS        iPrivacySetting                                                                                                                                          0
//
//  
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Linked Messages
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Msg ID    Msg Name              Parameters
//  --------  --------------------  ------------------------  ------------------------------------------------------------------------------------------------------
//  90001     MLS_Initialize        None                      Initialize the Multi-Language Support Script.           
//  90010     MLS_SetLanguage       sParam = Language Code    Change the language code to the user's preference
//  90015     MLS_SetPrivacy        sParam = Privacy Code
//  90xxyyy   MLS_TriggerEmote
//  90xxyyy   MLS_TriggerMenu
//
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Additional Info
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  For English, French, German, Italian and Spanish, plurals are 0 units, 1 unit, 2 units.  For now, no need to code indivdual cases except for 1.
//  See https://unicode-org.github.io/cldr-staging/charts/latest/supplemental/language_plural_rules.html#comparison
//  
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Version History:
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// 
// Version 1.0
//  - Initial Version
// 
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Future Versions:
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// - Add ability to set a custom time out period for individual dialog menus
//
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  To Do List:
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  - for name related string substitution tokens, add test for key and handle between SLURL or just substitute passed name string
//
// ********************************************************************************************************************************************************************************

// ********************************************************************************************************************************************************************************
//  Rollout Instructions
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// 1. Set constants
list    VALID_LANGUAGES = ["EN"];
integer MENU_TIMEOUT = 60;  

// 2. Update the StartProcessingNextEmote_Menu function for each product this script is used in
//     - Uncomment out the product's code block for the lEmoteNumbers and lNoteCardLineNumbers variable setup
//     - Verify the row numbers are still correct for that product's language notecard

/*
Debug(string sMsg)
{
    llOwnerSay("Debug (MLS): " + sMsg);
}
//*/

// ********************************************************************************************************************************************************************************


string g_sLanguageCode;
integer g_iPrivacySetting;

// Main Queue
list    g_lMainQueue;
integer g_iMainBusyProcessingEmote;
integer g_iMainRequestID;
integer g_iMainSearchDirection;

// Menu Queue
list g_lMenuChannel;
list g_lMenuHandle;
list g_lMenuType;
list g_lMenuTime;
list g_lMenuReturnID;
list g_lMenuButtons;
list g_lMenuSendToKey;
list g_lMenuReturnParms;

//Button Queue
list    g_lButtonQueryID;
list    g_lButtonKeys;
list    g_lButtonNames;
integer g_iButtonReturnID;
integer g_iButtonRequestTime;
string  g_sButtonLanguageString;
key     g_kButtonSendTo;

//Data Server Globals
key     g_kNotecardQuery;
integer g_iLine;
string  g_sEmoteNotecard;

// Other Globals 
key g_kOwnerKey;



// ********************************************************************************************************************************************************************************
//  Main Queue Processing Functions
// ********************************************************************************************************************************************************************************

StartProcessingNextEmote_Menu()
{
    g_iMainBusyProcessingEmote = llGetUnixTime();  //Immediately set busy flag, in case it's not already set
    llSetTimerEvent(5.0); //Set a timer to catch cases where data server takes its time responding and or drops request

    //Note:  This is a faster timer cycle than the dialog menu queue timer cycle

    integer iIndex;
    integer iLength;

    // For Your Product #1
    //*
    list lEmoteNumbers        = [10000, 90000, 9999999]; 
    list lNoteCardLineNumbers = [    1,    13,       1];   
    //*/
    
    // For Your Product #2
    /*
    list lEmoteNumbers        = [10000, 20000, 90000, 9999999]; 
    list lNoteCardLineNumbers = [    2,    21,    22,       2];  
    //*/

    // Note: These numbers above should be updated as the notecard changes, but is only an approximation to get the initial notecard line pulled approximately correct. The data
    // server code will adjust the line number if it doesnt find the correct one initially.

    // Note: These numbers are the first emote line for the section.  The line numbers in MS Code begin with row 1, but in SL the notecard lines begin counting with row 0. For
    // purposes of this script, use the number assuming the first row is row 1, since it is easier to use the MS Code generated row numbers than manually counting the rows in SL.
    // The code below assumes that the numbers above are counted from row 1.

    g_iMainRequestID = llList2Integer(g_lMainQueue,0);
    integer iRequestIDLast3  = g_iMainRequestID - (llFloor(g_iMainRequestID/1000) * 1000);

    //Look up an approximate notecard line number to minimize the number of notecard lines to process to find the correct emote
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    g_iLine = -1; //Reset line number
    iLength = llGetListLength(lEmoteNumbers);

    for(iIndex = 0; iIndex < iLength; iIndex++)
    {
        if(g_iMainRequestID < llList2Integer(lEmoteNumbers, iIndex))
        {
            g_iLine = llList2Integer(lNoteCardLineNumbers, iIndex - 1); //went too far, pull the previous indexes value
            iIndex = iLength; //break the loop early
        }
    }

    if(g_iLine < 0) llList2Integer(lNoteCardLineNumbers, iLength - 1); //The emote number was in the last bucket, pull the line number

    g_iLine += iRequestIDLast3 - 2;  //Add the last three digits, assuming that the notecard is in numeric order within that script's section of the notecard
    //Note:  Because the ranges above are base 1, not base 0, need to deduct 1 from the calc.  Also, deduct 1, because the emote numbers start at 1 in each section.

    // Look up the emote from the notecard
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    g_kNotecardQuery = llGetNotecardLine(g_sEmoteNotecard, g_iLine); 
} 

RemoveRequestFromMainQueueAndProcessNextOne()
{
    //Remove first emote from queue
    g_lMainQueue = llDeleteSubList( g_lMainQueue, 0, 2 );

    //See if anything left in the queue
    if(llGetListLength(g_lMainQueue) > 0)
    {
        StartProcessingNextEmote_Menu();
    }
    else
    {
        g_iMainBusyProcessingEmote = 0;

        llSetTimerEvent(1.0); //Trigger quick timer
    }
}

// ********************************************************************************************************************************************************************************
//  Button Queue Processing Functions
// ********************************************************************************************************************************************************************************

ProcessButtonDataServer(integer iIndex, string sData)
{
    integer iLength;
    integer iChannel;
    integer iHandle;
    list    lButtonValuesAndButtons;

    // Add Button Name to the list
    g_lButtonNames = llListReplaceList(g_lButtonNames, [llBase64ToString(llGetSubString(llStringToBase64(sData), 0, 31))], iIndex, iIndex);

    // Check to see if all names are set
    iLength = llGetListLength(g_lButtonKeys);

    for(iIndex = 0; iIndex < iLength; iIndex++)  
    {
        // Verify that button name has been pulled already
        if(llList2String(g_lButtonNames, iIndex) == "") return;

        //Set up Value/Button Pair for dialog menu
        lButtonValuesAndButtons += llList2List(g_lButtonKeys,  iIndex, iIndex);
        lButtonValuesAndButtons += llList2List(g_lButtonNames, iIndex, iIndex);
    }
    
    // Set up unique channel and listener for the dialog menu
    //---------------------------------------------------------------------------------------------------------------------------------------------------------
    do
        iChannel = (integer)llFrand(999999999.0) + 100; 
    while (llListFindList(g_lMenuChannel, [iChannel] ) >= 0);            	
    iHandle = llListen(iChannel, "", NULL_KEY, "");

    // Add menu to the Menu queue
    //---------------------------------------------------------------------------------------------------------------------------------------------------------
    g_lMenuChannel     += iChannel;
    g_lMenuHandle      += iHandle;
    g_lMenuType        += 3;         
    g_lMenuTime        += llGetUnixTime();
    g_lMenuReturnID    += g_iButtonReturnID;            
    g_lMenuButtons     += llList2CSV(lButtonValuesAndButtons);  
    g_lMenuSendToKey   += g_kButtonSendTo;   
    g_lMenuReturnParms += "";    

    // Send the menu and set timer
    //---------------------------------------------------------------------------------------------------------------------------------------------------------
    llDialog(g_kButtonSendTo, g_sButtonLanguageString, g_lButtonNames, iChannel);

    //Clear button request from queue and reset the variables for the next button request
    g_lButtonQueryID        = [];
    g_lButtonKeys           = [];
    g_lButtonNames          = [];
    g_iButtonReturnID       =  0;
    g_iButtonRequestTime    =  0;
    g_sButtonLanguageString = "";
    g_kButtonSendTo         = NULL_KEY;

    //Set Quick Timer
    llSetTimerEvent(1.0);
}


// ********************************************************************************************************************************************************************************
//  Language Setting Function
// ********************************************************************************************************************************************************************************

UpdateLanguageSetting(string sNewLanguageSetting)
{
    //Note: Defaults to the currently stored setting.  This function is called on script startup, initialization and user language updates
    g_sLanguageCode = llLinksetDataRead("90_LC");
    
    //if not a null parameter, then set a new language code
    if(sNewLanguageSetting != "")
    {
        g_sLanguageCode = sNewLanguageSetting;
    }

    if(llListFindList(VALID_LANGUAGES, [g_sLanguageCode]) < 0) g_sLanguageCode = "EN";

    g_sEmoteNotecard = "Language-" + g_sLanguageCode;   
    llLinksetDataWrite("90_LC", g_sLanguageCode );
    llMessageLinked(LINK_THIS, 90010, g_sLanguageCode, NULL_KEY);  // 90010 MLS_SetLanguage (sParam = Language Code)
    llMessageLinked(LINK_THIS, 1150, "8192", NULL_KEY); // 1150 UpdatedData-Update (sParam = bitfield flag)
}

// ********************************************************************************************************************************************************************************
//  String Functions
// ********************************************************************************************************************************************************************************

string strReplace(string str, string search, string replace) 
{
    //replaces all occurrences of 'search' with 'replace' in 'str'.  From http://wiki.secondlife.com/wiki/Combined_Library
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}


//This function replaces special items with actual values
string StringSubstitutions(string sStringToConvert)
{
    //The following symbols will have the actual value substituted when played.
    //    %ok%   Owner's Key            
    //    %on%   Owner's Name          
    //    %ofn%  Owner's First Name     

    //    %p1%   Param 1          %p2%   Param 2          %p3%   Param 3        
    //    %n1%   Name 1           %n2%   Name 2           %n3%   Name 3        
    //    %fn1%  First Name 1     %fn2%  First Name 2     %fn3%  First Name 3   

    string sFirstName;
    string sParamValue;

    // Handle Owner Name Substitutions
    // ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    sFirstName = ConvertReceivedKeyOrNameToFirstName(g_kOwnerKey);

    sStringToConvert = strReplace(sStringToConvert, "%ok%", (string)g_kOwnerKey);  
    sStringToConvert = strReplace(sStringToConvert, "%on%", "secondlife:///app/agent/"+(string)g_kOwnerKey+"/displayname");
    sStringToConvert = strReplace(sStringToConvert, "%ofn%", sFirstName);

    // Handle Other Avatar Key Based Substitutions
    // ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

    //Format:  Element 0 = Emote ID    Element 1 = Male Key    Element 2 = Optional <CSV: Message Substitution Parameters>|<CSV: Extra Parameters>
    list lEmoteParameters = llParseStringKeepNulls(llList2String(g_lMainQueue, 2), ["|"],[] );
    lEmoteParameters = llCSV2List(llList2String(lEmoteParameters, 0));

    sParamValue = llList2String(lEmoteParameters, 0)  ;
    sFirstName  = ConvertReceivedKeyOrNameToFirstName(sParamValue); 
    sStringToConvert = strReplace(sStringToConvert, "%p1%" , sParamValue);
    sStringToConvert = strReplace(sStringToConvert, "%n1%" , "secondlife:///app/agent/"+sParamValue+"/displayname");
    sStringToConvert = strReplace(sStringToConvert, "%fn1%", sFirstName);
    
    sParamValue = llList2String(lEmoteParameters, 1)  ;
    sFirstName  = ConvertReceivedKeyOrNameToFirstName(sParamValue); 
    sStringToConvert = strReplace(sStringToConvert, "%p2%" , sParamValue);
    sStringToConvert = strReplace(sStringToConvert, "%n2%" , "secondlife:///app/agent/"+sParamValue+"/displayname");
    sStringToConvert = strReplace(sStringToConvert, "%fn2%", sFirstName);
    
    sParamValue = llList2String(lEmoteParameters, 2)  ;
    sFirstName  = ConvertReceivedKeyOrNameToFirstName(sParamValue); 
    sStringToConvert = strReplace(sStringToConvert, "%p3%" , sParamValue);
    sStringToConvert = strReplace(sStringToConvert, "%n3%" , "secondlife:///app/agent/"+sParamValue+"/displayname");
    sStringToConvert = strReplace(sStringToConvert, "%fn3%", sFirstName);
    
    // "\n" is not properly interpreted as a new line when read from a notecard.  See VWR-4069 in JIRA
    sStringToConvert = strReplace(sStringToConvert, "\\n", "\n");

    return sStringToConvert;    
}

string ConvertReceivedKeyOrNameToFirstName(string sKeyOrName)
{  
    string sFirsttName;

    if( (key)sKeyOrName ) 
    {
    	sFirsttName = llGetDisplayName( sKeyOrName );   
    
   		if(sFirsttName == "" || sFirsttName == "???") 
        {
            //Only make the one attempt.  If unable to get the display name to extract the first name from it, just return the entire display name via SLURL
            return "secondlife:///app/agent/"+(string)sKeyOrName+"/displayname";
        }
    }
    else //Assume it was a name passed
    {
    	sFirsttName = sKeyOrName;
    }

    //Extract first name
    sFirsttName = llList2String( llParseString2List(sFirsttName,[" "],[]), 0);

    return sFirsttName;
}

// ********************************************************************************************************************************************************************************
//  Default State
// ********************************************************************************************************************************************************************************

default
{    
    // ****************************************************************************************************************************************************************************
    //  State Entry Handler
    // ****************************************************************************************************************************************************************************

    state_entry()
    {
        //Set up Language
        UpdateLanguageSetting("");
    }
    
    // ****************************************************************************************************************************************************************************
    //  Link Message Handler
    // ****************************************************************************************************************************************************************************

    link_message(integer sender_num, integer num, string sParam, key id)
    {
        g_kOwnerKey = llGetOwner(); 

        if(!((num >= 90000 && num <= 90999) || (num >= 9000000 && num <= 9099999))) return;

        if(num == 90001) // 90001 MLS_Initialize
        {
            g_iPrivacySetting = (integer)llLinksetDataRead("90_PS");
            UpdateLanguageSetting("");
        }
        
        if(num == 90010) // 90010 MLS_SetLanguage (sParam = Language Code)
        {
            UpdateLanguageSetting(sParam);
        }

        if(num == 90015) // 90015 MLS_SetPrivacy (sParam = Privacy Level) 
        {
            integer iNewPrivacySetting = (integer)sParam;

            if(iNewPrivacySetting < 0 || iNewPrivacySetting > 2) iNewPrivacySetting = 0;

            g_iPrivacySetting = iNewPrivacySetting; 

            llLinksetDataWrite("90_PS", (string)g_iPrivacySetting); 
            return;
        }

        //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // Process Emote & Menu Requests
        //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        //  
        // Other scripts call for emotes and menus by sending a link message with a number in the format of 90xxyyy, where xx is the calling script number code, and the yyy is a 
        // three digit emote number.  The id parameter will be the male key when needed.  The sParam parameter is an optional | delimited list of parameters to substiture into the 
        // emote string.
        // 
        // Emote requests are added to the queue, and if script is busy processing a previous emote, then processing the request is deferred.  As data request responses are 
        // received, the first one on the queue is then processed, and after processing if any remain, then begin processing the next one on the stack in FIFO order.

        if(num >= 9000000 && num <= 9099999) 
        {
            //Determine if id is defined.  NULL_KEY or invalid key should default to owner key
            if(id) {;} else {id = g_kOwnerKey;}

            g_lMainQueue += [num - 9000000, id, sParam]; 
 
            if(g_iMainBusyProcessingEmote) return;

            StartProcessingNextEmote_Menu();
            
        } // End of Process Emotes 
        
    } // End of Link Message Handler

    // ****************************************************************************************************************************************************************************
    //  Data Server Handler
    // ****************************************************************************************************************************************************************************

    dataserver(key query_id, string data) 
    { 
        integer iIndex;
        integer iLength;
        
        // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        //  Dataserver: Handle Dialog Menu Button Queries
        // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        // The data server expects the menu button requests to be aligned in two separate lists.  
		//
		//      Button Keys          Button Names         
		//      -------------------- -------------------- 
		//      UUID                 Truncated Name       Note:  Button Name is a null string until all of the dataserver events have been processed
		//      ...                  ...                  
		
		//Use the index from the dataserver match to store the name to the appropriate key. 
		iIndex = llListFindList( g_lButtonQueryID, [query_id] );  
		if(iIndex >= 0) 
        {
            ProcessButtonDataServer(iIndex, data);
            return; 
            //Note: Since the query was a dialog button name query, no more processing of the dataserver event required.  If not found, then let the code below handle the
            //notecard data request.
        }


        // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        //  Dataserver: Handle Notecard Queries
        // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        if (query_id == g_kNotecardQuery) 
        {
            string sLanguageString;
            list lMenuParams;
            string sMenuStrSubParams;
            string sMenuExtraParams;
            list lRequestData;
            key kSendTo;
            
            integer iRequestID;
            integer iRequestIDPulled;
            integer iRequestType;

            //Get the first request number from the Main queue
            iRequestID = llList2Integer(g_lMainQueue, 0);

            // this is a line of our notecard
            if (data == EOF) 
            {   
                llOwnerSay("ERROR: Language EOF "+ (string)iRequestID +"- Contact secondlife:///app/agent/" + (string)llGetCreator() + "/displayname to report the error.");
                RemoveRequestFromMainQueueAndProcessNextOne();
            } 
            else 
            {
                //Parse request to get message number, each request should be in the format xxyyy|<request type>|<emote volume>|<emote string>|<optional parameters>...
                iRequestIDPulled = (integer)llGetSubString(data, 0, 4 );

                if(iRequestIDPulled == iRequestID)
                {
                    //Parse data from data server
                    lRequestData       = llParseStringKeepNulls(data, ["|"],[] );

                    //Parse data and set up variables from main queue
                    //Format:  Element 0 = Request ID    Element 1 = Send To Key    Element 2 = Optional: <CSV of Message Params>|<CSV of Return Params>
                    //lEmoteParameters = llParseStringKeepNulls(llList2String(g_lMainQueue, 2), ["|"],[] );
                    kSendTo           = llList2Key(g_lMainQueue, 1);  
                    lMenuParams       = llParseStringKeepNulls( llList2String(g_lMainQueue, 2), ["|"],[] );
                    sMenuStrSubParams = llList2String(lMenuParams, 0) ; 
                    sMenuExtraParams  = llList2String(lMenuParams, 1) ; 

                    //Set up initial request variables
                    //Format: 90xxyyy|<request type>|<emote volume>|<request string>|<optional parameters>...
                    iRequestType    = llList2Integer( lRequestData, 1);
                    sLanguageString = llList2String(  lRequestData, 3);

                    //Do substitutions 
                    //Note: Within this function, the Main Queue, element 2 is used to find the substitutions.  
                    sLanguageString = StringSubstitutions(sLanguageString);

                    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
                    // Dataserver Notecard Query: Handle Emote Requests
                    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
                    if(iRequestType == 0) 
                    {
                        //Set up request variables needed for Emote requests
                        //Format: 90xxyyy|<request type>|<emote volume>|<request string>|<optional parameters>...
                        integer iVolume = llList2Integer(lRequestData, 2);
                        
                        //Convert volume where user emote settings require it
                        if(iVolume < 10) 
                        {
                            //(g_iPrivacySetting == 0)               //Public - Leave Alone
                            if(g_iPrivacySetting == 1)  iVolume = 1; //Private
                            if(g_iPrivacySetting == 2)  iVolume = 0; //Mute
                        }

                        //Convert mandatory emotes to their final volume
                        if(iVolume > 10) iVolume -= 10; 
                        if(iVolume > 10) //21-25 emotes
                        {
                            if(g_iPrivacySetting) iVolume = 1; else iVolume -= 10;
                        }

                        //Play emote based upon volume level
                        //(iVolume ==  0) Mute emote
                        if(iVolume ==  1) llOwnerSay(sLanguageString);
                        if(iVolume ==  2) llWhisper(0, sLanguageString);
                        if(iVolume ==  3) llSay(0, sLanguageString);
                        if(iVolume ==  4) llShout(0, sLanguageString); 
                        if(iVolume ==  5) llInstantMessage(kSendTo, sLanguageString);

                        //(iVolume == 11) Mandatory Owner Say        |
                        //(iVolume == 12) Mandatory Whisper          |
                        //(iVolume == 13) Mandatory Say              |-- Note: These will never be called. They are converted to 1-5 when taking into account user's emote settings
                        //(iVolume == 14) Mandatory Shout            |
                        //(iVolume == 15) Mandatory Instant Message  |

                        //(iVolume == 21) Mandatory Owner Say        |
                        //(iVolume == 22) Mandatory Whisper          |
                        //(iVolume == 23) Mandatory Say              |-- Note: These will never be called. They are converted to 1-5 when taking into account user's emote settings
                        //(iVolume == 24) Mandatory Shout            |         or to 1 when Private/Mute set.
                        //(iVolume == 25) Mandatory Instant Message  |
                    }
                    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
                    //  Dataserver Notecard Query: Handle Menu requests
                    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
                    else 
                    {
                        integer iChannel;
                        integer iHandle;
                        integer iReturnID;
                        string  sValuesAndButtonsCSV;
                        list    lButtons;
                        
                        // Check to see if request exceeds outstanding menu limits to prevent running out of memory
                        if(llGetListLength(g_lMenuChannel) > 5)
                        {
                            //Emote: *** Too many dialog menus open. Try again later.
                            llMessageLinked(LINK_THIS, 9090001, "", NULL_KEY); //90xxyyy MLS_TriggerEmote 
                            RemoveRequestFromMainQueueAndProcessNextOne();
                            return;
                            
                        }

                        // Set up general request variables needed for menu requests
                        // Format: 90xxyyy|<request type>|<Return ID>|<request string>|<value 1>|<button 1>...
                        iReturnID        = llList2Integer(lRequestData, 2);

                        // Set up buttons based on Request ID
                        //---------------------------------------------------------------------------------------------------------------------------------------------------------

                        // Button menu 
                        if(iRequestType == 1 || iRequestType == 2) 
                        {
                            list lWorkingCopy;

                            // Get initial list of buttons (includes button values as well)
                            lWorkingCopy = llDeleteSubList(lRequestData, 0, 3);

                            // Store value/button pairs for later
                            sValuesAndButtonsCSV = llList2CSV(lWorkingCopy); 

                            // Build Button List
                            iLength = llGetListLength(lWorkingCopy);
                            for(iIndex = 1; iIndex < iLength; iIndex += 2 )
                            {
                                lButtons += llList2String(lWorkingCopy, iIndex);
                            }

                        }

                        // Name Button menus
                        if(iRequestType == 3) 
                        {
                            //Note: For Type 3 Name Button menus, there is currently no way of passing additional paramaters to be returned on the return link message.  
                            //      This type uses the second slot of the sParam to pass the CSV of the keys to use for the menu.
                        
                            if(g_iButtonRequestTime)
                            {
                                //Emote: *** Previous name type menu still active, please wait and try again later.
                                llMessageLinked(LINK_THIS, 9090002, "", NULL_KEY); //90xxyyy MLS_TriggerEmote

                                RemoveRequestFromMainQueueAndProcessNextOne();
                                return;
                            }

                            //Get list of passed keys
                            list lWorkingCopy = llCSV2List(sMenuExtraParams);  
                            key kButtonUUID;

                            iLength = llGetListLength(lWorkingCopy);

                            for (iIndex = 0; iIndex < iLength; iIndex++)
                            {
                                //Prepare data for the dataserver
                                kButtonUUID       = llList2Key(lWorkingCopy, iIndex);
                                g_lButtonQueryID  += llRequestDisplayName(kButtonUUID);
                                g_lButtonKeys     += kButtonUUID;
                                g_lButtonNames    += "";  
                            }

                            //Finish setting up the button data request
                            g_iButtonReturnID = iReturnID;
                            g_iButtonRequestTime = llGetUnixTime();
                            g_sButtonLanguageString = sLanguageString;
                            g_kButtonSendTo = kSendTo;

                           
                            llSetTimerEvent(5.0); 

                            RemoveRequestFromMainQueueAndProcessNextOne();

                            return; //For name dialog menus, will have to wait for dataserver to finish getting the names for the buttons first before adding to Menu queue

                        }

                        // Textbox menus (Request Type 4)
                        // No action needed
                        
                        // Website menus (Request Type 5)
                        if(iRequestType == 5) 
                        {
                            llLoadURL(kSendTo, sLanguageString, llList2String(lRequestData, 4) );
                            RemoveRequestFromMainQueueAndProcessNextOne();
                            return;
                        }

                        // Reserved for Future Use (Request Type 6 to 9)

                        // In the section below, you can define handling for custom request types that are specific to your application
                        // --------------------------------------------------------------------------------------------------------------------------------------------------------
                        /*
                        if(iRequestType == 10) // Request types 10 and higher are available for you to use for customizations
                        {
                           
                        } 
                        */

                        //Check for info only dialog menus, that will never get a response.  Just send menu and don't bother adding it to the queue
                        //NOTE: Keep this before calculating a channel and setting up a listener to prevent setting up unneeded listeners that won't be cleared later
                        //NOTE: Request Type 2 has ReturnIDs with each individual button
                        if(iReturnID == 0 && iRequestType != 2)
                        {
                            llDialog(kSendTo, sLanguageString, lButtons, -9999);
                            RemoveRequestFromMainQueueAndProcessNextOne();
                            return;
                        }

                        

                        // Set up unique channel and listener for the dialog menu
                        //---------------------------------------------------------------------------------------------------------------------------------------------------------
                        do
                            iChannel = (integer)llFrand(999999999.0) + 100; 
                        while (llListFindList(g_lMenuChannel, [iChannel] ) >= 0);            	
                        iHandle = llListen(iChannel, "", NULL_KEY, "");

                        // Add menu to the Menu queue
                        //---------------------------------------------------------------------------------------------------------------------------------------------------------
                        g_lMenuChannel     += iChannel;
                        g_lMenuHandle      += iHandle;
                        g_lMenuType        += iRequestType;
                        g_lMenuTime        += llGetUnixTime();
                        g_lMenuReturnID    += iReturnID;
                        g_lMenuButtons     += sValuesAndButtonsCSV;
                        g_lMenuSendToKey   += (string)kSendTo;   
                        g_lMenuReturnParms += sMenuExtraParams;  

                        // Send the menu and set timer
                        //---------------------------------------------------------------------------------------------------------------------------------------------------------
                        if(iRequestType != 4)
                        {
                            llDialog(kSendTo, sLanguageString, lButtons, iChannel);
                        }
                        else //Text Box Menu
                        {
                            llTextBox(kSendTo, sLanguageString, iChannel);
                        }

                        //Set the dialog menu timer if needed
                        if(!g_iMainBusyProcessingEmote) 
                        {
                            llSetTimerEvent(60.0); //If main queue timer running, leave at shorter timer cycle  TODO: also if getting names leave at shorter
                        }
                    }
                        
                    RemoveRequestFromMainQueueAndProcessNextOne();

                } //End of Processing Emote or Menu Request
                else //Didn't find the correct request ID. Need to search for another row in the notecard
                {
                    if(iRequestIDPulled != 0)
                    {
                        //Decide if next or previous line should be pulled and look again
                        if(iRequestIDPulled < iRequestID) g_iMainSearchDirection = 1; else g_iMainSearchDirection = -1;
                    } 
                    else // it's a blank row, or invalid row
                    {
                        //Double check to make sure for some reason g_iMainSearchDirection isn't 0
                        if(g_iMainSearchDirection == 0) g_iMainSearchDirection = 1;  //Just force a direction and ideally it will figure out on the next row which direction to go
                    }
                    
                    g_iLine += g_iMainSearchDirection;

                    if(g_iLine < 0) 
                    {
                        llOwnerSay("ERROR: Language BOF"+ (string)iRequestID +" - Contact secondlife:///app/agent/" + (string)llGetCreator() + "/displayname to report the error.");
                        RemoveRequestFromMainQueueAndProcessNextOne();
                    }

                    g_kNotecardQuery = llGetNotecardLine(g_sEmoteNotecard, g_iLine); 
                }
                
            }
            
        }
    }

    // ****************************************************************************************************************************************************************************
    //  Listen Event Handler
    // ****************************************************************************************************************************************************************************

    listen(integer channel, string name, key id, string message)
    {
        integer iIndex;
        string  sReturnValue;
        key     kReturnKey = NULL_KEY;
        list    lValueButtonPairs;
       

        // Find the correct menu based upon channel
        iIndex = llListFindList(g_lMenuChannel, [channel] );
        if(iIndex < 0) return;  // For some reason the listener was for a menu not in the queue, ignore

        // Update Timer - This will extend timeout for a brief period.  On the next timer event, the timer event itself will determine when to trigger the next timer.
        llSetTimerEvent(1.0);


        // Pull the menu's info
        integer iMenuHandle      = llList2Integer(g_lMenuHandle,      iIndex);
        integer iMenuType        = llList2Integer(g_lMenuType,        iIndex);
        integer iMenuReturnID    = llList2Integer(g_lMenuReturnID,    iIndex);
        string  sMenuButtons     = llList2String( g_lMenuButtons,     iIndex);   
        string  sMenuExtraParams = llList2String( g_lMenuReturnParms, iIndex);

        // Clean Up Queue and Listener
        llListenRemove(iMenuHandle);

        g_lMenuChannel     = llDeleteSubList(g_lMenuChannel,     iIndex, iIndex);
        g_lMenuHandle      = llDeleteSubList(g_lMenuHandle,      iIndex, iIndex);
        g_lMenuType        = llDeleteSubList(g_lMenuType,        iIndex, iIndex);
        g_lMenuTime        = llDeleteSubList(g_lMenuTime,        iIndex, iIndex);
        g_lMenuReturnID    = llDeleteSubList(g_lMenuReturnID,    iIndex, iIndex);
        g_lMenuButtons     = llDeleteSubList(g_lMenuButtons,     iIndex, iIndex);
        g_lMenuSendToKey   = llDeleteSubList(g_lMenuSendToKey,   iIndex, iIndex);
        g_lMenuReturnParms = llDeleteSubList(g_lMenuReturnParms, iIndex, iIndex);

        // Set Up Value/Button Pairs list then find which button was clicked and the associated value
        lValueButtonPairs = llCSV2List(sMenuButtons);
        iIndex = llListFindList(lValueButtonPairs, [message] );

        sReturnValue = llList2String(lValueButtonPairs, iIndex - 1) ;

        // For Action Button Type Menus, the button's value is the return link message
        if(iMenuType == 2)
        {
            iMenuReturnID = (integer)sReturnValue;
            sReturnValue = "";
        }

        // For Name Type Menus, the key is passed in the key field instead of in the string field
        if(iMenuType == 3)
        {
            kReturnKey = (key)sReturnValue;  
            sReturnValue = "";
        }

        // For TextBox type menus, the message is the return value
        if(iMenuType == 4)
        {
            // Filter out any user submitted | characters from the return value.  The sReturnValue uses the pipe character to delimit the return value from additional return data.
            message = strReplace(message, "|" , "/");
            sReturnValue = message;
        }

        // For URL type menus (Type 5), there is no return value
        
        // Menu Types 6 to 9 are Reserved for Future Use

        // In the section below, you can define handling for custom request types that are specific to your application
        // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        /*
        if(iMenuType == 10)  // Request types 10 and higher are available for you to use for customizations
        {
        }
        */

        // Add back the return params and send the return link message 
        if(sMenuExtraParams) sReturnValue += "|" + sMenuExtraParams;
        
        llMessageLinked(LINK_THIS, iMenuReturnID, sReturnValue, kReturnKey);
    }

    // ****************************************************************************************************************************************************************************
    //  Timer Event Handler
    // ****************************************************************************************************************************************************************************
    timer() 
    {
        integer iCurrentTime = llGetUnixTime();
        float   fNextTimer;
        integer iIndex;
        integer iLength;

        // Handle Dialog Menu Queue Timeouts
        //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // This timeout is only used to remove stale dialog menu requests
        iLength = llGetListLength(g_lMenuTime);

        for(iIndex = 0; iIndex < iLength; iIndex++) 
        {
            
            if(iCurrentTime > llList2Integer(g_lMenuTime, iIndex) + MENU_TIMEOUT)
            {
                // Pull the menu's info
                integer iMenuHandle      = llList2Integer(g_lMenuHandle, iIndex);

                // Clean Up Queue and Listener
                llListenRemove(iMenuHandle);

                g_lMenuChannel     = llDeleteSubList(g_lMenuChannel,     iIndex, iIndex);
                g_lMenuHandle      = llDeleteSubList(g_lMenuHandle,      iIndex, iIndex);
                g_lMenuType        = llDeleteSubList(g_lMenuType,        iIndex, iIndex);
                g_lMenuTime        = llDeleteSubList(g_lMenuTime,        iIndex, iIndex);
                g_lMenuReturnID    = llDeleteSubList(g_lMenuReturnID,    iIndex, iIndex);
                g_lMenuButtons     = llDeleteSubList(g_lMenuButtons,     iIndex, iIndex);
                g_lMenuSendToKey   = llDeleteSubList(g_lMenuSendToKey,   iIndex, iIndex);
                g_lMenuReturnParms = llDeleteSubList(g_lMenuReturnParms, iIndex, iIndex);
            }
        }

        if(llGetListLength(g_lMenuChannel)) fNextTimer = MENU_TIMEOUT + 2.0;

        // Handle Main Queue Timeouts
        //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        if(g_iMainBusyProcessingEmote && iCurrentTime > g_iMainBusyProcessingEmote + 4)
        {
            //The Data Server may be having a delay or dropped the request.  This should be a rare case, but make another attempt to process the queue
            StartProcessingNextEmote_Menu();
            fNextTimer = 5.0; // Update more frequently
        }

        // Handle Dataserver Dialog Button Queue Timeouts
        //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        if(g_iButtonRequestTime)
        {
            if(iCurrentTime > g_iButtonRequestTime + 5)
            {
                // Clear button request from queue and reset the variables for the next button request
                g_lButtonQueryID        = [];
                g_lButtonKeys           = [];
                g_lButtonNames          = []; 
                g_iButtonReturnID       =  0;
                g_iButtonRequestTime    =  0;
                g_sButtonLanguageString = "";

                // Emote: *** Wasn't able to get button names from SL.  Try again later.
                llMessageLinked(LINK_THIS, 9090003, "", NULL_KEY); //90xxyyy MLS_TriggerEmote 
            }
            else // Button request still has not timed out
            {
                fNextTimer = 2.0;
            }
        }
       
        // Set next timer
        llSetTimerEvent(fNextTimer);
    } 
    
}

// ********************************************************************************************************************************************************************************
//  License Details
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// # Released under MIT License
// 
// Copyright (c) 2024 Tex Evans
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
// persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// Suggested Attribution:
// Multi-language support provided by LSL_MultiLanguage, Copyright (c) 2024 Tex Evans, and released under the MIT License.  
// Source code available at https://github.com/TexEvans90/LSL_MultiLanguage
// ********************************************************************************************************************************************************************************
