use Modern::Perl;
use lib 'lib/'; # <- bad!
use Test;
BEGIN { plan tests => 8 }

use FauxCombinator::Lexer 'lex';

my @rules = (
  [ qr/=/, 'eq' ],
);
my $eq_token = {type => 'eq', value => '='};

ok lex(\@rules, ''), [],
  "can parse empty strings (if needed...)";

ok lex(\@rules, '='), [$eq_token],
  "basic parsing works";
ok lex(\@rules, '=='), [$eq_token, $eq_token],
  "can parse multiple occurences";
ok lex(\@rules, '= ='), [$eq_token, $eq_token],
  "can parse multiple, space-separated occurences";

my @rules = (
  [ qr/=/, 'eq' ],
  [ qr/-/, 'dash' ],
  [ qr/_/, 'under' ],
);
my $dash_token = {type => 'dash', value => '-'};
my $under_token = {type => 'under', value => '_'};

ok lex(\@rules, '='), [$eq_token], "multiple rules can find first";
ok lex(\@rules, '-'), [$dash_token], "multiple rules can find second";
ok lex(\@rules, '_'), [$under_token], "multiple rules can find third";

ok lex(\@rules, '=-_'), [$eq_token, $dash_token, $under_token], "multiple rules can match all";
ok lex(\@rules, '=-  _'), [$eq_token, $dash_token, $under_token], "multiple rules can match all with space separation";

# TODO: add tests for [ qr/x/, y, sub {} ] form
