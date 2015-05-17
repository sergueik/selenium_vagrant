use Selenium::Remote::Driver;
use Data::Dumper;
my $driver = new Selenium::Remote::Driver;
$driver->get('http://www.google.com');
print $driver->get_title();
$driver->quit();

