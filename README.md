Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

    * [Motivations](#motivations)

NAME
====

Gzz::Text::Utils 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

v0.1.0

TITLE
=====

Gzz::Text::Utils

SUBTITLE
========

A Raku module to provide text formatting services to Raku programs.

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/Parse-Paths/blob/main/LICENSE)

Introduction
============

A Raku module to provide text formatting services to Raku programs.

Including a sprintf front-end Sprintf that copes better with Ansi highlighted text and implements **`%U`** and does octal as **`0o123`** or **`0O123`** if you choose **`%O`** as I hate ambiguity like **`0123`** is it an int with leading zeros or an octal number. Also there is **`%N`** for a new line and **`%T`** for a tab helpful when you want to use single quotes to stop the **<num> `$`** specs needing back slashes.

And a **`printf`** alike **`Printf`**.

Also it does centring and there is a **`max-width`** field in the **`%`** spec i.e. **`%*.*.*E`**, and more.

[Top of Document](#table-of-contents)

Motivations
-----------

When you embed formatting information into your text such as **bold**, *italics*, etc ... and **colours** standard text formatting will not work e.g. printf, sprintf etc also those functions don't do centring.

Another important thing to note is that even these functions will fail if you include such formatting in the **text** field unless you supply a copy of the text with out the formatting characters in it in the **:ref** field i.e. **`left($formatted-text, $width, :ref($unformatted-text))`** or **`text($formatted-text, $width, :$ref)`** if the reference text is in a variable called **`$ref`** or you can write it as **`left($formatted-text, $width, ref => $unformatted-text)`**

[Top of Document](#able-of-contents)

### Update

Fixed the proto type of **`left`** etc is now 

```raku
sub left(Str:D $text, Int:D $width is copy, Str:D $fill = ' ',
            :&number-of-chars:(Int:D, Int:D --> Bool:D) = &left-global-number-of-chars,
               Str:D :$ref = strip-ansi($text), Int:D
                                :$max-width = 0, Str:D :$ellipsis = '' --> Str) is export
```

Where **`sub strip-ansi(Str:D $text --> Str:D) is export`** is my new function for striping out ANSI escape sequences so we don't need to supply **`:$ref`** unless it contains codes that **`sub strip-ansi(Str:D $text --> Str:D) is export`** cannot strip out, if so I would like to know so I can update it to cope with these new codes.

[Top of Document](#table-of-contents)

