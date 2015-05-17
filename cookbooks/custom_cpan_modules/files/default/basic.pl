use Selenium::Remote::Driver;
use Data::Dumper;
use Carp::Assert;
our $DEBUG = 1;
my $driver = new Selenium::Remote::Driver;
$driver->get('http://www.google.com');
assert($driver->get_title() =~ /google/i ) if $DEBUG;
print $driver->get_title();
$driver->quit();

