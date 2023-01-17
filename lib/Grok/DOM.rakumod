use v6;


use Kaolin::Node;
use Kaolin::Utils :CompUnit-from-file;

use Grok::Wisp; # <-- TODO: move this to Kaolin
use Grok :grok;

#unit module Grok;   #= prevent GLOBAL:: pollution

#------------------------------------------------------------------------------
our sub load-from-file ( IO::Path:D $file --> CompUnit ) {
    CompUnit-from-file( $file );
}

#------------------------------------------------------------------------------
#| Grok Document-Object-Model - aka Tree of Wisp, e.g. created by Grok::DOM::Factory.create($file)
class Grok::DOM is Kaolin::Node {

    # $!id and $!name in Kaolin::Node;

    has $!type;
    has $!thing = Nil;
    has $!wisp;
    has @!content;

    submethod TWEAK ( |args ) {

        if self.name and not args<thing>:exists {
            # this node is just a name
        }
        else {
            $!thing     ||= args<thing>;
            $!wisp      = Wisp.new(:thing($!thing<>));
            self.name   ||= $!wisp.whom || $!wisp.what;
        }

        #@!content.append( $!wisp.gist, ) unless @!content.elems;
        #say 'TWEAK ', $?CLASS.^name, ;#' --> ', args;

    }
    method type { $!type }
    method thing { $!thing }
    method wisp { $!wisp }
    method content { @!content }

    multi method new ( Mu \thing, |args ) {
        self.bless(:thing(thing),|args)
    }

    method descr ( --> Str ) {
        my $prefix = ': ';
        return $prefix ~ @!content.join(' ') if @!content.elems;
        return '' if self.name and not $!wisp;
        $prefix ~ $!wisp.gist(:notwhom)
    }

}


#------------------------------------------------------------------------------
#| Factory to create DOM - Grok::DOM::Factory.create( IO::Path:D $file ) etc.
class Grok::DOM::Factory {

    use Kaolin::Cargo :Cargo; # exports Cargo

    our $DEBUG = False;

    sub short-name ( Str $name ) {
        $name.split('::').tail
    }

    multi method create ( IO::Path:D $file ) {
        _make-node( CompUnit-from-file( $file ) );
    }

    multi method create ( Mu \x, :$composition ) {

        my $mop = Grok::Moppet.new(:thing(x));

        my $wisp = Wisp.new(:thing(x));
        #say ( $wisp.whom, $wisp.what, $wisp.where, $wisp.why );


        my $root = Grok::DOM.new( :name('grok: ' ~ $wisp.whom ) ) ;
        _make-node( x, $root );

        if $composition {

            if my @parents = $mop.parents.grep({ $_.^name ne ('Any' | 'Mu') }) {
                _make-node(
                    Cargo.new(
                        :name('Parents'),
                        :parts( |@parents ),
                    ),
                   $root,
                );
            }

            if my @roles = $mop.roles {
                _make-node(
                    Cargo.new(
                        :name('Roles'),
                        :parts( |@roles ),
                    ),
                   $root,
                );
            }

            if my @knows = $mop.knows {
                _make-node(
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

    multi sub _make-node ( Mu \x, $parent = Any ) is default {

        #return $node if %GROKED{$x.WHICH}++;
        say 'grok Mu: ', x.HOW.^name, ' ', x.^name, ' ', x.gist if $DEBUG;

        my $mop    = Grok::Moppet.new(:thing(x));

        my $node = $parent  ?? $parent.add-kid( :thing(x) )
                            !! Grok::DOM.new( :thing(x) );

        if $mop.parents.grep({ $_.^name ne ('Any' | 'Mu') }) {
            _make-node(
                Cargo.new(
                    :name('Parents'),
                    :values( $mop.parents.grep({ $_.^name ne ('Any | Mu') })),
                ),
               $node,
            )
        }

        if $mop.roles {
            _make-node(
                Cargo.new(
                    :name('Roles'),
                    :values( $mop.roles ),
                ),
               $node,
            )
        }

        if $mop.exports {
            _make-node(
                Cargo.new(
                    :name('Exports'),
                    :values( $mop.exports ),
                ),
               $node,
            )
        }

        # Knows AFTER exports to supress duplicate-knows
        if $mop.knows {
            _make-node(
                Cargo.new(
                    :name('Knows'),
                    :values( $mop.knows ),  # dont recurse into knows...
                ),
               $node,
            )
        }

        if $mop.attributes {
            _make-node(
                Cargo.new(
                    :name('Attributes'),
                    :values( $mop.attributes ),
                ),
               $node,
            )
        }

        if $mop.methods {
            _make-node(
                Cargo.new(
                    :name('Methods'),
                    :values( $mop.methods ),
                ),
               $node,
            )
        }


    }


    #---------------------------------------------------------------------------
    # We use the Cargo class to package things up for easier grokking
    # It has .name .descr .thing .values .parts
    multi sub _make-node ( Kaolin::Cargo:D \x, $parent = Any ) {

        #return $node if %GROKED{$x.WHICH}++;

        say 'grok Cargo: ', x.name, ' ', x.descr if $DEBUG;

        my \args = \(
                    :name(x.name),
                    :thing(x.thing),
                    :content( x.descr // () ),
                    );

        my $node = $parent  ?? $parent.add-kid( :name(x.name) )
                            !! Grok::DOM.new( :name(x.name) );


        #my $node = $parent ?? $parent.add-kid( |args ) !! $?CLASS.new( |args );

        for x.values -> $y {

            if $y ~~ Pair {
                $node.add-kid(
                    :name($y.key<>),
                    :thing($y.value<>),
                );
            }
            else {
                $node.add-kid(
                    :thing($y<>),
                );
            }
        }

        for x.parts -> $y {
            _make-node( $y ~~ Pair ?? $y.value<> !! $y<>, $node );
        }

        $parent // $node

    }


    #---------------------------------------------------------------------------
    multi sub _make-node ( CompUnit \x , $parent = Nil ) {

        say 'grok CompUnit: ', x.short-name if $DEBUG;

        my $node = $parent  ?? $parent.add-kid( x )
                            !! Grok::DOM.new( x );

        $node.add-kid(
            :name('repo.prefix'),
            :thing( x.repo.prefix ),
            :content(x.repo.prefix.Str)
        ) if try x.repo.prefix;

        $node.add-kid( :name($_<>), :thing(x."$_"() ) )
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
        _make-node( x.distribution, $node );

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
            _make-node( $namespace, $node );
        }

        $parent // $node

    }

    #---------------------------------------------------------------------------
    multi sub _make-node ( CompUnit::Repository::Distribution \x , $parent = Any ) {

        say 'grok Distributon: ', x.gist.substr(0,100) if $DEBUG;

        my $node = $parent  ?? $parent.add-kid( x )
                            !! Grok::DOM.new( x );

        #_make-node( x.dist, $node );
        $node.add-kid( :name('dist.Str'),       :thing(x.dist.Str) );
        $node.add-kid( :name('dist.meta-file'), :thing(x.dist.meta-file) );
        $node.add-kid( :name('dist.prefix'),    :thing(x.dist.prefix)  );

        #        dist
        $node.add-kid( :name($_), :thing(x."$_"() ) )
            for <
                id
                dist-id
                >;

        # Collect the Meta under it's own named node
        # This includes hashes and arrays - should I expand those two?
        my $meta = $node.add-kid( :name('Meta') );
        $meta.add-kid( :name($_.key), :thing($_.value) )
            for x.meta.pairs.sort;

        $parent // $node

    }


    #---------------------------------------------------------------------------
    multi sub _make-node ( Mu \x where { $_.HOW ~~ ( Metamodel::ModuleHOW | Metamodel::PackageHOW ) }, $parent = Any ) {

        say 'grok Package/Module: ', x if $DEBUG;

        my $node = $parent  ?? $parent.add-kid( x )
                            !! Grok::DOM.new( x );

        # Jeff 17-Jan-2023 weirdly, the order in which we get called
        # affects whether .^ver and .^auth are populated

        # Own ver first, then HOW ver - a bit confused as to whether there is ever
        # an own.ver - maybe when grokking a Module defined in memory
        if try x.ver {
            $node.add-kid( :name( 'ver'     ), :thing( x.ver      ) ) if try x.ver;
            $node.add-kid( :name( 'api'     ), :thing( x.api      ) ) if try x.api;
            $node.add-kid( :name( 'auth'    ), :thing( x.auth     ) ) if try x.auth;
            $node.add-kid( :name( 'version' ), :thing( x.version  ) ) if try x.version;
        }
        elsif try x.^ver {
            $node.add-kid( :name( 'ver'     ), :thing( x.^ver     ) ) if try x.^ver;
            $node.add-kid( :name( 'api'     ), :thing( x.^api     ) ) if try x.^api;
            $node.add-kid( :name( 'auth'    ), :thing( x.^auth    ) ) if try x.^auth;
            $node.add-kid( :name( 'version' ), :thing( x.^version ) ) if try x.^version;
        }

        my $mop = Grok::Moppet.new(:thing(x));
        _make-node( $_, $node ) for $mop.knows;

        #{
        #    say 'line: ', $?LINE;
        #    grok(x);
        #
        #} if $mop.exports;

        $parent // $node;



    }

    #---------------------------------------------------------------------------
    multi sub _make-node ( Pair:D \x, $parent ) {

        #return $node if %GROKED{$x.WHICH}++;

        say 'grok - Pair ', x if $DEBUG;


        my $wv = Wisp.new(:thing(x.value));

        my $name = x.key.subst(/^\&/,''); # sub-names, sigh

        my $node;

        if  $name ne short-name($wv.mop.var-name) and
            $name ne short-name($wv.mop.name) {
            # We only create a Pair node if the value does NOT have a name

            say 'key: ', $name, ' not in ', $wv.mop.var-name.raku , ' or ', $wv.mop.name.raku, ' - ', $wv.mop.type
                if $DEBUG;

            $node = $parent ?? $parent.add-kid( x )
                            !! Grok::DOM.new( x );

        }
        else {

            if $wv.mop.is-core {
                #say 'skipped pair node: ', x.gist;
                $node = $parent ?? $parent.add-kid( :name(x.key), :thing(x.value<>) )
                                !! Grok::DOM.new(   :name(x.key), :thing(x.value<>) );
            }
            else {
                _make-node( x.value, $node // $parent );
            }
        }

        # EXPORT<ALL>(...) and EXPORT<DEFAULT>(...) seem to screw this all up
        #say 'pair-value is: ', x.value.^name, ' - ', x.value.raku;
        #_make-node( x.value, $node // $parent );

        $parent // $node

    }





}
