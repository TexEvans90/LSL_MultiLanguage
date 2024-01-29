# LSL_MultiLanguage

MultiLanguage is a add on script for your products to offer multiple language options to your users.  The system works by allowing your code to request emotes and dialog menus using a link message ID that pulls the correct language text from a language notecard.  There is no need to offer multiple versions of your product.  All the language options you offer are available in one product and your user can select the language or change the language at any time.  

The heart of the system is a language notecard.  Each language will have its own language notecard. Every emote, emote variant, and dialog menu consists of a row of text in the notecard.  There are varying formats for the text string depending on emote and menu type.  The layouts are below.  

## General Format
\<Request ID\>|\<Emote/Menu Type\>|\<Emote/Menu Parameter\>|\<Emote/Menu Text and Additional Parameters\>

### Request ID
The Request ID is in a xxyyy number format, where the first two digits are a grouping identifer and the last three are a emote/messsage ID.  The gouping identifier can be used to identify the calling script, which is useful in a multi-script product.  Each script can have their own group ID, so that changes to one script's emotes and menus won't require renumbering other script's emotes and menus.  And all of a specific scripts emotes/menus can be grouped in one section of the notecard, instead of being scattered throughout the language notecard.  The group ID has to be in the 10 to 99 range, but 90 is reserved for the LSL_MultiLanguage script.

The last three digits are a unique (within the group) identifier for the specific emote or menu.

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

