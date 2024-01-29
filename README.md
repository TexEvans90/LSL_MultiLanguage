# LSL_MultiLanguage

MultiLanguage is a add on script for your products to offer multiple language options to your users.  The system works by allowing your code to request emotes and dialog menus using a link message ID that pulls the correct language text from a language notecard.  There is no need to offer multiple versions of your product.  All the language options you offer are available in one product and your user can select the language or change the language at any time.  

# Language notecard
The heart of the system is a language notecard.  Each language will have its own language notecard. Every emote, emote variant, and dialog menu consists of a row of text in the notecard.  There are varying formats for the text string depending on emote and menu type.  The layouts are below.  

The language notecards should be named using the Language-\<Two Letter Language Code\> convention (example: Language-EN).

## General Format
\<Request ID\>|\<Emote/Menu Type\>|\<Emote/Menu Parameter\>|\<Emote/Menu Text and Additional Parameters\>

### Request ID
The Request ID is in a xxyyy number format, where the first two digits are a grouping identifer and the last three are a emote/messsage ID.  The gouping identifier can be used to identify the calling script, which is useful in a multi-script product.  Each script can have their own group ID, so that changes to one script's emotes and menus won't require renumbering other script's emotes and menus.  And all of a specific scripts emotes/menus can be grouped in one section of the notecard, instead of being scattered throughout the language notecard.  The group ID has to be in the 10 to 99 range, but 90 is reserved for the LSL_MultiLanguage script.

The last three digits are a unique (within the group) identifier for the specific emote or menu. The first indentifier in the group must be 001. 

All Request ID's must be in numerical order within the Language notecard.

### Emote/Menu Type
The Emote/Menu Type tells LSL_MultiLanguage script how to process the request.  The types are listed below

| Emote/Menu Type  | Description                                                                     | LSL Equivalent          |
| ---------------: | ------------------------------------------------------------------------------- | ----------------------- |
|                0 | Emote                                                                           | llSay, llShout, et. al. |
|                1 | Dialog Menu: Returns single linked msg with sParam indicating button selected   | llDialog                |
|                2 | Dialog Menu: Returns multiple linked msgs depending on which button is selected | llDialog                |
|                3 | Dialog Menu for name selection: Returns name selected's UUID                    | llDialog                |
|                4 | Textbox Menu: Returns user entered text                                         | llTextBox               |
|                5 | Weblink Menu                                                                    | llLoadURL               |

### Emote/Menu Parameter
The Emote/Menu Parameter definitition changes depending upon the type.  This will be discussed later in this document.

### Emote/Menu Text and Additional Parameters
The Emote/Menu Text and Additional Parameters varys depending upon the type, however the first part of this section is the text for the emote or menu text.  The additional parameters will be discussed in each Emote/Menu Type's section.

## Type 0: Emotes
\<Request ID\>|\<0\>|\<Emote Volume\>|\<Emote Text\>

10001|0|3|This is an example of an emote

### Emote Volume
The Emote Volume parameter controls which LSL function is used for the emote, adjusted by the user's privacy setting.  The privacy setting is an optional feature you can offer that allows the user to select if emotes are public, private only to them, or muted completely. Details are discussed in the Privacy Setting section later.

The volumes are listed below:

| Volume  | Description                                                                     |
| ------: | ------------------------------------------------------------------------------- |
|       0 | Muted (Only used internally by the script)                                      |
|       1 | Owner Say                                                                       |
|       2 | Whisper                                                                         |
|       3 | Say                                                                             |
|       4 | Shout                                                                           |
|       5 | Instant Message                                                                 |

As mentioned earlier, these volumes are subject to the user's privacy setting.  If the user has selected private, then the volumes are reduced to volume 1 (Owner Say).  If the user has selected private, then the volume is turned down to 0.

However, the privacy setting can be overriden for mandatory emotes in two ways.  The first is by turning the volume up to 11. :-) If you add 10 to the volume settings above, the emote volumes 11 to 15 will play regardless of the user's privacy setting.  If you add 20 to the volume settings above, the emotes will play as volume 1 (Owner Say) if the user has selected the Private or Mute privacy setting.

### Emote Text
The emote text is the text that will play when the emote is called.  The text can be static, or can make use of string substitutions using additional parameters you provide when requesting the emote.  The string substitutions are listed below:

| Token  | Description                                                                     |
| ------ | ------------------------------------------------------------------------------- |
| %ok%   | Owner's Key                                                                     |
| %on%   | Owner's Display Name                                                            |
| %ofn%  | Owner's First Name                                                              |
| %p1%   | Parameter (%p2% and %p3% is also available to use)                              |
| %n1%   | Display Name for UUID provided (%n2% and %n3% is also available to use)         |
| %fn1%  | Display First Name for UUID provided (%fn2% and %fn3% is also available to use) |

The first name string substitution parameters select the first word in the user's display name. The script will attempt to get the display name to extract the first name, but this is not guaranteed to happen, since it is subject to the limitations of the llGetDisplayName function. If the script is unable to get the display name, it will revert to showing the full display name.  The full display name uses the "secondlife:///app/agent/UUID/displayname" method, so this is guaranteed to work.

The parameter string substituion is a direct replacement with data that you provide when requesting the emote.  It is intended for numerical subsitutions or other non-language specific substitions only.

The string substitution parameters can also be used in all of the menu types as well.

## Type 1: Dialog Menu with a Single Linked Message Call
\<Request ID\>|\<1\>|\<Linked Message Number Returned\>|\<Menu Text\>|<\Button 1 Value\>|<\Button 1 Text\>|... (additional buttons)

10002|1|10202|Single Linked Message Dialog Menu|1|Yes|0|No

With this dialog type, only a single linked message is returned to your script.  The sParam of the link message will contain the button value selected by the user.

### Linked Message Number Returned
Provides the linked message number to return once the user has made their selection. Do not confuse this number with the Request ID.  They are independent and although in the example provided, it mirrors the "xxyyy" format of the Request ID, this is not a requirement for your scripts.  

### Button 1 Value
The value provided for this parameter will be returned in the sParam of the linked message when the user makes their selection.

### Button 1 Text
The text to use for the button.

You can define up to 12 button/value pairs.


## Type 2: Dialog Menu with Multiple Linked Message Calls
\<Request ID\>|\<2\>|\<Link Message Number Returned\>|\<Menu Text\>|<Button 1 Link Msg\>|\<Button 1 Text\>|... (additional buttons)

10003|2|0|Example of a menu that returns a different link message number for each button:|10201|Button One|10202|Button Two

With this dialog type, each button has an individual linked message number that is returned once the user makes their selection.  

### Button 1 Link Msg|Button 1 Text
These define the linked message number/button text pairs.

## Type 3: Dialog Menu for Name Selection
\<Request ID\>|\<3\>|\<Link Message Number Returned\>|\<Menu Text\>

10004|3|10401|Example of a name picker menu

With this dialog type, you provide a csv list of UUID's when requesting the menu.  Once the user has made their selection, it will return the Linked Message Number and the UUID selected will be in the kParam.

## Type 4: TextBox Menu
\<Request ID\>|\<4\>|\<Link Message Number Returned\>|\<Menu Text\>

10005|4|10501|Example of a Name Selection Dialog Menu

With this dialog type, a TextBox style menu is provided to the user.  Once the user has entered the text, it will return the Linked Message Number and the user's text will be in the sParam.

## Type 5: Website Dialog Box
\<Request ID\>|\<5\>|\<Link Message Number Returned\>|\<Menu Text\>|\<URL\>

10012|5|0|Example of a website dialog box|https://github.com/TexEvans90/LSL_MultiLanguage

This dialog type is used to give the user a link to a website.  There is no return value for this type.

### URL
The URL of the webpage.

## Type 6 to 9: Reserved For Future Use

## Types 10 +
There are several areas in the script where you can definine your own custom types. If you have a use case for a custom type that you think may be useful for other creators, send me a message and I will consider adding it as an official type.

# Requesting Emotes and Menus




