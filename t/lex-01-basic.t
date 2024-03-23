use Modern::Perl;
use lib 'lib/'; # <- bad!
use Test::More;
BEGIN { plan tests => 4 }

use FauxCombinator::Lexer 'lex';

my @rules = (
  [ qr/=/, 'eq' ],
);
sub eq_token {
  my ($line, $col) = @_;
  {
    type => 'eq',
    value => '=',
    start => {line => $line, column => $col},
    end => {line => $line, column => $col + 1},
  }
}

is_deeply [lex(\@rules, '')], [],
  "can parse empty strings (if needed...)";

is_deeply [lex(\@rules, '=')], [eq_token(1, 0)],
  "basic parsing works";
is_deeply [lex(\@rules, '==')], [eq_token(1, 0), eq_token(1, 1)],
  "can parse multiple occurences";
is_deeply [lex(\@rules, '= =')], [eq_token(1, 0), eq_token(1, 2)],
  "can parse multiple, space-separated occurences";

