integer g_iExampleNumber;

default
{
    state_entry()
    {
        //llSay(0, "This script gives examples of how to use MultiLanguage.");
        g_iExampleNumber = 10000;
        
        // Initialize the MultiLanguage
        // Note: This will pull in the last saved language code and privacy setting
        llMessageLinked(LINK_THIS, 90001, "", NULL_KEY);
        
        // Changing the language code
        // Note: You are responsible for verifying that your product has the appropriate cards and only submitting valid codes. The MultiLanguage
        // script contains a list of valid codes that you define and will error check as well.
        llMessageLinked(LINK_THIS, 90010, "EN", NULL_KEY);
        
        // Changing the privacy setting
        // 0 = Public emotes, 1 = Private (Owner Only) emotes, 2 = Mute
        // This sets a default privacy setting for emotes.  However, based on the volume setting in the language notecard, this can be overriden
        // to allow for mandatory emotes.
        llMessageLinked(LINK_THIS, 90010, "1", NULL_KEY);
        
    }

    touch_start(integer total_number)
    {
        g_iExampleNumber += 1;
        
        integer iLanguageCardRequestID = 9000000 + g_iExampleNumber;  
       
        
        if(g_iExampleNumber == 10001)
        {   
            // 10001|0|1|Example of an emote
            // Note:  9010001, 9010002, etc.  The prepended 90 tells the MultiLanguage script that it is a request 
            llMessageLinked(LINK_THIS, 9010001, "", NULL_KEY);
        }
        
        if(g_iExampleNumber == 10002)
        {   
            // 10002|0|1|Example of an emote with %on% (owner name) included
            llMessageLinked(LINK_THIS, 9010002, "", NULL_KEY);
        }
        
        if(g_iExampleNumber == 10003)
        {   
            // 10003|0|1|Example of an emote with %n1% (third party name) included
            llMessageLinked(LINK_THIS, 9010003, "d167f3d6-ea7e-4496-a066-cabe21038083", NULL_KEY);
        }
        
        if(g_iExampleNumber == 10004)
        {   
            // 10004|0|1|Example of an emote with %p1% (custom parameter) included
            // Note: In general, you should limit these to numbers or other items that are the same regardless of language, for instance
            // numerical dates (2024-12-31). 
            llMessageLinked(LINK_THIS, 9010004, "2024-12-31", NULL_KEY);
        }
        
        if(g_iExampleNumber == 10005)
        {   
            // 10005|0|1|Example of an emote with %on% (owner name), %n1% (third party name) and %p2% (custom parameter) included
            // Notice you never have to specify the owner's UUID parameter
            llMessageLinked(LINK_THIS, 9010005, "d167f3d6-ea7e-4496-a066-cabe21038083, 5", NULL_KEY);
        }
        
        if(g_iExampleNumber == 10006 || g_iExampleNumber == 10007)
        {   
            // You should also be careful about plurals in your messages, defining multiple lines for "one item" and "7 items" emotes, calling 
            // the appropriate version in your code.  
            
            // 10006|0|1|Example of an emote with one item
            // 10007|0|1|Example of an emote with %p1% item
            integer iValue = g_iExampleNumber - 10005;
            
            if(iValue == 1) llMessageLinked(LINK_THIS, 9010006, "", NULL_KEY);
            else llMessageLinked(LINK_THIS, 9010007, (string)iValue, NULL_KEY);
        }
        
        // Menus
        // ----------------------------------------------------------------------------------------------------------------------------------
        if(g_iExampleNumber == 10008)
        {   
            // Type 1 Menu
            // 10008|1|10101|Example of a menu that returns a single link message number, but with parameters based on button pressed. Value
            // returned in sParam |1|Yes|0|No|-1|Maybe
            // The button/value pairs are defined at the end of the dialog text
            
            // Note:  You can direct this menu to anyone, based on key passed.  If going to the owner, you can just specify NUKK_KEY and it 
            // will default to the owner.  This example manually passes the owner key for demonstration purposes, but could to to any key.
            llMessageLinked(LINK_THIS, 9010008, "", llGetOwner());
        }
        
        if(g_iExampleNumber == 10009)
        {   
            // Type 2 Menu
            // 10009|2|0|Example of a menu that returns a different link message number for each button:|10201|Button One|10202|Button Two
            // The button/value pairs are defined at the end of the dialog text
            llMessageLinked(LINK_THIS, 9010009, "", NULL_KEY);
        }
        
        if(g_iExampleNumber == 10010)
        {   
            list lNameKeys = [llGetOwner()];
            
            // Type 3 Menu
            // 10010|3|10301|Example of a name picker menu
            llMessageLinked(LINK_THIS, 9010010, "|" +llList2CSV(lNameKeys), NULL_KEY);
        }
        
        if(g_iExampleNumber == 10011)
        {   
            // Type 4 Menu
            // 10010|4|10301|Example of a texbox menu that also includes a parameter.  You can add parameters to all of your menus, like %on%.
            llMessageLinked(LINK_THIS, 9010011, "", NULL_KEY);
        }
        
        if(g_iExampleNumber == 10012)
        {   
            // Type 5 Menu
            // 10012|5|0|Example of a website dialog box|https://github.com/TexEvans90/LSL_MultiLanguage
            llMessageLinked(LINK_THIS, 9010012, "", NULL_KEY);
        }
        
        
        
    }
    
    link_message(integer sender_num, integer num, string sParam, key kParam)
    {
        if(num == 10101)
        {
            llOwnerSay("Link Message " + (string)num + " from your dialog menu. Button value = " + sParam);
        }
        
        if(num == 10201)
        {
            llOwnerSay("Link Message " + (string)num + " from your dialog menu. You pressed Button One");
        }  
        
        if(num == 10202)
        {
            llOwnerSay("Link Message " + (string)num + " from your dialog menu. You pressed Button Two");
        }  
        
        if(num == 10301)
        {
            llOwnerSay("Link Message " + (string)num + " from your name menu. You selected secondlife:///app/agent/"+(string)kParam+"/displayname");
        }  
        
        if(num == 10401)
        {
            llOwnerSay("Link Message " + (string)num + " from your textbox menu. You typed:" + sParam);
        }  
    }
}
