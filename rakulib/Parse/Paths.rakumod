unit module Parse::Paths:ver<0.1.0>:auth<Francis Grizzly Smit (grizzly@smit.id.au)>;

=begin pod

=begin head2

Table of  Contents

=end head2

=item L<NAME|#name>
=item L<AUTHOR|#author>
=item L<VERSION|#version>
=item L<TITLE|#title>
=item L<SUBTITLE|#subtitle>
=item L<COPYRIGHT|#copyright>
=item L<Introduction|#introduction>
=item2 L<Motivations|#motivations>

=NAME Gzz::Text::Utils 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION v0.1.0
=TITLE Gzz::Text::Utils
=SUBTITLE A Raku module to provide text formatting services to Raku programs.

=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/Parse-Paths/blob/main/LICENSE>

=head1 Introduction

A Raku module to provide text formatting services to Raku programs.

Including a sprintf front-end Sprintf that copes better with Ansi highlighted
text and implements B<C<%U>> and does octal as B<C<0o123>> or B<C<0O123>> if
you choose B<C<%O>> as I hate ambiguity like B<C<0123>> is it an int with
leading zeros or an octal number.
Also there is B<C<%N>> for a new line and B<C<%T>> for a tab helpful when
you want to use single quotes to stop the B«<num> C«$»» specs needing back slashes.

And a B<C<printf>> alike B<C<Printf>>.

Also it does centring and there is a B<C<max-width>> field in the B<C<%>> spec i.e. B<C<%*.*.*E>>, 
and more.

L<Top of Document|#table-of-contents>

=head2 Motivations

When you embed formatting information into your text such as B<bold>, I<italics>, etc ... and B<colours>
standard text formatting will not work e.g. printf, sprintf etc also those functions don't do centring.

Another important thing to note is that even these functions will fail if you include such formatting
in the B<text> field unless you supply a copy of the text with out the formatting characters in it 
in the B<:ref> field i.e. B<C<left($formatted-text, $width, :ref($unformatted-text))>> or 
B<C<text($formatted-text, $width, :$ref)>> if the reference text is in a variable called B<C<$ref>>
or you can write it as B«C«left($formatted-text, $width, ref => $unformatted-text)»»

L<Top of Document|#able-of-contents>

=head3 Update

Fixed the proto type of B<C<left>> etc is now 

=begin code :lang<raku>
sub left(Str:D $text, Int:D $width is copy, Str:D $fill = ' ',
            :&number-of-chars:(Int:D, Int:D --> Bool:D) = &left-global-number-of-chars,
               Str:D :$ref = strip-ansi($text), Int:D
                                :$max-width = 0, Str:D :$ellipsis = '' --> Str) is export 
=end code

Where B«C«sub strip-ansi(Str:D $text --> Str:D) is export»» is my new function for striping out ANSI escape sequences so we don't need to supply 
B<C<:$ref>> unless it contains codes that B«C«sub strip-ansi(Str:D $text --> Str:D) is export»» cannot strip out, if so I would like to know so
I can update it to cope with these new codes.

L<Top of Document|#table-of-contents>

=end pod


grammar BasePaths is export {
    regex base-path           { [ <absolute-path> || <relative-path> ] }
    regex absolute-path       { <lead-in>  <path-segments>? }
    regex lead-in             { [ '/' || '~/' || '~' ] }
    regex relative-path       { <path-segments> }
    regex path-segments       { <path-segment> [ '/' <path-segment> ]* '/' }
    token path-segment        { [ <with-space-in-it> || <with-other-stuff> ] }
    token with-space-in-it    { <with-other-stuff> <trailing-sp-stuff>+ }
    token trailing-sp-stuff   { <spaces> <tail-other-stuff> }
    token spaces              { ' '+ }
    token with-other-stuff    { [ <start-other-stuff> <tail-other-stuff>* || <tail-other-stuff>+ ] }
    token start-other-stuff   { \w+ }
    token tail-other-stuff    { <other-stuff>+ <tails-tail>? }
    token tails-tail          { \w+ }
    token other-stuff         { [ '-' || '+' || ':' || '@' || '=' || ',' || '&' || '%' || '.' ] }
}

role BasePathsActions is export {
    #token with-other-stuff    { [ <start-other-stuff> <tail-other-stuff>* || <tail-other-stuff>+ ] }
    method with-other-stuff($/) {
        my $with-other-stuff;
        my @tailotherstuff;
        if $/<tail-other-stuff> {
            @tailotherstuff = $/<tail-other-stuff>».made;
        }
        if $/<start-other-stuff> {
            $with-other-stuff = $/<start-other-stuff>.made ~ @tailotherstuff.join();
        } else {
            $with-other-stuff = @tailotherstuff.join();
        }
        make $with-other-stuff;
    }
    #token editor-name         { <with-other-stuff> }
    method editor-name($/) {
        my $edname = $/<with-other-stuff>.made;
        make $edname;
    }
    method lead-in($/) {
        my $leadin = ~$/;
        make $leadin;
    }
    #token spaces              { ' '+ }
    method spaces($/) {
        my $spaces = ~$/;
        make $spaces;
    }
    #token trailing-sp-stuff   { <spaces> <tail-other-stuff> }
    method trailing-sp-stuff($/) {
        my $trailing-sp-stuff = $/<spaces>.made ~ $/<tail-other-stuff>.made;
        make $trailing-sp-stuff;
    }
    #token with-space-in-it    { <with-other-stuff> <trailing-sp-stuff>+ }
    method with-space-in-it($/) {
        my @trailing = $/<trailing-sp-stuff>».made;
        my $with-space-in-it = $/<with-other-stuff>.made ~ @trailing.join();
        make $with-space-in-it;
    }
    #token start-other-stuff   { \w+ }
    method start-other-stuff($/) {
        my $start-other-stuff = ~$/;
        make $start-other-stuff;
    }
    #token tails-tail          { \w+ }
    method tails-tail($/) {
        my $tails-tail = ~$/;
        make $tails-tail;
    }
    #token other-stuff         { [ '-' || '+' || ':' || '@' || '=' || ',' || '%' || '.' ] }
    method other-stuff($/) {
        my $other-stuff = ~$/;
        make $other-stuff;
    }
    #token tail-other-stuff    { <other-stuff>+ <tails-tail>? }
    method tail-other-stuff($/) {
        my @otherstuff = $/<other-stuff>».made;
        my $tail-other-stuff = @otherstuff.join();
        if $/<tails-tail> {
            $tail-other-stuff ~= $<tails-tail>.made;
        }
        make $tail-other-stuff;
    }
    #token path-segment        { [ <with-space-in-it> || <with-other-stuff> ] }
    method path-segment($/) {
        my $path-segment = ~$/;
        make $path-segment;
    }
    method path-segments($/) {
        my @path-seg = $/<path-segment>».made;
        make @path-seg.join('/');
    }
    method base-path($/) {
        my Str $abs-rel-path;
        if $/<absolute-path> {
            $abs-rel-path = $/<absolute-path>.made;
        } elsif $/<relative-path> {
            $abs-rel-path = $/<relative-path>.made;
        }
        make $abs-rel-path;
    }
    method absolute-path($/) {
        my Str $abs-path = $/<lead-in>.made;
        if $/<path-segments> {
            $abs-path ~= $/<path-segments>.made;
        }
        make $abs-path;
    }
    method relative-path($/) {
        my Str $rel-path = '';
        if $/<path-segments> {
            $rel-path ~= $/<path-segments>.made;
        }
        make $rel-path;
    }
} # role BasePathsActions is export #

