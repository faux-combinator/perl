use Modern::Perl;
use lib 'lib/'; # <- bad!
use lib 't/';
use Test::More;
use helper;
BEGIN { plan tests => 1 }

use FauxCombinator::Lexer 'lex';

my @rules = (
  [ qr/[A-Z]+/, 'id', sub { lc shift } ],
);

my $id_abc = tok('id', 'abc');
my $id_def = tok('id', 'def');
is_deeply [lex(\@rules, 'ABC DEF')], [$id_abc->(1, 0), $id_def->(1, 4)],
  "mutators can access and mutate values";
