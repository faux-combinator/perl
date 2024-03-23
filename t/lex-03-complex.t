use Modern::Perl;
use lib 'lib/'; # <- bad!
use lib 't/';
use Test::More;
use helper;

use FauxCombinator::Lexer 'lex';

my @rules = (
  [ qr/=/, 'eq' ],
  [ qr/-/, 'dash' ],
  [ qr/_/, 'under' ],
);

my $eq_token = tok('eq', '=');
my $dash_token = tok('dash', '-');
my $under_token = tok('under', '_');

is_deeply [lex(\@rules, '=')], [$eq_token->(1, 0)],
  "multiple rules can find first";
is_deeply [lex(\@rules, '-')], [$dash_token->(1, 0)],
  "multiple rules can find second";
is_deeply [lex(\@rules, '_')], [$under_token->(1, 0)],
  "multiple rules can find third";

is_deeply [lex(\@rules, '=-_')], [$eq_token->(1, 0), $dash_token->(1, 1), $under_token->(1, 2)],
  "multiple rules can match all";
is_deeply [lex(\@rules, '=-  _')], [$eq_token->(1, 0), $dash_token->(1, 1), $under_token->(1, 4)],
  "multiple rules can match all with space separation";

is_deeply [lex(\@rules, "=- \n\n\n  _")],
  [$eq_token->(1, 0), $dash_token->(1, 1), $under_token->(4, 2)],
  "multiple rules can match all with space separation";

done_testing;
