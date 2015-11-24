# perl
#
# prime_shuffle.pl
#
# shuffle bits or bytes using prime numbers
#
# Ralf Peine
#
# Wed Mar 22 12:26:47 2006

use strict;

$| = 1;

my $startTime = time();
print "Start ".localtime($startTime)."\n";

my $primeNbrFile = 'prime_nbrs.pl';
# load vector of prime numbers later
require $primeNbrFile;

my $actTime;

$actTime = time();
print "compiled\t". ($actTime - $startTime)."\n";


# returns index list
sub primeShuffle {
    my $sx = shift; # shuffle Max Index
    my $kr = shift; # key     Ref    
    my $pr = shift; # prime   Ref  

    my $ik; # index in key
    my $ia; # index add
    my $im; # index mul
    my $id; # index mod
    my $pa; # prime add
    my $pm; # prime mul
    my $pd; # prime mod

    my $pl = $#$pr + 1; # prime length
    my $kl = $#$kr - 1; # key length
    my $a;  # running number

    # init

    $ik = 0;
    $a  = ((($$kr[0] * 256 + $$kr[1]) * 256 + $$kr[2]) * 256 + $$kr[3]) % $sx;

    # print "a=$a\tpl=$pl\tkl=$kl\n";

    my $ax = 0;
    my $i  = 0;
    $ia = 4;
    $im = 5;
    $id = 6;

    my @ua;
    $ua[$sx+2] = "end";
    my $dd = 0;

    while ($i < $sx) {
	$ia = ($ia + $kr->[$ik+0])% $pl;
	$im = ($im + $kr->[$ik+1])% $pl;
	$id = ($id + $kr->[$ik+2])% $pl;
	$pa = $pr->[$ia];
	$pm = $pr->[$im];
	$pd = $pr->[$id];
        
	$a  = ((($a + $pa) * $pm) % $pd) % $sx;

	if (defined $ua[$a]) {
	    while ($ax <= $sx) {
		last unless defined ($ua[$ax]);
		$ax++;
	    }
	    last if ($ax > $sx); # fire exit
	    $a = $ax;
	}
	$ua[$a] = $i;
	$ik += 3;
	$ik = $ik % $kl;

	# print "." if $i % 1000 == 0;
	print "$i $a, " if $i % 100000 == 0  &&  $i > 0;

	$i++;
    }

    print "\nmax: $i ==============================\n";

    return \@ua;
}

#--- main ----------------------------------------------------------------------

my $resultFile = "results.txt";
my @data;
my @key;
my @primeNumbers = &primeNumbers();
# my $maxNumbers = 1000;
my $maxNumbers = 1000000;


foreach my $i (0..$maxNumbers) {
    $data[$i] = $i;
}

open (INP, $resultFile) || die "can't read result file $resultFile\n";

my $count = 0;
while (<INP>) {
    if (/^\s*\{\s*_maxNbr\s*=>/) {
	$count++;
    }
}

close INP;

while (1) {
    $count++;
    $startTime = time();
    foreach my $i (0..999) {
	$key[$i] = int(rand() * 256);
    }
    
    $actTime = time();
    print "$count inited\t". ($actTime - $startTime)."\n";
    
# my $shuffleArrRef = &primeShuffle($#primeNumbers+1, \@key, \@primeNumbers);
    
# my @newPrimeNumbers;
    
# $newPrimeNumbers[$#primeNumbers] = "";
    
# foreach my $i (0..$#primeNumbers) {
#     $newPrimeNumbers[$i] = $primeNumbers[$shuffleArrRef->[$i]];
#     print print "$i " unless $primeNumbers[$shuffleArrRef->[$i]];
# }
    
# print "primes\t". ($actTime - $startTime)."\n";

    my $arrRef = &primeShuffle($maxNumbers, \@key, \@primeNumbers);

    $actTime = time();
    print "$count calc\t". ($actTime - $startTime)."\n";
    
    open (OUTF, ">>$resultFile"); 
    
    my %diffs;
    foreach my $i (0..$maxNumbers-1) {
	warn "not defined: \$arrRef->[$i] \n" unless defined $arrRef->[$i];
	my $d = $i - $arrRef->[$i];
	$diffs{$d} = 0 unless $diffs{$d};
	$diffs{$d}++;
    }
    
    my %results;
    foreach my $k (keys (%diffs)) {
	$results{$diffs{$k}} = "0" unless $results{$diffs{$k}};
	$results{$diffs{$k}}++;
    }
    
    printf OUTF "{ _maxNbr => $maxNumbers, _count => %5d, ", $count;
    my $printOut = "maxDuplicates: ";
    foreach my $k (sort {$b <=> $a} (keys (%results))) {
	printf OUTF "%3d => %3d, ", $k, $results{$k};
	printf $printOut."%3d => %3d\n", $k, $results{$k} if $printOut;
	$printOut = "";
	# printf "%6d $results{$k}\n", $k;
    }
    print OUTF ("},\n");
    
    close OUTF;
    
    $actTime = time();
    print "$count ready\t". ($actTime - $startTime)."\n";
}
# }

# 12 sec for &primeShuffle()
# 220.600 KB