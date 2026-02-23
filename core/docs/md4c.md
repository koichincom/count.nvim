Embedding Parser: Calling MD4C

John Lemme edited this page on Oct 6, 2024 · 5 revisions
This page of the wiki explains how to call MD4C. md4c.h is the header file which should be #include in the caller's code. This header file is very well documented. So don't forget to read it too.

MD4C exposes a function called md_parse in the md4c.h header file. Users of the library should call this function to parse markdown text. Caller should provide several callback functions and markdown text. MD4C call the callbacks on events like entering a markdown block or leaving a markdown block etc.

Here's the function prototype:

int md_parse(const MD_CHAR* text, MD_SIZE size, const MD_PARSER* parser, void\* userdata);
text - Pointer to the beginning of the markdown text to parse.
size - Size of the string text.
parser - Pointer to a MD_PARSER struct which contains information about callback functions.
userdata - MD4C does not use this parameter. It simply pass this to the callbacks as it is. Application can use this to transfer data to the callbacks. Set to NULL if you don't want this.
Note: MD_CHAR will take either WCHAR(if defined macro MD4C_USE_UTF16 and platform is windows) or char data type. MD_SIZE is a typedef to unsigned.

MD_PARSER struct
3rd parameter of md_parse function is a pointer to a variable of type MD_PARSER. This holds the information about the caller-provided callback functions for rendering.

MD_PARSER is defined as follows:

typedef struct MD_PARSER {
unsigned abi_version; // Reserved. Set to zero.
unsigned flags; // Dialect options. Bitmask of MD_FLAG_xxxx values.

    // Caller-provided rendering callbacks.

    int (*enter_block)(MD_BLOCKTYPE /*type*/, void* /*detail*/, void* /*userdata*/);
    int (*leave_block)(MD_BLOCKTYPE /*type*/, void* /*detail*/, void* /*userdata*/);
    int (*enter_span)(MD_SPANTYPE /*type*/, void* /*detail*/, void* /*userdata*/);
    int (*leave_span)(MD_SPANTYPE /*type*/, void* /*detail*/, void* /*userdata*/);
    int (*text)(MD_TEXTTYPE /*type*/, const MD_CHAR* /*text*/, MD_SIZE /*size*/, void* /*userdata*/);

    void (*debug_log)(const char* /*msg*/, void* /*userdata*/);
    void (*syntax)(void); // Reserved. Set to NULL.

} MD_PARSER;
abi_version: Set this to zero.
flags : Bitmask of flags. Refer md4c.h for more details.
enter_block : Function pointer. This should point to the function MD4C should call when entering a block.
leave_block : This should point to the function MD4C should call when leaving a block.
enter_span : This should point to the function MD4C should call when entering a span.
leave_span : This should point to the function MD4C should call when leaving span.
text : This should point to the function MD4C should call when reading actual text content. (Discussed below).
debug_log : Optional (may be NULL). If provided and something goes wrong, this function gets called. But note that this is intended for debugging and problem diagnosis for developers. Not suitable to get errors to display at end user.
syntax : Set this to NULL.
md_parse function takes a void\* parameter (last parameter) called userdata. As mentioned above, MD4C does not use this, but it simply pass it to the callbacks. This will be is passed to the last parameter(userdata) of caller-provided rendering callback.MD4C pass the type of a block, span or a text to the 1st parameter of all rendering callbacks, which is referred to as type in the above code block (see below). The parameter referred to as detail will receive additional information about the relevant block or span (see below). The text callback will receive a pointer to the beginning of the actual text content.

Warning: Note that any strings provided to the callbacks as their arguments or as members of any detail structure are generally not zero-terminated. Application has to take the respective size information into account.

How and when the callbacks are called
Callbacks enter_block, leave_block, enter_span, leave_span won't receive any render-able textual content. These callbacks tell the application that MD4C encountered a certain block or a span.

The actual text is propagated into the text callback and it's up to the application to know at that moment (given what other callbacks have been called previously) whether the text should be rendered e.g. with a regular, bold or italic font.

Application must be able to handle situations when blocks are nested in each other, and similarly when spans are nested in each other. For example the following input:

- foo **bar [link](http://example.com) baz**
  will lead to sequence of callback calls roughly sketched in the following pseudocode:

enter_block(MD_BLOCK_DOC)
enter_block(MD_BLOCK_UL)
enter_block(MD_BLOCK_LI)
text("foo ")
enter_span(MD_SPAN_STRONG)
text("bar ")
enter_span(MD_SPAN_A) // target URL provided as an attribute of the detailed structure
text("link")
leave_span(MD_SPAN_A)
text(" baz")
leave_span(MD_SPAN_STRONG)
leave_block(MD_BLOCK_LI)
leave_block(MD_BLOCK_UL)
leave_block(MD_BLOCK_DOC)
Detail Structure
Some block and span types may provide additional information in a detailed, type-specific, structure, which propagates to the respective block or span callback.

For example for title (MD_BLOCK_H), a pointer to the structure MD_BLOCK_H_DETAIL is passed to enter_block and corresponding leave_block callback, and it provides information about level of the title (between 1 and 6, corresponding to the HTML tags <H1> ... <H6>).

Similar structures for links or images provide their attribute like URLs or alt text.

Typical Implementation
Typical implementations need to maintain a stack describing how the blocks are nested in each other, so that the application e.g. knows how deeply it needs to indent a text when it's in a list nested in a parent list, which itself may be nested in block quotation.

enter_block then needs to push an application-defined structure on the stack, leave_block then pops it out from the stack.

Usually application does not need to implement similar stack for spans. Instead it may maintain a set of internal counters (e.g. a bold font counter). The counter is incremented/decremented whenever relevant span callback is called (e.g. for the bold counter whenever enter_span/leave_span(MD_SPAN_STRONG) is called. Then, when text callback is called, the application chooses to use a regular font when the counter is zero, or bold one when non-zero.
