unit module Parse::Paths:ver<0.1.2>:auth<Francis Grizzly Smit (grizzly@smit.id.au)>;

=begin pod

=begin head2

Table of  Contents

=end head2

=item1 L<NAME|#name>
=item1 L<AUTHOR|#author>
=item1 L<VERSION|#version>
=item1 L<TITLE|#title>
=item1 L<SUBTITLE|#subtitle>
=item1 L<COPYRIGHT|#copyright>
=item1 L<Introduction|#introduction>
=item2 L<Motivations|#motivations>
=item1 L<Grammars|#grammars>
=item2 L<grammar BasePaths & actions BasePathsActions|#grammar-basepaths--actions-basepathsactions>
=item2 L<grammar Paths & actions class PathsActions|#grammar-paths--actions-class-pathsactions>
=item1 L<check-path(…)|#check-path>

=NAME Parse::Paths 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION v0.1.2
=TITLE Parse::Paths
=SUBTITLE A Raku module to provide path parsing and validation for assorted programs.

=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/Parse-Paths/blob/main/LICENSE>

=head1 Introduction

A Raku module to provide path parsing and validation services to Raku programs.

Basically a grammar and a role for inclusion in your own code.

L<Top of Document|#table-of-contents>

=head2 Motivations

I need to parse paths a lot in other grammars so I am centralising it.

L<Top of Document|#table-of-contents>

=head2 BadPath

B<C<BadPath>> is an exception for when paths don't parse.

=begin code :lang<raku>

class BadPath is Exception is export {
    has Str:D $.msg = 'Error: Highlighter Failed.';
    method message( --> Str:D) {
        $!msg;
    }
}

=end code

=end pod

class BadPath is Exception is export {
    has Str:D $.msg = 'Error: Highlighter Failed.';
    method message( --> Str:D) {
        $!msg;
    }
}

=begin pod

=head1 Grammars

=head2 grammar BasePaths & actions BasePathsActions

A grammar action pair to act as a basis of path parsing.
See B<C<GUI::Editors>> and B<C<Usage::Utils>> for other examples. 

=begin code :lang<raku>

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

=end code

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
            $abs-path ~= $/<path-segments>.made ~ '/';
        }
        make $abs-path;
    }
    method relative-path($/) {
        my Str $rel-path = '';
        if $/<path-segments> {
            $rel-path ~= $/<path-segments>.made ~ '/';
        }
        make $rel-path;
    }
} # role BasePathsActions is export #

=begin pod

=head3 grammar Paths & actions class PathsActions

A front end that uses BasePaths & BasePathsActions to implement a path parser.

=begin code :lang<raku>

grammar Paths is BasePaths is export {
    TOP    { [ <base-path> <path-segment>? || <path-segment> ] }
}

class PathsActions does BasePathsActions is export {
    method TOP($made) {
        my $top = '';
        if $made<base-path> {
            $top ~= $made<base-path>.made;
        }
        if $made<path-segment> {
            $top ~= $made<path-segment>.made;
        }
        $made.make: $top;
    }
} # class PathsActions does BasePathsActions is export #

=end code

=end pod

grammar Paths is BasePaths is export {
    token TOP    { ^ [ <base-path> <path-segment>? || <path-segment> ] $ }
}

class PathsActions does BasePathsActions is export {
    method TOP($made) {
        my $top = '';
        if $made<base-path> {
            $top ~= $made<base-path>.made;
        }
        if $made<path-segment> {
            $top ~= $made<path-segment>.made;
        }
        $made.make: $top;
    }
} # class PathsActions does BasePathsActions is export #

=begin pod

L<Top of Document|#table-of-contents>

=head3 check-path(…)

Check that the path is valid.

=begin code :lang<raku>

sub check-path(Str:D $path --> Str:D) is export {
    my $actions = PathsActions;
    my $tmp = Paths.parse($path, :enc('UTF-8'), :$actions).made;
    BadPath.new(:msg("Error: path $path did not parse.")).throw if $tmp === Any;
    my Str:D $result = $tmp;
    return $result;
} # sub check-path(Str:D $path --> Str:D) is export #

=end code

L<Top of Document|#table-of-contents>

=end pod

sub check-path(Str:D $path --> Str:D) is export {
    my $actions = PathsActions;
    my $tmp = Paths.parse($path, :enc('UTF-8'), :$actions).made;
    BadPath.new(:msg("Error: path $path did not parse.")).throw if $tmp === Any;
    my Str:D $result = $tmp;
    return $result;
} # sub check-path(Str:D $path --> Str:D) is export #
