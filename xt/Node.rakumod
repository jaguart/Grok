use v6;

role PodNodeCompression {

    #has $!thing;
    #has @!kids;

    #| compress Pod::Blocks that just have a single kid
    method compress-pod-nodes {

        .compress-pod-nodes for self.kids;

        if not self.content.elems and self.kids.elems == 1 {
            my $kid = self.kids[0];

            if self.thing ~~ Array or $kid.thing ~~ Pod::Block::Para {
                if self.thing ~~ Array {
                    say 'replaced: ', $kid.id, ' ',$kid.name, ' -> ', self.id, ' ', self.name;
                    self.thing  = $kid.thing ;
                    self.name   = $kid.name;
                    self.left   = $kid.left;
                }
                else {
                    say 'merged:   ', $kid.id, ' ',$kid.name, ' -> ', self.id, ' ', self.name;
                }
                self.content.append( $kid.content.flat );
                self.kids.append( $kid.kids.flat );
                self.del-kid(0);
            }
            else {
                say 'skipped:  ', $kid.id, ' ',$kid.name, ' -> ', self.id, ' ', self.name;
            }
        }


    }

}


class Node does PodNodeCompression {

    our $count = 0;

    has $!id;

    has $.name is rw;
    has $.thing is rw;
    has @.content is rw;
    has $.left is rw;

    has @.kids;

    submethod TWEAK {
        $!id = $count++;
        $!name ||= $!thing.^name ~ ($!thing.?name ?? ' ' ~ $!thing.?name !! '' );

        if $!thing.^name eq 'Str' and not @!content {
            @!content.append($!thing)
        }



    }

    method id { $!id }

    # Helper to construct tree
    method get ( $id ) {
        return self if $!id == $id;
        for @.kids -> $kid {
            return $kid.get($id) if $kid.get($id);
        }
        return Nil;
    }

    method add-kid ( :$thing, :$name = '', :$left = False, :@content = [] ) {

        #$name ||= $thing.?name || $thing.^name;

        @!kids.append(
            Node.new(
                :thing(   $thing ),
                :name(    $name  ),
                :content( @content ),
                :$left,
             ));
        @!kids.tail;

    }

    method del-kid ( Int $index ) {
        @!kids.splice( $index, 1);
    }

    method count-nodes ( --> Int ) {
        my $howmany = 1;
        $howmany += $_.count-nodes for @!kids;
        $howmany;
    }


    method dump ( $prefix is copy = '' ) {

        # Have to determine the prefix for the next round of kids in parent,
        # because that's where we know if there are more kids

        # Various unicode box-draw chars - keep for reference
        #   │
        #   ├─
        #   └─
        #   ╰

        my $leading = '';
        given $!thing {
            when Pod::Defn              { $leading = "{$!thing.term}: "    }
            when Pod::Heading           { $leading = "{$!thing.level}: "   }
            when Pod::FormattingCode    { $leading = "{$!thing.type}: "    }
            when Pod::Item              { $leading = "{$!thing.level}: "   }
            when Pod::Block::Table      { $leading = "{$!thing.caption}: " }
        }

        my $trailing = '';
        given $!thing {
            when Pod::Block::Table      { $trailing = ' ' ~ $!thing.headers.join('␤ ') }
        }

        my $content = @!content.join('␤');

        $content ||= "{$!thing.elems} elems" if $!thing ~~ Array;
        $content ||= ".contents {$!thing.?contents.elems} elems" if $!thing.?contents;

        $content = $content.raku if $content ~~ / ^^ \s* $$ /;

        say $prefix, $!id, ' ', $!name, $!left ?? ' ← ' !! ' → ', $leading, $content, $trailing;

        # calc leader for kids
        $prefix.=subst(/\─$/, ' ');         # remove this nodes leader
        $prefix.=subst(/\└\s/, '  ', :g);   # prior last-kid hangover
        $prefix.=subst(/\├\s/, '│ ',:g);    # prior inter-kid hangover

        .dump( $prefix ~ ($_.id == @!kids.tail.id ?? '└─' !! '├─') ) for @!kids;

    }
}