use v6d+;

use Grok::Moppet;

#------------------------------------------------------------------------------
#| A prettier .gist from MOP for almost anything.
#| .gist   from .ident .whom .what .where .why
#| .detail from .ident .whom .what .where .whence .wax .why
#| .mop is accessible - possible anti-pattern - deprecate or delegate?
#------------------------------------------------------------------------------
unit class Wisp is export;

has Mu              $.thing is built(:bind);
has Grok::Moppet    $.mop;

has Str             $!ident   = '';   #= External identity
has Str             $!whom    = '';   #= Who I think I am
has Str             $!what    = '';   #= What am I
has Str             $!where   = '';   #= Where am I
has Str             $!whence  = '';   #= Whence I came from - File/Line
has Str             $!wax     = '';   #= Wax - detail I only reveal when asked
has Str             $!why     = '';   #= Why I am

#------------------------------------------------------------------------------
submethod TWEAK {

    $!mop = Moppet.new( :thing($!thing ) ) unless $!mop;

    $!whom =    $!mop.ident         ||    # sometimes we have an external identity
                $!mop.var-name      ||    # sometimes we are a var
                $!mop.name          ||    # sometimes we have a name
                $!mop.type          ||    # sometimes we are a Type
                $!thing.Str               # hmmm, we always need a $!whom
                ;

    #say '^name:     ', $!mop.thing.^name;
    #say 'subtype:   ', $!mop.subtype; # proto multi private etc
    #say 'type:      ', $!mop.type;    # just the base type
    #say 'which:     ', $!mop.which;   # includes any mixins
    #say 'supertype: ', $!mop.supertype;
    #say 'is-core:   ', $!mop.is-core;
    #say 'is-class:  ', $!mop.is-class;

    # Jeff 05-Jan-2023 note that the !$mop.which includes the +{is_hidden_from_backtrace} etc.
    # I may remove that in future and put it into detail.

    my  $type = $!whom ne $!mop.type ?? $!mop.which || $!mop.type || '' !! '';
        $type = '' if $!mop.subtype and $!mop.type eq 'Attribute';

    my  $supertype  =  $!mop.supertype;
        $supertype  = '' if $supertype eq 'Class'; # noise vs signal?

    my  $name       = $!mop.name;
        $name       = '' if ($name eq $!whom | '<anon>' | $type ).so;

    $!what  = (
                $name,
                $!mop.signature // '',
                $!mop.subtype //'',
                $type,
                $!mop.descr,
                $supertype,
              )
              .grep(*.chars)
              .join(' ');

    #say ': name      ', ($!mop.name ne $!whom and $!mop.name ne '<anon>') ?? $!mop.name !! '',     ;
    #say ': signiture ', $!mop.signature // '',                                                     ;
    #say ': subtype   ', $!mop.subtype //'',                                                        ;
    #say ': type      ', $type,                                                                     ;
    #say ': descr     ', $!mop.descr,                                                               ;
    #say ': supertype ', $supertype,                                                                ;

    $!what ||= $!mop.supertype;

    #say 'whom:    ', $!whom;
    #say 'what:    ', $!what;
    #say 'type:    ', $type;
    #say 'package: ', $!mop.package;

    # Add Parents and Roles for Classes
    if $!what eq $!mop.supertype {
        $!what ~= ' is: '   ~ $!mop.parent-names.join(' ')  if $!mop.parent-names.elems;
        $!what ~= ' does: ' ~ $!mop.role-names.join(' ')    if $!mop.role-names.elems;
    }
    $!what ~= ' enums: ' ~ $!mop.enum-names.join(' ') if $!mop.enum-names.elems;

    $!where = $!mop.package;

    $!whence = (
                $!mop.file,
               ).grep(*.chars).unique.join(' ');

    # POD or Exception Message - with NL subst
    $!why = S:g/\n/\c[SYMBOL FOR NEWLINE]/ given ( $!mop.why || $!mop.message );

}

# $notware can be:
#   False -> no $where is displayed,
#   Str   -> $!where is not displayed if it is the same as the Str value
method gist ( :$format="%s", :$detail = False, :$notwhere = False, --> Str ) {

    #say 'ident:  ', $!ident;
    #say 'whom:   ', $!whom;
    #say 'what:   ', $!what;
    #say 'where:  ', $!where;
    #say 'whence: ', $!whence;
    #say 'wax:    ', $!wax;
    #say 'why:    ', $!why;

    # Note that $detail forces inclusion of $!where $!whence $!wax and overrides $notwhere
    my  $where = $!where ?? 'in '~$!where !! '';
        $where = '' if $!where eq $!whom;

    if not $detail {
        given $notwhere {
            when Str  { $where = '' if $notwhere and $where.contains($notwhere) }
            when Bool { $where = '' if $notwhere.so }
        }
    }

    my $divider = '-';

    (
      $format.sprintf($!whom),
      $divider,
      $!what,
      $where,
      ( $detail     ?? $!whence   !! '' ),
      ( $detail     ?? $!wax      !! '' ),
      ( $!why ?? ('#', $!why )    !! () ),
    )
    .grep( *.chars )
    .join(' ');

}

method ident  ( --> Str ) { $!ident   } #= identity - external
method whom   ( --> Str ) { $!whom    } #= who I am - name
method what   ( --> Str ) { $!what    } #= what I am - subtype, type, supertype
method where  ( --> Str ) { $!where   } #= where I am - namespace
method whence ( --> Str ) { $!whence  } #= whence I came from - file/line
method wax    ( --> Str ) { $!wax     } #= additional wax - extended detail
method why    ( --> Str ) { $!why     } #= Pod declarator content. RAKUDO_POD_DECL_BLOCK_USER_FORMAT=1


# TODO: rejig this detail
