# Jeff 05-Jan-2023 - looking into tree traversal
# dfs           - depth first search
# bfs           - breadth first search
# dfs-inorder   - LNR - left node right - requires kids to be classified as left or right
# dfs-preorder  - NLR - node left right - doesnt actually need kids in left / right groups
# dfs-postorder - LRN - left right node - doesnt actually need kids in left / right groups
# bfs-level     - use a FIFO queue
class node {

    our @bf-queue;

    has $.id;
    has @.kids is rw;
    has $.left = False; # node is a left kid of parent

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


}

my $a = node.new(:id(1));

$a.get(1).kids.push( node.new(:id(2),:left), node.new(:id(3)) );

$a.get(2).kids.push( node.new(:id(4),:left), node.new(:id(5)) );
$a.get(3).kids.push( node.new(:id(6),:left), node.new(:id(7)) );

$a.get(4).kids.push( node.new(:id(8),:left) );
$a.get(6).kids.push( node.new(:id(9), :left), node.new(:id(10))  );


say "dfs-inorder    : ", $a.dfs-inorder.join(' ');
say "expect         : 8 4 2 5 1 9 6 10 3 7\n";

say "dfs-preorder   : ", $a.dfs-preorder.join(' ');
say "expect         : 1 2 4 8 5 3 6 9 10 7\n";

say "dfs-postorder  : ", $a.dfs-postorder.join(' ');
say "expect         : 8 4 5 2 9 10 6 7 3 1\n";

say "bfs-level      : ", $a.bfs-level.join(' ');
say "expect        : 1 2 3 4 5 6 7 8 9 10\n";

