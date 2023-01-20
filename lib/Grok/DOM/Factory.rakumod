use v6.d+;

use Kaolin::Cargo   :Cargo;                 #= Carrier for node creation
use Kaolin::Moppet  :Moppet;                #= Introspection
use Kaolin::Utils   :CompUnit-from-file,    #= Load a CompUnit
                    :is-class,              #= Is it a Class
                    :is-role,
                    :is-core-class,
                    :is-package,
                    ;
use Kaolin::Wisp    :Wisp;                  #= Describe things consistently

use Grok::DOM       :DOM;                   #= Document Object Model

#==============================================================================
#| Factory to create DOM - Grok::DOM::Factory.create( IO::Path:D $file ) etc.
unit class Grok::DOM::Factory;


#| helper for comparison of Module shortnames
sub shortname ( Str $name ) {  $name.split('::').tail  }

has @!QUEUE;
has %!DONE;
has $!DEBUG = False;


#------------------------------------------------------------------------------
#| DOM constructor - load and grok a CompUnit by filename
multi method create ( IO::Path:D $file ) {

    %!DONE = Empty;

    self._make-node( CompUnit-from-file( $file ) );

}

#------------------------------------------------------------------------------
#| DOM constructor - introspect Mu
#| - **:deeply**  - recurse into parents, roles etc.
#| - **:core**    - include core classes.
#| - **:local**   - skip composed / imported methods.
#| - **:detail**  - include extra detail.
#| - **:where**   - True - show in-package, False - hide in-package, Default - show imported package names.
#| - **:hide**    - hide this string, used by Scry to remove POD generation artifacts.
multi method create (
    Mu \x,

    :$ascend  is copy = False,
    :$descend is copy = False,
    :$deeply  = False,

    :$local   = False,
    :$filter  = Nil,

    :$core    = False,
    :$detail  = False,
    :$hide    = Nil,

    :$where   = Nil,

) {

    # Jeff 18-Jan-2023 new interface:
    # ascend  -> go up - parents roles backlinks
    # shallow -> exports knows properties attributes methods
    # descend -> expand knows ...
    # deeply  -> ascend and descend
    # filter  -> callable, given THING True to include, False to exclude
    #
    # local   -> only local methods, probably not useful
    # core    -> include core classes
    # detail  -> display - what gets emitted - pass to DOM
    # hide    -> display - filtering - pass to DOM

    $ascend  = True if $deeply;
    $descend = True if $deeply;

    my \opt = \(
        :$ascend  ,
        :$descend ,
        :$deeply  ,
        :$local   ,
        :$filter  ,
        :$core    ,
        :$detail  ,
        :$hide    ,
        :$where   ,
    );
    #say opt, "\n";

    %!DONE = Empty;
    @!QUEUE = Empty;

    my $wisp    = Wisp.new(:thing(x));
    my $mop     = $wisp.mop;
    #say ( $wisp.whom, $wisp.what, $wisp.where, $wisp.whence, $wisp.wax, $wisp.why );

    # root is always a container - we will probably add to it.
    my $root = DOM.new( :name('grok: ' ~ $wisp.whom ) );

    #
    self._make-node( x, $root, |opt );


    # ascend - these are parents and roles added during initial make-node...
    if $ascend {
        # no |opt -> we dont want these to get out of hand.
        for $mop.parents.grep(&not-any-mu) {
            %!DONE = Empty;
            self._make-node( $_<>, $root, );
        }
        for $mop.roles {
            %!DONE = Empty;
            self._make-node( $_<>, $root, );
        }
    }


    if False {

        if my @parents = $mop.parents.grep(&not-any-mu) {
            self._make-node(
                Cargo.new(
                    :name('Parents'),
                    :parts( |@parents ),
                ),
               $root,
            );
        }

        if my @roles = $mop.roles {
            self._make-node(
                Cargo.new(
                    :name('Roles'),
                    :parts( |@roles ),
                ),
               $root,
            );
        }
    }


    if False {

        if my @parents = $mop.parents.grep(&not-any-mu) {
            self._make-node(
                Cargo.new(
                    :name('Parents'),
                    :parts( |@parents ),
                ),
               $root,
            );
        }

        if my @roles = $mop.roles {
            self._make-node(
                Cargo.new(
                    :name('Roles'),
                    :parts( |@roles ),
                ),
               $root,
            );
        }

        if my @knows = $mop.knows {
            self._make-node(
                Cargo.new(
                    :name('Knows'),
                    :parts( |@knows ),
                ),
               $root,
            );
        }
    }


    $root;

}

#==============================================================================
# Subs only below here.
#==============================================================================
sub not-any-mu ( Mu $x ) { $x.^name ne ('Any' | 'Mu')  }



multi method _make-node ( Mu \x,
    $parent = Nil, |opt
) is default {

    return $parent if %!DONE{x.WHICH}++;

    #return $node if %GROKED{$x.WHICH}++;
    say 'grok Mu: ', x.HOW.^name, ' ', x.^name, ' ', x.gist if $!DEBUG;

    my $wisp   = Wisp.new(:thing(x));
    my $mop    = $wisp.mop; # hmmm Moppet.new(:thing(x));

    my $node = $parent  ?? $parent.add-kid( :$wisp )
                        !! DOM.new( :$wisp );

    # NO descent because we DONT pass on opt
    # and we use Cargo.values

    self._make-props( x, $node, $mop, |opt );
    self._make-parts( x, $node, $mop, |opt );


    $parent // $node;

}

sub is-descendant ( \x --> Bool ) {
    my $value := x ~~ Pair ?? x.value<> !! x;

    return False if is-core-class($value);
    return False if $value.^name eq 'EXPORT';

    #dd $x.value; say 'not core ', $x.value.^name;
    return True if is-class( $value );
    return True if is-role( $value );

    False;
}

method _make-parts ( Mu \x, $node, $mop, |opt ) {

    if $mop.parents.grep(&not-any-mu) {
        self._make-node(
            Cargo.new(
                :name('Parents'),
                :values( $mop.parents.grep(&not-any-mu)),
            ),
           $node,
        )
    }

    if $mop.roles {
        self._make-node(
            Cargo.new(
                :name('Roles'),
                :values( $mop.roles ),
            ),
           $node,
        )
    }


    if $mop.exports {
        self._make-node(
            Cargo.new(
                :name('Exports'),
                :values( $mop.exports ),
            ),
           $node,
        );
        #@!QUEUE.append( $mop.exports );
    }

    # Knows AFTER exports to supress duplicate-knows
    if $mop.knows {
        self._make-node(
            Cargo.new(
                :name('Knows'),
                :values( $mop.knows ),  # dont recurse into knows...
            ),
           $node,
        );
        #@!QUEUE.append( $mop.knows );
    }

     {
        if $mop.attributes {
            self._make-node(
                Cargo.new(
                    :name('Attributes'),
                    :values( $mop.attributes ),
                ),
               $node,
            )
        }

        if $mop.methods {
            self._make-node(
                Cargo.new(
                    :name('Methods'),
                    :values( $mop.methods ),
                ),
               $node,
            )
        }
    }

    if opt<descend> {
        if my @interesting = $mop.knows.grep(&is-descendant) {

            # Allow these to be descended into.
            #dd %!DONE;
            %!DONE{$_}:delete for @interesting.values.map({$_ ~~ Pair ?? $_.value.WHICH !! $_.WHICH});
            #.say for @interesting.values.map({$_ ~~ Pair ?? $_.value.WHICH !! $_.WHICH});
            #dd %!DONE;


            self._make-node(
                Cargo.new(
                    :name('Contains'),
                    :parts( |@interesting ), # recurse into these
                ),
               $node,
            );
            #@!QUEUE.append( $mop.knows );
        }
    }


}

multi method xx_make-props ( Mu \x,
    $node,
    |opt
) {
    say x.gist, ' has no properties';
    return $node;
}

#---------------------------------------------------------------------------
#| We use Cargo to wrap things up for easier grokking.
#| It has .name .descr .thing .values .parts.
#| .values are always :shallow
#| .parts  are always :descend
multi method _make-node ( Cargo:D $cargo, $parent = Nil, :$ascend, :$descend, ) {

    #return $node if %GROKED{$x.WHICH}++;

    say 'grok Cargo: ', $cargo.name, ' ', $cargo.descr if $!DEBUG;

    # TODO: NOT WORKING FOR WISPS
    my @values;
    @values.append( $cargo.values.grep({
        my $value = $_ ~~ Pair ?? $_.value<> !! $_<>;
        %!DONE{$value.WHICH} ?? False !! True
        }).flat );
    #dd @values;

    my @parts;
    @parts.append( $cargo.parts.grep({
        my $value = $_ ~~ Pair ?? $_.value<> !! $_<>;
        %!DONE{$value.WHICH} ?? False !! True
        }).flat );
    #if @parts {
    #    dd @parts;
    #    dd %!DONE;
    #    $!DEBUG = True;
    #}


    return $parent unless @parts or @values;

    # The Cargo.name node to act as an identifying collection.
    my $node = $parent  ?? $parent.add-kid( :name($cargo.name) )
                        !! DOM.new(         :name($cargo.name) );


    # Jeff 18-Jan-2023 values are flat - i.e. no descent
    for @values -> $x {
        given $x {
            when Pair {
                next if %!DONE{$x.value<>.WHICH}++;
                my $name = $x.key;
                $name = $x.value.^name if try $name eq $x.value.^shortname;
                $node.add-kid( Wisp.new( :thing($x.value<>), :ident($name) ) );
            }
            when Wisp {
                next if %!DONE{$x.thing<>.WHICH}++;
                $node.add-kid( $x );
            }
            default {
                next if %!DONE{$x.WHICH}++;
                $node.add-kid( Wisp.new( :thing($x<>) ) );
            }

        }
        #if $x ~~ Pair {
        #    next if %!DONE{$x.value<>.WHICH}++;
        #    my $name = $x.key;
        #    $name = $x.value.^name if try $name eq $x.value.^shortname;
        #    $node.add-kid( Wisp.new( :thing($x.value<>), :ident($name) ) );
        #}
        #else {
        #    next if %!DONE{$x.WHICH}++;
        #    $node.add-kid( Wisp.new( :thing($x<>) ) );
        #}
    }

    # Jeff 18-Jan-2023 parts are always descended into

    for @parts -> $x {
        # Hmmm we lose the ident here
        #dd $x;

        # in case an interesting part was mentioned by a sibling...
        if $cargo.name eq 'Contains' {
            %!DONE{$_}:delete for @parts.map({$_ ~~ Pair ?? $_.value.WHICH !! $_.WHICH});
        }

        self._make-node(
            ($x ~~ Pair ?? $x.value<> !! $x<>),
            $node
        );
    }

    $parent // $node

}


#---------------------------------------------------------------------------
multi method _make-node ( CompUnit \x , $parent = Nil,  :$ascend, :$descend, ) {

    return $parent if %!DONE{x.WHICH}++;

    say 'grok CompUnit: ', x.short-name if $!DEBUG;

    my $node = $parent  ?? $parent.add-kid( x )
                        !! DOM.new( x );

    $node.add-kid(
        Wisp.new( :thing(x.repo.prefix), :ident('repo.prefix') )
    ) if try x.repo.prefix;

    $node.add-kid( Wisp.new(:ident($_<>), :thing(x."$_"() ) ) )
        for <
            short-name
            repo-id
            version
            api
            auth
            from
            >;

    # delve into Distribution for this run/compunit
    # Note that this may NOT be the distribution of the CompUnit
    # if you are running in a folder with a META6.json
    self._make-node( x.distribution, $node );

    # recurse into namespaces created by this compunit
    # GLOBALish is the set of namespaces that were merged into GLOBAL::
    # Note that the order changes, so needs a sort to be consistent.
    for x.handle.globalish-package.values
        # Jeff 17-Jan-2023 weird - Module loses its ver/auth if it
        # is groked AFTER an inferred package (e.g. Bob from Bob::Apple)
        # so we sort by HOW.^name - Classes, Modules, Packages...
        .sort({ $^a.HOW.^name cmp $^b.HOW.^name or $^a.^name cmp $^b.^name })
        -> $namespace {
         #say 'name: ', $namespace.HOW.^name, ' ', $namespace.^name;
        self._make-node( $namespace, $node );
    }

    $parent // $node

}

#---------------------------------------------------------------------------
multi method _make-node ( CompUnit::Repository::Distribution \x , $parent = Nil, :$ascend, :$descend, ) {

    return $parent if %!DONE{x.WHICH}++;

    say 'grok Distributon: ', x.gist.substr(0,100) if $!DEBUG;

    my $node = $parent  ?? $parent.add-kid( x )
                        !! DOM.new( x );

    #_make-node( x.dist, $node );
    $node.add-kid( Wisp.new( :ident('dist.Str'),       :thing(x.dist.Str)       ));
    $node.add-kid( Wisp.new( :ident('dist.meta-file'), :thing(x.dist.meta-file) ));
    $node.add-kid( Wisp.new( :ident('dist.prefix'),    :thing(x.dist.prefix)    ));

    #        dist
    $node.add-kid( Wisp.new( :ident($_), :thing(x."$_"() ) ))
        for <
            id
            dist-id
            >;

    # Collect the Meta under it's own named node
    # This includes hashes and arrays - should I expand those two?
    my $meta = $node.add-kid( :name('Meta') );
    $meta.add-kid( Wisp.new( :ident($_.key), :thing($_.value) ))
        for x.meta.pairs.sort;

    $parent // $node

}


#---------------------------------------------------------------------------
multi method _make-props ( Mu \x,
    $node,
    |opt
) {

    #return $node if %!DONE{x.WHICH}++;

    say 'grok Package/Module properties: ', x if $!DEBUG;

    my $mop = Moppet.new(:thing(x));

    # Jeff 17-Jan-2023 weirdly, the order in which we get called
    # affects whether .^ver and .^auth are populated

    # Own ver first, then HOW ver - a bit confused as to whether there is ever
    # an own.ver - maybe when grokking a Module defined in memory
    my @props;
    @props.append( Wisp.new( :ident( 'ver' ), :thing( $mop.ver  ))) if $mop.ver;
    @props.append( Wisp.new( :ident( 'api' ), :thing( $mop.api  ))) if $mop.api;
    @props.append( Wisp.new( :ident( 'auth'), :thing( $mop.auth ))) if $mop.auth;
    @props.append( Wisp.new( :ident( 'why' ), :thing( $mop.why  ))) if $mop.why;
    @props.append( Wisp.new( :ident( 'archetypes' ), :thing( $mop.archetypes  ))) if $mop.archetypes;
    @props.append( Wisp.new( :ident( 'lang' ), :thing( $mop.language-version  ))) if $mop.language-version;

    # Jeff 19-Jan-2023 not yet working...
    #say x.gist, x.^name, x.HOW.^name;
    #say $mop.archetypes;
    #say $mop.language-version;


    self._make-node(
        Cargo.new(
            :name('Properties'),
            :values( |@props ),
        ),
       $node,
    )
    if @props;

}

#---------------------------------------------------------------------------
multi method x_make-node ( Pair:D \x, $parent = Nil, :$ascend, :$descend, ) {

    #return $node if %GROKED{$x.WHICH}++;

    say 'grok - Pair ', x.raku if $!DEBUG or True;

    my $name = x.key.subst(/^\&/,''); # sub-names, sigh

    my $wv = Wisp.new(:thing(x.value<>),:ident($name));

    my $node;

    if  False and $name ne shortname($wv.mop.var-name) and
        $name ne shortname($wv.mop.name) {
        # We only create a Pair node if the value does NOT have a name

        say 'key: ', $name, ' not in ', $wv.mop.var-name.raku , ' or ', $wv.mop.name.raku, ' - ', $wv.mop.type
            if $!DEBUG or True;

        $node = $parent ?? $parent.add-kid( x )
                        !! DOM.new( x );

    }
    else {

        if $wv.mop.is-core {
            #say 'skipped pair node: ', x.gist;
            $node = $parent ?? $parent.add-kid( $wv )
                            !! DOM.new( $wv );
        }
        else {
            self._make-node( x.value, $node // $parent );
        }
    }

    # EXPORT<ALL>(...) and EXPORT<DEFAULT>(...) seem to screw this all up
    #say 'pair-value is: ', x.value.^name, ' - ', x.value.raku;
    #_make-node( x.value, $node // $parent );

    $parent // $node

}

#==============================================================================
