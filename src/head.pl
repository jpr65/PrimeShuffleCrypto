# perl
#
# prime_shuffle.pl
#
# shuffle bits or bytes using prime numbers
#
# Ralf Peine
#
# 25.11.2015

use strict;
use warnings;

$| = 1;

my $file  = shift;
my $chars = 100; 

if (lc($file) eq '-chars') {
    $chars = shift;
    $file  = shift;
}

# ===============================================================================

open (INP, $file) or die "can't read $file: $!\n";

# binmode INP;

my $inp;

my $bytesRead = read (INP, $inp, $chars);

print "$inp\n";
