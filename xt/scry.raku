use v6;

use Grok;

#use Pod::Load;
#use X::Pod::Load::SourceErrors;
#
## Or use simply the file name
#my @pod = load("lib/Grok.rakumod");
#say .raku for @pod;
#

#use MONKEY-SEE-NO-EVAL;

my $source-file = @*ARGS ?? @*ARGS.shift !! 'lib/Grok.rakumod';

#my $source = 'lib/Grok.rakumod'.IO.slurp;
my $source = $source-file.IO.slurp;


my $module-name = "_m{(rand*100_000_000).Int}";
say $module-name;

# Must be first if present
my $p6v;
$source.=subst(/^(\s*use\s+v6\S+)/, { "# $0" });
say ' changed ', $/.elems, ' elems';
#dd $/;
for $/ -> $m {
    say 'changed: ', $m.Str;
    $p6v ||= $m.Str;
}

# unit module Grok;
# unit class Grok;
my $closes = '';
$source.=subst(/ ^^ \s* 'unit' \s+ ( [ 'module' || 'class' ] \s+ .+? ) \; /, {"$0 \{"});
if $/ {
    say ' changed ', $/.elems, ' elems';
    for $/ -> $m {
        say 'changed: ', $m.Str;
        $closes ~= '}';
    }
    say 'closes: ', $closes.raku;
}

my $wrapped = (
        $p6v,
        "module {$module-name} \{",
        $source,
         '}',
         $closes,
         '$=pod;',
     )
     .grep( *.?chars )
     .join("\n");

say $wrapped.substr(0,50);

my @pod    = $wrapped.EVAL;
#dd @pod;

say 'raku: ', @pod.raku;

grok( GLOBAL::{$module-name}, :deeply, :hide($module-name ~ '::')  );


=begin pod

# Thanks to ugexe and Zef and skaji
my @mi6run-invoke = BEGIN $*DISTRO.is-win ?? <cmd.exe /x/d/c>.Slip !! '';
sub mi6run(*@_, *%_) is export { run (|@mi6run-invoke, |@_).grep(*.?chars), |%_ }

method generate-readme($file) {
    #my $section = "ReadmeFromPod";
    #my $default = "";
    #return if config($section, "enabled", :$default) eq "false" ;
    #my $file = config($section, "filename", :$default) || $module-file;

    my @cmd = $*EXECUTABLE, "-I$*CWD", "--doc=Markdown", $file;
    my $p = mi6run |@cmd, :out;
    LEAVE $p && $p.out.close;
    die "Failed @cmd[]" if $p.exitcode != 0;
    my $markdown = $p.out.slurp;
    my $header = self.readme-header();
    spurt "README.md", $header ~ $markdown;
}

method readme-header() {
    #my ($user, $repo) = guess-user-and-repo();
    #return "" if !$user;
    #my $badges = config("Badges", default => []);
    #if @$badges == 0 && ".travis.yml".IO.e {
    #    push $badges, (provider =>"travis-ci.org");
    #}
    #return "" if @$badges == 0;
    #
    #my @markdown;
    #for @$badges -> $badge {
    #    die "unknown key Badges.{$badge.key} in dist.ini" if $badge.key ne "provider";
    #    my $provider = $badge.value;
    #    my $name = "test";
    #    if $provider ~~ rx{ (.+) '/' (.+) } {
    #        $provider = $/[0];
    #        $name = $/[1];
    #    }
    #    my $b = App::Mi6::Badge.new(:$user, :$repo, :$provider, :$name);
    #    push @markdown, $b.markdown();
    #}
    #return @markdown.join(" ") ~ "\n\n";
    return '';
}


=end pod