use v6d+;

use Grok::Moppet;

#------------------------------------------------------------------------------
#| A prettier .gist from MOP for almost anything.
#| .gist  from .ident .whom .what .where .detail .why.
#| .mop is accessible - possible anti-pattern - maybe we should delegate?
#------------------------------------------------------------------------------
unit class Wisp is export;

has Mu    $.thing is built(:bind);
has Grok::Moppet $.mop;

has Str   $!ident = '';   # External name/identity
has Str   $!whom = '';    # Who I think I am
has Str   $!what = '';    # What am I
has Str   $!where = '';   # Where am I
has Str   $!detail = '';  # Extra details that I only reveal when asked
has Str   $!why = '';     # Why I am

has Bool $!debug = False;

#------------------------------------------------------------------------------
submethod TWEAK {

  $!mop = Moppet.new( :thing($!thing ) ) unless $!mop;

  #    say 'wisp.ident   ', $!ident;
  #try say 'thing.ident: ', $!thing.ident;
  #try say 'thing.name:  ', $!thing.name;
  #try say 'mop.ident:   ', $!mop.ident;

  $!whom =  $!mop.ident         ||    # sometimes we have an external identity
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


  my $type = $!whom ne $!mop.type ?? $!mop.which || $!mop.type || '' !! '';
  $type = '' if $!mop.subtype and $!mop.type eq 'Attribute';

  my $supertype =  $!mop.not-core || $!mop.not-class ?? $!mop.supertype !! '';
  $supertype = '' if $supertype eq 'Class'; # noise vs signal?


    $!what    = (
                 ($!mop.name eq $!whom | '<anon>' | $type ).so ?? '' !! $!mop.name,
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

    # Add Parents and Roles
    if $!what eq $!mop.supertype {
      $!what ~= ' is: ' ~ $!mop.parent-names.join(' ') if $!mop.parent-names.elems;
      $!what ~= ' does: ' ~ $!mop.role-names.join(' ') if $!mop.role-names.elems;
    }
    $!what ~= ' enums: ' ~ $!mop.enum-names.join(' ') if $!mop.enum-names.elems;

    $!where = '';
    $!where = $!mop.package(:prefix('in '))
       unless $!mop.package eq $!whom;
#      unless set $!whom, $!what, $type (&) $!mop.package;

    # Failed on ForeignCode
    #$!where   = (
    #              ($!mop.package ne $!whom ?? $!mop.package(:prefix('in ')) !! ''),
    #            ).grep(*.chars).unique.join(' ');

    #say 'where:   ', $!where;


  #}

  # Jeff 01-Jan-2023 keep this useful debug
  #$!where ~= ' ' ~ $!thing.WHICH if try $!thing.WHICH;


    $!detail   = (
                  $!mop.file,
                ).grep(*.chars).unique.join(' ');

  # POD or Exception Message
  $!why     = S:g/ \n / \c[SYMBOL FOR NEWLINE] / given ( $!mop.why || $!mop.message );



}

# whom  - ident || name + signature
# what  - name if ident, subtype type supertype origin
# where - further details
# why   - declarators

# $notware can be:
#   False -> no $where is displayed,
#   Str   -> $!where is not displayed if it is the same as the Str value
method gist ( :$format="%s", :$detail = False, :$notwhere = False, :$debug = $!debug --> Str ) {

  #say 'ident:  ', $!ident;
  #say 'whom:   ', $!whom;
  #say 'what:   ', $!what;
  #say 'where:  ', $!where;
  #say 'detail: ', $!detail;
  #say 'why:    ', $!why;

  # Note that $detail forces inclusion of $!where
  # and overrides any setting in $notwhere
  my $where = $!where;
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
      ( $detail   ?? $!detail   !! '' ),
      ( $!why ?? ('#', $!why )  !! () ),
      ($debug ?? 'by ' ~ self.^name !! '' ),
    )
    .map({ $debug ?? ($_, '‧') !! $_ })
    .grep( *.chars )
    .join(' ');

}

  # Accessors - but not constructor args.
  method ident  { $!ident   }
  method whom   { $!whom    }
  method what   { $!what    }
  method where  { $!where   }
  method detail { $!detail  }
  method why    { $!why     }



