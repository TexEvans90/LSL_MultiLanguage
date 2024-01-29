LSL_MultiLanguage

MultiLanguage is a add on script for your products to offer multiple language options to your users.  The system works by allowing your code to request emotes and dialog menus using a link message ID that pulls the correct language text from a language notecard.  There is no need to offer multiple versions of your product.  All the language options you offer are available in one product and your user can select the language or change the language at any time.  

The heart of the system is a language notecard.  Each language will have its own language notecard. Every emote, emote variant, and dialog menu consists of a row of text in the notecard.  There are varying formats for the text string depending on emote and menu type.  The layouts are below.  

General Format
-------------------------------------------------------------------------------------------------------
\<Request ID\>|\<Emote/Menu Type\>|\<Emote/Menu Parameter\>|\<Emote Menu Text and additional parameters\>

10001|0|11|
