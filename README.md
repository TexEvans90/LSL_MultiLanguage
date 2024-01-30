# LSL_MultiLanguage

MultiLanguage is a add on script for your products to offer multiple language options to your users. The system works by allowing your code to request emotes and dialog menus using a link message ID that pulls the correct language text from a language notecard. There is no need to offer multiple versions of your product. All the language options you offer are available in one product and your users can select the language or change the language at any time. 

# Language notecard
The heart of the system is a language notecard. Each language will have its own language notecard. Every emote, emote variant, and dialog menu consists of a row of text in the notecard. The language notecards should be named using the Language-\<Two Letter Language Code\> convention (example: Language-EN).

There are varying formats for the text string depending on emote and menu type. The layouts are below:

## General Format
\<Request ID\>|\<Emote/Menu Type\>|\<Emote/Menu Parameter\>|\<Emote/Menu Text and Additional Parameters\>

### Request ID
The Request ID is in a xxyyy number format, where the first two digits are a grouping identifer and the last three are a emote/messsage ID. The gouping identifier can be used to identify the calling script, which is useful in a multi-script product. Each script can have their own group ID, so that changes to one script's emotes and menus won't require renumbering other script's emotes and menus. And all of a specific scripts emotes/menus can be grouped in one section of the notecard, instead of being scattered throughout the language notecard. The group ID has to be in the 10 to 99 range, but 90 is reserved for the LSL_MultiLanguage script.

The last three digits are a unique (within the group) identifier for the specific emote or menu. The first indentifier in the group must be 001. 

All Request ID's must be in numerical order within the Language notecard.

### Emote/Menu Type
The Emote/Menu Type tells LSL_MultiLanguage script how to process the request. The types are listed below

| Emote/Menu Type  | Description                                                                     | LSL Equivalent          |
| ---------------: | ------------------------------------------------------------------------------- | ----------------------- |
|                0 | Emote                                                                           | llSay, llShout, et. al. |
|                1 | Dialog Menu: Returns single linked msg with sParam indicating button selected   | llDialog                |
|                2 | Dialog Menu: Returns multiple linked msgs depending on which button is selected | llDialog                |
|                3 | Dialog Menu for name selection: Returns name selected's UUID                    | llDialog                |
|                4 | Textbox Menu: Returns user entered text                                         | llTextBox               |
|                5 | Weblink Menu                                                                    | llLoadURL               |

### Emote/Menu Parameter
The Emote/Menu Parameter definitition changes depending upon the type. This will be discussed later in this document.

### Emote/Menu Text and Additional Parameters
The Emote/Menu Text and Additional Parameters varys depending upon the type, however the first part of this section is the text for the emote or menu text. The additional parameters will be discussed in each Emote/Menu Type's section.

## Type 0: Emotes
\<Request ID\>|\<0\>|\<Emote Volume\>|\<Emote Text\>

10001|0|3|This is an example of an emote

### Emote Volume
The Emote Volume parameter controls which LSL function is used for the emote, adjusted by the user's privacy setting. The privacy setting is an optional feature you can offer that allows the user to select if emotes are public, private only to them, or muted completely. Details are discussed in the Privacy Setting section later.

The volumes are listed below:

| Volume  | Description                                                                     |
| ------: | ------------------------------------------------------------------------------- |
|       0 | Muted (Only used internally by the script)                                      |
|       1 | Owner Say                                                                       |
|       2 | Whisper                                                                         |
|       3 | Say                                                                             |
|       4 | Shout                                                                           |
|       5 | Instant Message                                                                 |

As mentioned earlier, these volumes are subject to the user's privacy setting. If the user has selected private, then the volumes are reduced to volume 1 (Owner Say). If the user has selected private, then the volume is turned down to 0.

However, the privacy setting can be overriden for mandatory emotes in two ways. The first is by turning the volume up to 11. :-) If you add 10 to the volume settings above, the emote volumes 11 to 15 will play regardless of the user's privacy setting. If you add 20 to the volume settings above, the emotes will play as volume 1 (Owner Say) if the user has selected the Private or Mute privacy setting.

### Emote Text
The emote text is the text that will play when the emote is called. The text can be static, or can make use of string substitutions using additional parameters you provide when requesting the emote. The string substitutions are listed below:

| Token  | Description                                                                     |
| ------ | ------------------------------------------------------------------------------- |
| %ok%   | Owner's Key                                                                     |
| %on%   | Owner's Display Name                                                            |
| %ofn%  | Owner's First Name                                                              |
| %p1%   | Parameter (%p2% and %p3% is also available to use)                              |
| %n1%   | Display Name for UUID provided (%n2% and %n3% is also available to use)         |
| %fn1%  | Display First Name for UUID provided (%fn2% and %fn3% is also available to use) |

The first name string substitution parameters select the first word in the user's display name. The script will attempt to get the display name to extract the first name, but this is not guaranteed to happen, since it is subject to the limitations of the llGetDisplayName function. If the script is unable to get the display name, it will revert to showing the full display name. The full display name uses the "secondlife:///app/agent/UUID/displayname" method, so this is guaranteed to work, if a valid UUID is provided.

The parameter string substituion is a direct replacement with data that you provide when requesting the emote. It is intended for numerical subsitutions or other non-language specific substitions only.

The string substitution parameters can also be used in all of the menu types as well.

## Type 1: Dialog Menu with a Single Linked Message Call
\<Request ID\>|\<1\>|\<Linked Message Number Returned\>|\<Menu Text\>|<\Button 1 Value\>|<\Button 1 Text\>|... (additional buttons)

10002|1|10202|Single Linked Message Dialog Menu|1|Yes|0|No

With this dialog type, only a single linked message is returned to your script. The sParam of the link message will contain the button value selected by the user.

### Linked Message Number Returned
Provides the linked message number to return once the user has made their selection. Do not confuse this number with the Request ID. They are independent and although in the example provided, it mirrors the "xxyyy" format of the Request ID, this is not a requirement for your scripts. 

### Button 1 Value
The value provided for this parameter will be returned in the sParam of the linked message when the user makes their selection.

### Button 1 Text
The text to use for the button.

You can define up to 12 button/value pairs.

## Type 2: Dialog Menu with Multiple Linked Message Calls
\<Request ID\>|\<2\>|\<0\>|\<Menu Text\>|<Button 1 Link Msg\>|\<Button 1 Text\>|... (additional buttons)

10003|2|0|Example of a menu that returns a different link message number for each button:|10201|Button One|10202|Button Two

With this dialog type, each button has an individual linked message number that is returned once the user makes their selection. 

### Button 1 Link Msg|Button 1 Text
These define the linked message number/button text pairs.

## Type 3: Dialog Menu for Name Selection
\<Request ID\>|\<3\>|\<Link Message Number Returned\>|\<Menu Text\>

10004|3|10401|Example of a name picker menu

With this dialog type, you provide a csv list of UUID's when requesting the menu. Once the user has made their selection, it will return the Linked Message Number and the UUID selected will be in the kParam.

## Type 4: TextBox Menu
\<Request ID\>|\<4\>|\<Link Message Number Returned\>|\<Menu Text\>

10005|4|10501|Example of a textbox menu

With this dialog type, a TextBox style menu is provided to the user. Once the user has entered the text, it will return the Linked Message Number and the user's text will be in the sParam.

## Type 5: Website Dialog Box
\<Request ID\>|\<5\>|\<0\>|\<Menu Text\>|\<URL\>

10012|5|0|Example of a website dialog box|https://github.com/TexEvans90/LSL_MultiLanguage

This dialog type is used to give the user a link to a website. There is no return value for this type.

### URL
The URL of the webpage.

## Type 6 to 9: Reserved For Future Use

## Types 10 +
There are several areas in the script where you can definine your own custom types. If you have a use case for a custom type that you think may be useful for other creators, send me a message and I will consider adding it as an official type.

## Addition Information about the Language Notecard
The 90001 to 90003 Request IDs must be included in your Language notecards. These emotes are used by the LSL_MultiLanguage script to handle error conditions. LSL_MultiLangauge uses the 90 grouping identifier.

**IMPORTANT: The Language Card language strings should not have empty rows between them.  If you do add a row; for comments for instance; you should skip the Request ID number that would have been used for that row. See the example below.**

```
10001|0|3|An Emote
* The next row is an example of a dialog menu. Notice Request ID 10002 is skipped
10003|1|10202|A Dialog Menu|1|Yes|0|No
```

# Setting up the LSL_Language Script
Once you have the Language notecards set up, you will need to update several items in the LSL_MultiLanguage script. In the Rollout Instructions section near the top of the script, you can change the following options.

* Valid Languages: This should be updated to include all the two letter language codes that are valid for your collection of Lanugage notecards.
* Menu Timeout: You can adjust the amount of time before the menus time out and are cleared from the script's queues. LSL_MultiLanguage can handle more than one menu outstanding at a time.

In the StartProcessingNextEmote_Menu function, there is a set of lists that must be updated to correspond to your Language notecards. The lEmoteNumbers list is a list of your grouping identifers used in the Request IDs. They should be formatted in a xx000 format. The lNotecardLineNumbers list is a list of the first notecard line for each grouping identifier. The line numbers for the notecard starts at 1. If you are using an IDE similar to MS Code, you'll see the correct line number in the IDE line numbers. The line number should always be for the xx001 Request ID. The final 9999999 and 1 elements to these lists are mandatory and should not be changed. In addition the 90000 element is required and the line number should be updated to the 90001 Request ID.

You can define additional blocks to cover different products, so you only have to maintain the one LSL_MultiLanguage script, but before rolling out your product, make sure the correct block is the only one uncommented out.

## Initializing LSL_MultiLanguage
Whenever your scripts start up, for instance, after your product is worn, your code is responsible for initializing the LSL_MultiLanguage script.  To initialize, send the following linked message:

     llMessageLinked(LINK_THIS, 90001, "", NULL_KEY);

This tells the LSL_MultiLanguage script to reload the last saved privacy setting and language code. You do not have to call this linked message after changing the language code or the privacy setting via the linked messages.
 
In theory, you could change the 90_LC or 90_PS linkset data storage keys directly and use this command to force a reload of the latest values, however, this is **not recommended**, since it bypasses the data validation for these variables. 

## Changing the Language
If your product supports multiple languages, then instead of creating individual product versions, you can keep all your different language notecards in one product and provide a way for your users to swap between languages. Your scripts are responsible for implementing the menus or other methods for the user to change the language. To inform the LSL_MultiLanguage script of changes to the language setting, send the following linked message:

     llMessageLinked(LINK_THIS, 90010, "/<two letter language code/>", NULL_KEY);

LSL_MultiLanguage stores this setting in the 90_LC key in the linkset data storage. Your scripts can read the latest setting at any time.
     
## Change the Privacy Setting
Your product can support a privacy setting to allow the user to choose to keep emotes private or to turn off emotes. The three levels are:

| Privacy Setting  | Description                                      |
| ---------------: | ------------------------------------------------ |
|                0 | Public  - Emotes play using llSay, llShout, etc. |
|                1 | Private - Emotes play using llOwnerSay           |
|                2 | Mute    - Emotes are muted                       |

Your scripts are responsible for implementing the menus or other methods for the user to change the privacy setting. To inform the LSL_MultiLanguage script of changes to the privacy setting, send the following linked message:

     llMessageLinked(LINK_THIS, 90015, "/<privacy setting/>", NULL_KEY);

LSL_MultiLanguage stores this setting in the 90_PS key in the linkset data storage. Your scripts can read the latest setting at any time.
     
# Requesting Emotes and Menus
To request an emote or menu, use the following linked message:

     llMessageLinked(LINK_THIS, 90xxyyy, "/<Text Parameters/>|\<Additional Parameters\>", \<Key Parameter\>);

The message number is the Request ID, prepended with a "90".

### Text Parameters
The Text Parameters is a CSV string of values used by the string substitution tokens. You can have up to three values passed. For example, if the emote/menu text uses the %p1%, %n2%, %p3%, you should provide a numerical parameter, a UUID, and a second numerical parameter. They must appear in the order of the number suffix in the token. It does not use the order they appear within the text string. 

So, if you have the text string "This is an example of an emote using the name %n2% and a numererical paramenter %p1%.", you would provide the numerical parameter first, then followed by the UUID for the display name desired. 

The UUID parameter for the owner tokens (%on%, %ofn%, and %ok%) are never included in the text parameters.

### Additional Parameters
The Additional Parameters are used to provide additional information for the emote/menu. In many cases, it is optional, but for some menu types, it is mandatory. It is a CSV string of values. The Additional Parameters are documented in each type's section later.

**Note: If you do not have Text Parameters to pass to the request, the "|" character must be prepended to the CSV list of Additional Parameters.**

### Key Parameter
The Key Parameter is used to direct an emote/menu to a specific avatar as needed. You do not need to provide this for emotes or menus that are intended for the owner of your product. The owner's key is substituted for NULL_KEY when necessary.

## Requesting a Type 0 Emote
An emote is called with the following linked message:

     llMessageLinked(LINK_THIS, 90xxyyy, "/<Text Parameters/>", \<Key Parameter\>);
     No Return Message

There are no Additional Parameters for emote requests. The Key Parameter is only required when directing a llInstantMessage to a non-owner avatar. Otherwise, it is recommended you use NULL_KEY instead of passing the owner's UUID.

## Requesting a Type 1 Dialog Menu (Single Linked Message Call)
An Type 1 dialog menu is called with the following linked message:

     llMessageLinked(LINK_THIS, 90xxyyy, "/<Text Parameters/>|\<Return Data\>", \<Key Parameter\>);
     Returns: llMessageLinked(LINK_THIS, \<Return ID\>, "\<Button ID\>|\<Return Data\>", NULL_KEY);
     
### Return Data parameter
Most of the dialog menu requests can optionally return a CSV string of data. If provided when the menu is requested, the sParam of the linked message returned when the user makes their selection will have this data appended, 

The Key Parameter is only required when directing the menu to a non-owner avatar. Otherwise, it is recommended you use NULL_KEY instead of passing the owner's UUID. 

## Requesting a Type 2 Dialog Menu (Multiple Linked Message Calls)
An Type 2 dialog menu is called with the following linked message:

     llMessageLinked(LINK_THIS, 90xxyyy, "/<Text Parameters/>|\<Return Data\>", \<Key Parameter\>);
     Returns: llMessageLinked(LINK_THIS, \<Button Link Msg\>, "|\<Return Data\>", NULL_KEY);

The Key Parameter is only required when directing the menu to a non-owner avatar. Otherwise, it is recommended you use NULL_KEY instead of passing the owner's UUID. This menu type also can optionally return additional data.

## Requesting a Type 3 Dialog Menu (Name Selection)
An Type 3 dialog menu is called with the following linked message:

     llMessageLinked(LINK_THIS, 90xxyyy, "/<Text Parameters/>|\<CSV of Button UUIDs\>", \<Key Parameter\>);
     Returns: llMessageLinked(LINK_THIS, \<Return ID\>, "", \<Selected Name's UUID\>);
     
For Type 3 dialogs, the CSV of UUIDs parameter is mandatory. 

The Key Parameter is only required when directing the menu to a non-owner avatar. Otherwise, it is recommended you use NULL_KEY instead of passing the owner's UUID. This menu type cannot return additional data.

## Requesting a Type 4 TextBox Menu
An Type 4 dialog menu is called with the following linked message:

     llMessageLinked(LINK_THIS, 90xxyyy, "/<Text Parameters/>|\<Return Parameters\>", \<Key Parameter\>);
     Returns: llMessageLinked(LINK_THIS, \<Return ID\>, "\<User Text\>|\<Return Data\>", NULL_KEY);

The Key Parameter is only required when directing the menu to a non-owner avatar. Otherwise, it is recommended you use NULL_KEY instead of passing the owner's UUID. This menu type also can optionally return additional data.

## Requesting a Type 5 Website Dialog Box
An Type 5 dialog menu is called with the following linked message:

     llMessageLinked(LINK_THIS, 90xxyyy, "/<Text Parameters/>", \<Key Parameter\>);
     No Return Message

There are no Additional Parameters for website dialog box requests. The Key Parameter is only required when directing the menu to a non-owner avatar. Otherwise, it is recommended you use NULL_KEY instead of passing the owner's UUID.


# Advanced Language Notecard and Code Examples

## Handling Calendar Text Dates
To provide multilanguage support for textual calendar dates, you should provide month specific language strings. 

Language Notecard:
```
- English Language Notecard Example -
...
10400|0|3|Today is January %p2%, %p1%.
10401|0|3|Today is February %p2%, %p1%.
...
10411|0|3|Today is December %p2%, %p1%.
...

- Spanish Language Notecard Example -
...
10400|0|3|Hoy es %p2% de enero de %p1%.
10401|0|3|Hoy es %p2% de febrero de %p1%.
...
10411|0|3|Hoy es %p2% de diciembre de %p1%.
...
```

Code:
```
integer iMonth = 12;
integer iDay = 25;
integer iYear = 2024;
integer iRequestID;

iRequestID = 9010399 + iMonth; // The request ID for January, minus 1
llMessageLinked(LINK_THIS, iRequestID, (string)iYear +"," + (string)iDay, NULL_KEY);
```

## Handling Plural Text
Generally, languages have different grammar rules for singular and plural forms.  These cases can be handled by providing separate language strings to handle each case.

Language Notecard:
```
...
10501|0|3|There is an avatar nearby.
10502|0|3|There are %p1% avatars nearby.
...
```

Code:
```
integer iNumberOfAvatars = 5;
integer iRequestID;

if(iNumberOfAvatars == 1) iRequestID = 9010501; else iRequestID = 9010502;
llMessageLinked(LINK_THIS, iRequestID, (string)iNumberOfAvatars, NULL_KEY);
```

## Documenting Your Code
I recommend that you include the language string for your primary language as a comment above your linked message call to the LSL_MultiLanguage script.  At least from my experience, having the language string comment nearby your requests, helps remind you of the purpose of the emote or menu, and helps to document what parameters are needed to be passed to the request, which helps when you are debugging and reviewing your code.  And it also provides a reminder of what return values you need to provide code to handle.

```
key kClosestAvatar;

// Emote: 10001|0|3|The closest avatar is %n1%.
llMessageLinked(LINK_THIS, 9010001, (string)kClosestAvatar, NULL_KEY);

// Menu: 10002|1|10202|%on% wants to be friends with you.  Do you want to be friends with them?|1|Yes|0|No
llMessageLinked(LINK_THIS, 9010002, "", kClosestAvatar);
```

