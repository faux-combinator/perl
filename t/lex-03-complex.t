use Modern::Perl;
use lib 'lib/'; # <- bad!
use Test::More;
BEGIN { plan tests => 5 }

use FauxCombinator::Lexer 'lex';

my @rules = (
  [ qr/=/, 'eq' ],
  [ qr/-/, 'dash' ],
  [ qr/_/, 'under' ],
);
my $eq_token = {type => 'eq', value => '='};
my $dash_token = {type => 'dash', value => '-'};
my $under_token = {type => 'under', value => '_'};

is_deeply [lex(\@rules, '=')], [$eq_token],
  "multiple rules can find first";
is_deeply [lex(\@rules, '-')], [$dash_token],
  "multiple rules can find second";
is_deeply [lex(\@rules, '_')], [$under_token],
  "multiple rules can find third";

is_deeply [lex(\@rules, '=-_')], [$eq_token, $dash_token, $under_token],
  "multiple rules can match all";
is_deeply [lex(\@rules, '=-  _')], [$eq_token, $dash_token, $under_token],
  "multiple rules can match all with space separation";
