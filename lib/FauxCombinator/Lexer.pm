package FauxCombinator::Lexer;
use Modern::Perl;
use Exporter 'import';
use vars qw(@EXPORT_OK);

@EXPORT_OK = qw(lex);

my $space = qr/[ \t\n]/;

sub lex {
  my @tokens;
  my ($rules, $code) = @_;
  part: while ($code) {
    $code =~ s/^$space+//;
    for (@$rules) {
      my ($regexp, $type, $mutate) = @$_;
      if ($code =~ /^($regexp)/) {
        push @tokens, {
          type => $type,
          value => $mutate ? $mutate->($1) : $1
        };
        $code = substr($code, length($1));
        $code =~ s/^$space+//;
        next part;
      }
    }
    die "unable to match rule on this code: " . substr($code, 0, 15);
  }
  @tokens
}
