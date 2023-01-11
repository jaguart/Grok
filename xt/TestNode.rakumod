class node {

    our $ID_FOUNTAIN = 0;

    our @bf-queue;

    has $!id;


    has @.kids is rw;
    has $.left = False; # node is a left kid of parent

    submethod TWEAK {
        $!id = $ID_FOUNTAIN++;
    }

    # Helper to construct tree
    method get ( $id ) {
        return self if $!id == $id;
        for @.kids -> $kid {
            return $kid.get($id) if $kid.get($id);
        }
        return Nil;
    }

    method dfs-inorder {
        # for inorder in n-ary trees - kids must be classified as left or right.
        my @ids;
        for @.kids -> $kid {
            @ids.append( $kid.dfs-inorder ) if $kid.left;
        }
        @ids.push( $!id );
        for @.kids -> $kid {
            @ids.append( $kid.dfs-inorder ) unless $kid.left;
        }
        @ids;
    }

    method dfs-preorder {
        my @ids;
        @ids.append( $_.dfs-preorder ) for @!kids;
        @ids.prepend($!id);
        @ids;
    }

    method dfs-postorder {
        my @ids;
        @ids.append( $_.dfs-postorder ) for @!kids;
        @ids.push($!id);
        @ids;
    }

    method bfs-level {
        my @ids;

        @bf-queue.append( @!kids ); # add our kids to the queue

        @ids.push($!id);
        while @bf-queue.shift -> $node {
            @ids.append( $node.bfs-level );
        }

        @ids;

    }

    method descr { '' }

    method dump ( $prefix is copy = '', $lastkid = False ) {

        # Have to determine the prefix for the next round of kids in parent,
        # because that's where we know if there are more kids

        # Various unicode box-draw chars - keep for reference
        #   │
        #   ├─
        #   └─
        #   ╰

        say $prefix, $!id, $!left ?? ' ← ' !! ' → ', self.descr;

        $prefix.=subst(/\─$/, ' ');         # remove this nodes leader
        $prefix.=subst(/\└\s/, '  ', :g);   # prior last-kid continuation
        $prefix.=subst(/\├\s/, '│ ',:g);    # prior inter-kid continuation

        .dump($prefix ~ ($_.id == @!kids.tail.id ?? '└─' !! '├─') ) for @!kids;
    }

    method add-kid ( |args ) {
        @!kids.append( self.WHAT.new( |args ) );
        @!kids.tail;
    }

    method id { $!id }



}

# a grok-node is a little subtree created by groking a thing
class grok-node is node {

    has $.thing;
    has @.content;

    method descr {
        @!content.join(' ');
    }


}
