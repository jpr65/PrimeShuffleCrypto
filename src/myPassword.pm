# perl
#
# MyPassword.pm
#
# Read passwords from console / terminal
#
# Ralf Peine
#
# 25.11.2015

use strict;
use warnings;

$| = 1;

package MyPassword;

sub readPasswordUnsecure {
    my $password = <STDIN>;
    return $password;
}

my $readPasswordAction = sub { return readPasswordUnsecure(); };

my $termReadKeyLoaded = eval ("use Term::ReadKey; 1;");

if ($termReadKeyLoaded) {
    my $readPasswordActionStr = <<EnDe
        sub {
            ReadMode('noecho');
            return ReadLine(0);
        }
EnDe
;
    print $readPasswordAction;
    $readPasswordAction = eval($readPasswordActionStr);
}

sub Read {
    print shift;
    my $password = $readPasswordAction->();
    print "\n";
    chomp $password;
    return $password;
}

1;
