use Modern::Perl;
use lib 'lib/'; # <- bad!
use Test::More;
BEGIN { plan tests => 5 }

use FauxCombinator::Parser;

my $lparen_token = {type => 'lparen', value => '('};
my $rparen_token = {type => 'rparen', value => ')'};
my $eq_token = {type => 'eq', value => '='};
my $dash_token = {type => 'dash', value => '-'};
my $under_token = {type => 'under', value => '_'};

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
    my @tokens = ($lparen_token, $rparen_token);
    is $parse->(\@tokens), 'rparen',
      "it parses";
  }

  {
    my @tokens = ($eq_token);
    eval { $parse->(\@tokens) };
    ok $@, "it checks arguments";
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
    my @tokens = ($lparen_token, $rparen_token);
    ok $parse->(\@tokens),
      "maybe tokens are optional";
  }

  {
    my @tokens = ($lparen_token, $eq_token, $rparen_token);
    ok $parse->(\@tokens),
      "it matches optional tokens";
  }

  {
    my @tokens = ($lparen_token, $dash_token, $rparen_token);
    eval { $parse->(\@tokens) };
    ok $@,
      "optional tokens are checked";
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
    my @tokens = ($eq_token);
    is $parse->(\@tokens), 'eq',
      "one_of can match first case";
  }

  {
    my @tokens = ($dash_token);
    is $parse->(\@tokens), 'dash',
      "one_of can match second case";
  }

  {
    my @tokens = ($under_token);
    is $parse->(\@tokens), 'under',
      "one_of can match third case";
  }

  {
    my @tokens = ();
    eval { $parse->(\@tokens) };
    ok $@, "one_of still requires a token";
  }

  {
    my @tokens = ($lparen_token);
    eval { $parse->(\@tokens) };
    ok $@, "one_of doesn't allow any token";
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
    my @tokens = ($eq_token);
    is_deeply $parse->(\@tokens), ['='],
      "can parse one ocurrence";
  }

  {
    my @tokens = ($eq_token, $eq_token, $eq_token);
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
    ok $@, "CANNOT parse zero occurence";
  }

  {
    my @tokens = ($eq_token);
    is_deeply $parse->(\@tokens), ['='],
      "can parse one ocurrence";
  }

  {
    my @tokens = ($eq_token, $eq_token, $eq_token);
    is_deeply $parse->(\@tokens), ['=', '=', '='],
      "can parse many occurences";
  }
};

