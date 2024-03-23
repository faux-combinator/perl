package FauxCombinator::Lexer;
use Modern::Perl;
use Exporter 'import';
use vars qw(@EXPORT_OK);

@EXPORT_OK = qw(lex);

my $space = qr/[ \t\n]/;

sub adjust_line_col {
  my ($line, $col, $s) = @_;

  my $nl = $s =~ tr/\n//;
  if ($nl) {
    $line += $nl;
    $col = length($s) - rindex($s, "\n") - 1;
  } else {
    $col += length($s) // 0;
  }

  return ($line, $col)
}

sub lex {
  my @tokens;
  my $line = 1;
  my $col = 0;
  my ($rules, $code) = @_;
  part: while ($code) {
    if ($code =~ m/^($space+)/) {
      ($line, $col) = adjust_line_col($line, $col, $1);
      $code = substr $code, length $1;
    }
    for (@$rules) {
      my ($regexp, $type, $mutate) = @$_;
      if ($code =~ /^($regexp)/) {
        my $start = {line => $line, column => $col};
        ($line, $col) = adjust_line_col($line, $col, $1);

        push @tokens, {
          type => $type,
          value => $mutate ? $mutate->($1) : $1,
          start => $start,
          end => {line => $line, column => $col},
        };
        $code = substr($code, length($1));
        next part;
      }
    }
    die "unable to match rule on this code: " . substr($code, 0, 15);
  }
  @tokens
}
