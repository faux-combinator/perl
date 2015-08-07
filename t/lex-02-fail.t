use Modern::Perl;
use lib 'lib/'; # <- bad!
use Test;
BEGIN { plan tests => 1; }

use FauxCombinator::Lexer 'lex';

eval { lex([], "="); };
ok($@);
