use Modern::Perl;
use lib 'lib/'; # <- bad!
use Test::More;
BEGIN { plan tests => 1 }

use FauxCombinator::Lexer 'lex';

my @rules = (
  [ qr/[A-Z]+/, 'id', sub { lc shift } ],
);
my $id_token1 = {type => 'id', value => 'abc'};
my $id_token2 = {type => 'id', value => 'def'};
is_deeply [lex(\@rules, 'ABC DEF')], [$id_token1, $id_token2],
  "mutators can access and mutate values";
