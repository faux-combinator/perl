use Modern::Perl;
use lib 'lib/'; # <- bad!
use lib 't/';
use Test::More;
use helper;
BEGIN { plan tests => 5 }

use FauxCombinator::Parser;

my $lparen_token = tok('lparen', '(');
my $rparen_token = tok('rparen', ')');
my $eq_token = tok('eq', '=');
my $dash_token = tok('dash', '-');
my $under_token = tok('under', '_');

# Test::More is just *broken*...
# I need those `pass`es, otherwise, it... does strange stuff
# (basically, it swaps the order of the subtest names -.-)
subtest '->expect()', sub {
  plan tests => 2;

  my $parse = sub {
    my $parser = FauxCombinator::Parser::new(shift);
    $parser->expect('lparen');
    $parser->expect('rparen')->{type};
  };

  {
    my @tokens = ($lparen_token->(1, 0), $rparen_token->(1, 1));
    is $parse->(\@tokens), 'rparen',
      "it parses";
  }

  {
    my @tokens = ($eq_token->(1, 0));
    eval { $parse->(\@tokens) };
    like $@, qr/expected lparen, found eq at 1:0 - 1:1/, "it checks arguments";
  }
};

subtest '->try()', sub {
  plan tests => 3;

  my $parse = sub {
    my $parser = FauxCombinator::Parser::new(shift);
    $parser->expect('lparen');
    $parser->try(sub { $parser->expect('eq') });
    $parser->expect('rparen');
    1;
  };

  {
    my @tokens = ($lparen_token->(1, 0), $rparen_token->(1, 0));
    ok $parse->(\@tokens),
      "maybe tokens are optional";
  }

  {
    my @tokens = ($lparen_token->(1, 0), $eq_token->(1, 1), $rparen_token->(1, 2));
    ok $parse->(\@tokens),
      "it matches optional tokens";
  }

  {
    my @tokens = ($lparen_token->(1, 0), $dash_token->(1, 1), $rparen_token->(1, 2));
    eval { $parse->(\@tokens) };
    like $@, qr/expected rparen, found dash at 1:1 - 1:2/, "optional tokens are checked";
  }
};

subtest '->one_of()', sub {
  plan tests => 5;

  my $parse = sub {
    my $parser = FauxCombinator::Parser::new(shift);
    $parser->one_of(
      sub { $parser->expect('eq') },
      sub { $parser->expect('dash') },
      sub { $parser->expect('under') },
    )->{type}
  };

  {
    my @tokens = ($eq_token->(1, 0));
    is $parse->(\@tokens), 'eq',
      "one_of can match first case";
  }

  {
    my @tokens = ($dash_token->(1, 0));
    is $parse->(\@tokens), 'dash',
      "one_of can match second case";
  }

  {
    my @tokens = ($under_token->(1, 0));
    is $parse->(\@tokens), 'under',
      "one_of can match third case";
  }

  {
    my @tokens = ();
    eval { $parse->(\@tokens) };
    like $@, qr/unable to parse one_of/, "one_of still requires a token";
  }

  {
    my @tokens = ($lparen_token->(1, 0));
    eval { $parse->(\@tokens) };
    like $@, qr/unable to parse one_of at 1:0 - 1:1/, "one_of doesn't allow any token";
  }
};

subtest '->any_of()', sub {
  plan tests => 3;

  my $parse = sub {
    my $parser = FauxCombinator::Parser::new(shift);
    $parser->any_of(sub { $parser->expect('eq')->{value} });
  };

  {
    my @tokens = ();
    is_deeply $parse->(\@tokens), [],
      "can parse zero ocurrences";
  }

  {
    my @tokens = ($eq_token->(1, 0));
    is_deeply $parse->(\@tokens), ['='],
      "can parse one ocurrence";
  }

  {
    my @tokens = ($eq_token->(1, 0), $eq_token->(1, 0), $eq_token->(1, 0));
    is_deeply $parse->(\@tokens), ['=', '=', '='],
      "can parse many occurences";
  }
};

subtest '->many_of()', sub {
  plan tests => 3;

  my $parse = sub {
    my $parser = FauxCombinator::Parser::new(shift);
    $parser->many_of(sub { $parser->expect('eq')->{value} });
  };

  {
    my @tokens = ();
    eval { $parse->(\@tokens) };
    like $@, qr/expected eq, found eof/, "CANNOT parse zero occurence";
  }

  {
    my @tokens = ($eq_token->(1, 0));
    is_deeply $parse->(\@tokens), ['='],
      "can parse one ocurrence";
  }

  {
    my @tokens = ($eq_token->(1, 0), $eq_token->(1, 0), $eq_token->(1, 0));
    is_deeply $parse->(\@tokens), ['=', '=', '='],
      "can parse many occurences";
  }
};
