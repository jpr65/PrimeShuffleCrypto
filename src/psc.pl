# perl
#
# psc.pl
#
# shuffle bits or bytes using prime numbers
#
# Ralf Peine
#
# 25.11.2015

use strict;
use warnings;

$| = 1;

use MyPassword;
use PSC;

my @argv_backup = @ARGV;

sub help {
    return <<EnDe
# psc - PrimeShuffleCrypto

# Options
   -test           Testmode
-h -help           print this help
-c -crypt          crypt   file
-d -decrypt        decrypt file

# call

psc -h

psc -crypt   file file.crypted
psc -decrypt file file.decrypted

# --------------------------------------------------------
EnDe
}

sub do_die {
    print "# You called\n\n$0 ".join (" ", @argv_backup) . "\n\n";
    print shift ." STOP!\n\n";
    print help;

    exit 1;
}


my $action = shift || "";

if (   $action eq "-h"
    or $action eq "-help"
) {
    print help;
    exit 1;
}

my $test_mode = lc($action) eq '-test' ? 1 : 0;

$action = shift if $test_mode;

do_die "Not enough arguments given" if scalar (@ARGV) < 2;

my $inpFile = shift;
my $outFile = shift;

my $startTime = time();
my $actTime;

my $password = $test_mode ? 'abcdefghI123%' : '';

do_die "No input file given!" unless $inpFile;
do_die "No output file given!" unless $outFile;

do_die "can't find file to read in: $inpFile" unless -e $inpFile;

print "# Start ".localtime($startTime)."\n";

unless ($password) {
    $password = MyPassword::Read("Input password: ");
}

print "# start ...\n";

my $done = eval {
    PSC::run($action, $password, $inpFile, $outFile);
    1;
};

my $err = $@;
unless ($done) {
    $err = "Incomplete call of $0" unless $err;
    
    do_die $err if $err;
}

print "# Done.\n\n";
