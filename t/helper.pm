use Modern::Perl;
use Exporter 'import';
use vars qw(@EXPORT_OK);

@EXPORT_OK = qw(tok);

sub tok {
  my ($type, $value) = @_;
  return sub {
    my ($line, $col) = @_;
    {
      type => $type,
      value => $value,
      start => {line => $line, column => $col},
      end => {line => $line, column => $col + length($value)},
    }
  }
}
