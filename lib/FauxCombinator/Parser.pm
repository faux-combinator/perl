package FauxCombinator::Parser;
use Modern::Perl;

sub new {
  my $tokens = shift;
  my $last = $tokens->[-1];
  if ($last) {
    push @$tokens, {type => 'eof'};
  } else {
    my $eof_pos = $last->{end};
    push @$tokens, {type => 'eof', start => $eof_pos, end => $eof_pos};
  }
  bless {tokens => $tokens};
}

sub peek {
  my ($self) = @_;
  @{$self->{tokens}}[0];
}

sub _token_loc {
  my ($token) = @_;
  if ($token && $token->{start} && $token->{end}) {
    " at $token->{start}{line}:$token->{start}{column} - $token->{end}{line}:$token->{end}{column}";
  } else {
    "";
  }
}

sub expect {
  my ($self, $type) = @_;
  my $token = shift @{$self->{tokens}};
  if ($token->{type} ne $type) {
    die "expected $type, found $token->{type}" . _token_loc($token);
  }
  $token;
}

# this method just serves as a shorthand to look better
sub match {
  my ($self, $match) = @_;
  $match->($self);
}
 

sub try {
  my ($self, $match) = @_;
  my @tokens = @{ $self->{tokens} };

  local $@;
  my $value = eval { $self->match($match); };
  if (!$@) {
    return $value;
  }
  $self->{tokens} = \@tokens;
  ()
}

sub one_of {
  my $self = shift;
  while ($_ = shift) {
    if (my $value = $self->try($_)) {
      return $value;
    }
  }

  die "unable to parse one_of" . _token_loc($self->peek);
}

sub any_of {
  my ($self, $match) = @_;
  my @parts;

  while ($_ = $self->try($match)) {
    push @parts, $_;
  }
  \@parts;
}

sub many_of {
  my ($self, $match) = @_;

  # force the first one not to be `try`d
  [$self->match($match), @{ $self->any_of($match) }];
}

1;
