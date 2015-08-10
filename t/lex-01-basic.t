use Modern::Perl;
use lib 'lib/'; # <- bad!
use Test::More;
BEGIN { plan tests => 4 }

use FauxCombinator::Lexer 'lex';

my @rules = (
  [ qr/=/, 'eq' ],
);
my $eq_token = {type => 'eq', value => '='};

is_deeply [lex(\@rules, '')], [],
  "can parse empty strings (if needed...)";

is_deeply [lex(\@rules, '=')], [$eq_token],
  "basic parsing works";
is_deeply [lex(\@rules, '==')], [$eq_token, $eq_token],
  "can parse multiple occurences";
is_deeply [lex(\@rules, '= =')], [$eq_token, $eq_token],
  "can parse multiple, space-separated occurences";

