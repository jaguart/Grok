use v6.d+;

use Grok;
use Grok::Wisp;

use lib $?FILE.IO.parent;
use TestNode;

my @a =  1, 2, 3;

my $root = _grok( @a );
$root.dump;


my $id = @*ARGS ?? @*ARGS.shift !! Nil;
dd $root.get($id) if $id.defined;


sub _grok ( Mu $x is raw; :$node is copy ) {

    my $wisp    = Wisp.new(:thing($x));
    my $mop     = $wisp.mop;

    $node = $node ?? $node.add-kid(
                        :thing($wisp),
                        :content( $wisp.gist, )
                        )
                  !! grok-node.new(
                        :thing($wisp),
                        :content( $wisp.gist, )
                        );

    if $mop.knows {
        class Knows {}
        my $wx = Wisp.new(:thing(Knows.new));
        my $nx = $node.add-kid(
                            :thing($wx),
                            :content($wx.gist,)
                        );

        for $mop.knows -> $y {
            my $wy = Wisp.new(:thing($y<>));
            $nx.add-kid(
                :thing($wy),
                :content($wy.gist,)
            );
        }
    }

    if $mop.exports {
        class Exports {}
        my $wx = Wisp.new(:thing(Exports.new));
        my $nx = $node.add-kid(
                            :thing($wx),
                            :content($wx.gist,)
                        );

        for $mop.exports -> $y {
            my $wy = Wisp.new(:thing($y<>));
            $nx.add-kid(
                :thing($wy),
                :content($wy.gist,)
            );
        }
    }


    if $mop.parents {
        class Parents {}
        my $wx = Wisp.new(:thing(Parents.new));
        my $nx = $node.add-kid(
                            :thing($wx),
                            :content($wx.gist,)
                        );

        for $mop.parents -> $y {
            my $wy = Wisp.new(:thing($y<>));
            $nx.add-kid(
                :thing($wy),
                :content($wy.gist,)
            );
        }
    }

    if $mop.roles {
        role Roles {}
        my $wx = Wisp.new(:thing(Roles));
        my $nx = $node.add-kid(
                            :thing($wx),
                            :content($wx.gist,)
                        );

        for $mop.roles -> $y {
            my $wy = Wisp.new(:thing($y<>));
            $nx.add-kid(
                :thing($wy),
                :content($wy.gist,)
            );
        }
    }

    if $mop.attributes {
        class Attributes {};
        my $wx = Wisp.new(:thing(Attributes.new));
        my $nx = $node.add-kid(
                            :thing($wx),
                            :content($wx.gist,)
                        );

        for $mop.attributes -> $y {
            my $wy = Wisp.new(:thing($y<>));
            $nx.add-kid(
                :thing($wy),
                :content($wy.gist,)
            );
        }
    }

    if $mop.methods {
        class Methods {};
        my $wx = Wisp.new(:thing(Methods.new));
        my $nx = $node.add-kid(
                            :thing($wx),
                            :content($wx.gist,)
                        );

        for $mop.methods -> $y {
            my $wy = Wisp.new(:thing($y<>));
            $nx.add-kid(
                :thing($wy),
                :content($wy.gist,)
            );
        }
    }


    $node;
}