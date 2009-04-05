# Align.tmbundle

This bundle contains a couple of simple tools for aligning text. There are already some aligning commands in other bundles, but this one is created to supply a more generic alignment functionality. The bundle is modeled to some extent after the align plugin available for the vim editor.

To use it, just press CTRL-SHIFT-A, and then select the appropriate action:

* Align (brings up a input dialog where custom alignment patterns can be entered)
* Align assignments.
* Align comments.
* Align text columns.

The currently selected block of text will be aligned, but you can invoke alignment without a selection too. In that case, the text "block" in which the cursor is placed will be aligned. A block is defined as all the lines of text above and below the current line that:

* Has the same indentation as the current line.
* Is not empty.

## Installation

Run this:
 
	$ cd ~/Library/Application\ Support/TextMate/Bundles
	$ git clone git://github.com/sicher/align-tmbundle.git Align.tmbundle
	$ osascript -e 'tell app "TextMate" to reload bundles'

You can also use GetBundles:

	$ cd ~/Library/Application\ Support/TextMate/Bundles
	$ svn co http://svn.textmate.org/trunk/Review/Bundles/GetBundles.tmbundle/

## Examples:

### Align assignments.

	Patterns: "= += *= -= /="

	Before:
	
	a=1;
	ab=2;
	abc=3;
	abcd=4;
	abcde=5;
	a+=1;
	ab+=2;
	abc+=3;
	this_is_func();
	abcd+=4;
	abcde+=5;
	a/=1;
	ab/=2;
	abc/=3;
	abcd/=4;
	abcde/=5;

	After:

	a      = 1;
	ab     = 2;
	abc    = 3;
	abcd   = 4;
	abcde  = 5;
	a     += 1;
	ab    += 2;
	abc   += 3;
	this_is_func();
	abcd  += 4;
	abcde += 5;
	a     /= 1;
	ab    /= 2;
	abc   /= 3;
	abcd  /= 4;
	abcde /= 5;

### Align comments. 

	Patterns: "/* */" (TM_COMMENT_START TM_COMMENT_END TM_COMMENT_START_2 TM_COMMENT_END_2)

	Before:

	int     a;              /* a   */
	float   b;              /* b   */
	double *c=NULL;              /* b   */
	char x[5]; /* x[5] */
	struct  abc_str abc;    /* abc */
	struct  abc_str *pabc;    /* pabc */
	static   int     a;              /* a   */
	static   float   b;              /* b   */
	static   double *c=NULL;              /* b   */
	static   char x[5]; /* x[5] */
		static   struct  abc_str abc;    /* abc */
	static   struct  abc_str *pabc;    /* pabc */
	
	After:

	int     a;                      /* a    */
	float   b;                      /* b    */
	double *c=NULL;                 /* b    */
	char x[5];                      /* x[5] */
	struct  abc_str abc;            /* abc  */
	struct  abc_str *pabc;          /* pabc */
	static   int     a;             /* a    */
	static   float   b;             /* b    */
	static   double *c=NULL;        /* b    */
	static   char x[5];             /* x[5] */
	static   struct  abc_str abc;   /* abc  */
	static   struct  abc_str *pabc; /* pabc */

### Align word columns

	Patterns: "\b"
	
	Before:
	
	Name Age Married Hairstyle
	Jake 23 yes wild
	Jane 32 no long
	Jimmy 44 no bald
	Eddie 22 yes slick
	Edna 31 no greasy
	Lorna 34 yes curly
	Artie 41 no crewcut
	
	After:

	Name  Age Married Hairstyle
	Jake  23  yes     wild
	Jane  32  no      long
	Jimmy 44  no      bald
	Eddie 22  yes     slick
	Edna  31  no      greasy
	Lorna 34  yes     curly
	Artie 41  no      crewcut