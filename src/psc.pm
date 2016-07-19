# perl
#
# psc.pm
#
# shuffle bits or bytes using prime numbers
#
# Ralf Peine
#
# 18.07.2016

use strict;
use warnings;

$| = 1;

package PSC;

my $startTime = time();
my $actTime;

require 'prime_nbrs.pl';

#===============================================================================
#
# the shuffle algorithm implementation
#
# returns the bijective shuffle vector as an index list

sub primeShuffle {
    my $smx     = shift; # shuffle max index
    my $kr      = shift; # key     ref    
    my $pr      = shift; # prime   ref
    my $sr      = shift; # shuffle rounds
    my $initRef = shift;

    my $sx = $smx * 10; # shuffle max array index, 10 Mio
    $sx    = min($sx, 10000000);

    my $ik; # index in key
    my $ia; # index add
    my $im; # index mul
    my $id; # index mod
    my $pa; # prime add
    my $pm; # prime mul
    my $pd; # prime mod

    my $pl = $#$pr + 1; # prime length
    my $kl = $#$kr - 8; # key length
    my $a;  # running number
    my $ac; # last calced running number

    my $ip = 0;

    my @ret1; # result array 1 with vectors
    my @ret2; # result array 2 with vectors
    my @ua;   # vector with calced numbers
    $ua  [$sx+2] = "end"; # let array grow in one step
    $ret1[$sx+2] = "end"; # let array grow in one step
    $ret2[$sx+2] = "end"; # let array grow in one step

    # --- init first result vector ---
    foreach my $ti (0..$sx+1) {
	    $ret1[$ti] = $ti;
    }

    # --- use references to move arrays around ---
    my $retRef1 = \@ret1;
    my $retRef2 = \@ret2;

    # --- init --------------------

    unless ($initRef  &&  defined $initRef->{'a'}) {
	    $a  = (((((($kr->[0] << 8) + $kr->[1]) << 8) + $kr->[2]) << 8) + $kr->[3]) % $sx;

        # print "a=$a\tpl=$pl\tkl=$kl\n";

	    $ia = 0;
	    $im = 0;
	    $id = 0;
	    $initRef = {} unless $initRef;
	    $ik = 4;
    } else {
	    $a  = $initRef->{'a'};
	    $ia = $initRef->{'ia'};
	    $im = $initRef->{'im'};
	    $id = $initRef->{'id'};
	    $ik = 0;
    }
    # print "$initRef\n";

    my $r;          # actual round counter
    my $sinv = "1"; # search direction switch
    foreach $r (1..$sr) {

	    # --- calc shuffle vectors --------------------------------------------------------

	    # --- start anywhere with duplicate exchange ---
	    my $axs = (((($kr->[$ik+0] << 8) + $kr->[$ik+1]) << 8) + $kr->[$ik+2]) % $sx;
	    # print "\$xas = $axs\n\n";
	    my $axb = $axs;
	    my $axt = $axs;
	    my $i   = 0;

	    $ik += 3;

	    while ($i < $smx) {

	        # --- get next index values for prime number array -----------------------------
	        $ia = ($ia + ((($kr->[$ik+0] << 8) + $kr->[$ik+1]) << 8) + $kr->[$ik+2]) % $pl;
	        $im = ($im + ((($kr->[$ik+3] << 8) + $kr->[$ik+4]) << 8) + $kr->[$ik+5]) % $pl;
	        $id = ($id + ((($kr->[$ik+6] << 8) + $kr->[$ik+7]) << 8) + $kr->[$ik+8]) % $pl;
	    
	        # --- get prime numbers --------------------------------------------------------
	        $pa = $pr->[$ia];
	        $pm = $pr->[$im];
	        $pd = $pr->[$id];

	        # --- get next iterator number -------------------------------------------------
	        $ac = $a = ((($a + $pa) * $pm) % $pd) % $sx;

	        # --- if already used, search next unused value up or down ---------------------
            # --- starting at the middle ---------------------------------------------------
	        if (defined $ua[$a]) {
		        if ($sinv > 0) { # search from bottom
		            while (defined ($ua[$axb])) {
			            while ($axb < $sx) {
			                last unless defined ($ua[$axb]);
			                $axb++;
			            }
		            }
		            # print "\n$i: $a -> $axb ";
		            $a = $axb;
		        } else { # search from top
		            while (defined ($ua[$axt])) {
			            while ($axt >= 0) {
			                last unless defined ($ua[$axt]);
			                $axt--;
			            }
		            }
		            # print "\n$i: $a -> $axt ";
		            $a = $axt;
		        }
		        $sinv = -$sinv;
	        # } else {
		    # print "$i -> $a\n";
	        }

	        # --- store a value ---
	        $ua[$a] = $i;

	        # --- prepare to get next indexes ---
	        $ik += 9;
	        $ik = $ik % $kl if $ik >= $kl;

	        # --- show that something is working ---
	        if ($ip & 65536) {
		        print ".";
		        $ip = "0";
	        }

	        $ip++;
	        $i++;
	    }

        # print "\nround $r, max: $i ==============================\n";

        shrink_ua(\@ua, $smx, $sx);

	    # --- build the new translation vector -------------------------------------------------------

	    foreach my $ti (0..$smx-1) {
	        # print " \$retRef2->[$ti] := \$ua[$retRef1->[$ti]] = " 
            #     --> if $retRef1->[$ti] > 7900  &&  $retRef1->[$ti] < 8000;
	        
            $retRef2->[$ti] = $ua[$retRef1->[$ti]];
	        $ua[$retRef1->[$ti]] = undef;
	        
            # print "$retRef2->[$ti]\t\t v ".($ti - $retRef2->[$ti])."\n"
            #     --> if $retRef1->[$ti] > 7900  &&  $retRef1->[$ti] < 8000;
	    }

	    # --- exchange vectors ------------------------------------------------------------------------

	    my $href = $retRef2;
	    $retRef2 = $retRef1;
	    $retRef1 = $href;

	    # print "\n\$a  = $a\n\$ac = $ac\n\$ia=$ia\n\$im=$im\n\$id=$id\n";

	    $a = $ac; # use last calced value
    }

    # print join (" ", @$retRef1, "\n");
    # exit 1;

    # return \@ua;

    $initRef->{'a'}  = $a ;
    $initRef->{'ia'} = $ia;
    $initRef->{'im'} = $im;
    $initRef->{'id'} = $id;

    return $retRef1;
}

sub shrink_ua {
    my $ua  = shift; # ref of array to shrink
    my $smx = shift; # shuffle Max Index
    my $sx  = shift; # shuffle Max Array Index, 10 Mio

	# --- shrink @ua to used fields only, max index afterwards has to be $smx ------

	my $ui = -1; # search index
	my $ii =  0; # write index
	
	while ($ii < $smx) {
	    # search next not used array index
	    while (defined $ua->[$ii]) {
	        $ii++;
	    }
	    # search index $ui has to be greater than write index $ii
	    if ($ui < $ii) {
	        $ui = $ii;
	    }
	    # search next used field of @ua
	    while (!defined $ua->[$ui]) {
	        $ui++;
	    }
	    # fire exit: max reached for $ui, just to be sure
	    last if ($ui >= $sx);

        # move value to smallest unused
        if ($ui > $ii) {
            $ua->[$ii] = $ua->[$ui];
            $ua->[$ui] = undef;
        }

        $ii++;
        $ui++;
    }
}

#===============================================================================
#
# invert the shuffle vector to be used by decryption
#
# returns index list

sub invertShuffle {
    my $inpArrRef = shift;
    my $inpArrLen = shift;
     
    my @invArr;
    $invArr[$inpArrLen] = "end";
     
    foreach my $i (0..$inpArrLen-1) {
	    $invArr[$$inpArrRef[$i]] = $i;
    }
     
    return \@invArr;
}

#===============================================================================
#
# shuffle the bits of the given $origVecRef using $shuffleVecRef
# 
# the length of the vecs is needed because not the whole vector must be used
#
sub shuffleBits {
    my $origVecRef = shift;
    my $origVecLen = shift;    # array could be longer
    my $shuffleVecRef = shift;
    my $shuffleVecLen = shift; # array could be longer
    
    my $bitVecLen = $origVecLen * 8;
    ($shuffleVecLen <= $bitVecLen)  or  die "shuffle vector length $shuffleVecLen fits not to bit vector length $bitVecLen !!";
    
    my @bitVal = (1,2,4,8,16,32,64,128);   
    my @resultVec;
    $resultVec[$origVecLen] = "end";
    my $si; # shuffle iter
    my $oci; # orig char for iter
    my $obi; # orig bit for iter
    my $mi;  # moveto index
    my $mci; # moveto char for iter
    my $mbi; # moveto bit for iter
    my $bit;
    
    foreach $si (0..$shuffleVecLen-1) {
	    $oci = int($si / 8);
	    $obi = $bitVal[$si % 8];
	    $mi = $shuffleVecRef->[$si];
	    $mci = int($mi / 8);
	    $mbi = $bitVal[$mi % 8];
	
	    $bit = (ord($origVecRef->[$oci]) & $obi) ? 1 : 0;
	    $resultVec[$mci] = chr(0) unless defined $resultVec[$mci];
	    $resultVec[$mci] = chr(ord ($resultVec[$mci]) | ($bit ? $mbi: 0));

	    print "." unless ($si+1) % 100000;
    }
    return \@resultVec;
}

#===============================================================================
#
# compare 2 arrayRefs (up to len2cmp) and print out the diffs
#
sub cmpArrRefs
{
    my $arrRef1 = shift;
    my $arrRef2 = shift;
    my $len2cmp = shift;
    
    foreach my $i (0..$len2cmp-1) {
	    print "diff $i: $$arrRef1[$i] != $$arrRef2[$i]\n" if $$arrRef1[$i] != $$arrRef2[$i];
    }
}

#===============================================================================
#
# generate a random key to use as shuffle init
#
# if there is no random key as part of the key, you can identify some changed
# bits in the data
#
sub genRandomKey {
    my $keyLength = shift;

    my @key;
    foreach my $i (0..$keyLength-1) {
	    $key[$i] = int(rand() * 256);
	    # $key[$i] = chr($i % 256);
    }

    return @key;
}


#===============================================================================
#
# combine two or more keys by xor to one
#
#
sub combineKeys {
    my $keyRef     = shift;
    my $addKeyRef;

    my @arr = @$keyRef;

    while ($addKeyRef = shift) {
	    foreach my $i (0..$#arr) {
	        $arr[$i] ^= $addKeyRef->[$i];
	    }
    }

    return \@arr;
}


#===============================================================================
#
# combine key and password string
#
#
sub combineKeyWithPassword {
    my $keyRef     = shift;
    my $passWord   = shift;

    while (length($passWord) < $#$keyRef) {
	    $passWord .= $passWord;
    }

    my @arr = split (//, $passWord);

    foreach my $i (0..$#arr) {
	    $arr[$i] = ord($arr[$i]);
    }

    return &combineKeys($keyRef, \@arr);
}


#===============================================================================
#
# iterate key x times
#
# this is needed to prevent the key beiing searched byte by byte
#
# iterating 10 times is enough to get a result, that is complete different
# from the crypted string, if only one bit in the key changes. So you get
# the crypted string back only if the key is exact correct. (Thats the main
# condition for a good cryption algorithm!)
#
sub shuffleKey {
    my $keyIterNbr     = shift; # how many rounds to shuffle the key
    my $calcKeyRef     = shift; # \@arr
    my $keyLength      = shift;
    my $primeNumberRef = shift; # \@primeNumbers
    my $initRef        = shift;

    my $shuffleKeyArrRef;
    my $shuffleKeyArrLen = $keyLength*8;
    # my $invertShuffleKeyArrRef;
    
    print "# shuffle keys   ";
    
    foreach my $ki (1..$keyIterNbr) {
	    $shuffleKeyArrRef = &primeShuffle($shuffleKeyArrLen, $calcKeyRef, $primeNumberRef, 4, $initRef);
	    # print "$shuffleKeyArrRef  \$#\$calcKeyRef = $#$calcKeyRef\n";
	    # $invertShuffleKeyArrRef = &invertShuffle($shuffleKeyArrRef, $shuffleKeyArrLen);
	
	    foreach my $i (0..$keyLength-1) {
	        $$calcKeyRef[$i] = chr($$calcKeyRef[$i]);
	    }
	
	    $calcKeyRef = &shuffleBits($calcKeyRef, $keyLength, $shuffleKeyArrRef, $shuffleKeyArrLen);
	    # my $oldKeyRef = &shuffleBits($calcKeyRef, $keyLength, $invertShuffleKeyArrRef, $shuffleKeyArrLen);
	
	    foreach my $i (0..$keyLength-1) {
	        $$calcKeyRef[$i] = ord($$calcKeyRef[$i]);
	        # $$oldKeyRef[$i] = ord($$oldKeyRef[$i]);
	    }
	    # &cmpArrRefs(\@key, $oldKeyRef, $keyLength) if $ki == 1;
	    # print join (' ', '#', @$oldKeyRef[60..80], "\n\n");
	    # print join (' ', '#', @$calcKeyRef[60..80], "\n");
	    print ".";
    }

    # print join ("\n", @$shuffleKeyArrRef[0..100], "\n");

    return $calcKeyRef;
}

#===============================================================================
#
# minimum of two values
#
# I don't want to use any other modules
#
sub min {
    return ($_[0] < $_[1]) ? $_[0]: $_[1]; 
}


#=== run ... ======================================================================

sub run {

    my $action   = shift;
    my $passWord = shift;

    my $inpFile  = shift;
    my $outFile  = shift;

    my $maxNumbers = shift || 1000000;

    my %initHash;

    my @primeNumbers = &primeNumbers();

    # foreach my $loop (0..100) {

    my $crypt = 'true';

    my @data;
    my @key;
    my $keyLength = 1000;
    my $keyIterNbr = 10;
    my $shuffleRounds = 1;

    my $printCharNbrs = 50;

# --- open files ----------------------------------------------------------

    open (INP,  $inpFile) or die "can't read $inpFile: $!\n";
    open (OUTP, ">$outFile") or die "can't write $outFile: $!\n";

    binmode INP;
    binmode OUTP;

    if (   $action eq "-crypt"
        or $action eq "-c"
    ) {
        print "# crypt\n";
        @key = &genRandomKey($keyLength);

    } 
    elsif (   $action eq "-decrypt"
           or $action eq "-d"
    ) {
        print "# decrypt\n";
        $crypt = '';

        # --- read in key ---
        my $cryptData;
        my $cread = read (INP, $cryptData, $keyLength);
        print "# key chars read $cread == $keyLength\n";
        foreach my $k (split (//, $cryptData)) {
	        push (@key, ord($k));
        }
        # skip separator ||| between key and data,
        # will be removed later in product version
        my $dummy = "";
        $cread = read (INP, $dummy, 3);
    }
    else {
        die "unknown action '$action'";
    }

    # --- add password to key -------------------------------------

    my $keyRef = &combineKeyWithPassword(\@key, $passWord);
    # print join (' ', @$keyRef[0..30], "\n");

    # my $keyRef = \@key;


    #
    #
    # --- !!! missing !!! --- add other keys to key ---------------
    #
    #


    # --- shuffle key ----------------------------------------------------------

    $actTime = time();
    print "# ready to run\t". ($actTime - $startTime)."\n";

    my $calcKeyRef = &shuffleKey($keyIterNbr, $keyRef, $keyLength,  \@primeNumbers, \%initHash);

    # print "\n";
    # foreach my $k (sort(keys(%initHash))) {
    #     print "$k -> $initHash{$k}\n";
    # }
    # print "\n";

    # --- create shuffle vector ------------------------------------------------

    $actTime = time();
    print " key ready\t". ($actTime - $startTime)."\n# shuffle vector ";

    my $shuffleArrRef;
    if ($crypt){
        $shuffleArrRef = &primeShuffle($maxNumbers, $calcKeyRef, \@primeNumbers, $shuffleRounds,
                                      \%initHash);
    }
    else {
        $shuffleArrRef = &primeShuffle($maxNumbers, $calcKeyRef, \@primeNumbers, $shuffleRounds,
                                      \%initHash);
    }

    # print "\n";
    # foreach my $k (sort(keys(%initHash))) {
    #     print "$k -> $initHash{$k}\n";
    # }
    # print "\n";

    # --- read in data from file -----------------------------------------------

    $actTime = time();
    print " ready\t". ($actTime - $startTime)."\n# shuffle data   ";

    # my $inp = "Das sind meine unverschlüsselten Testdaten!!";
    # my $inp = "These are my uncrypted test data, so it is!!";

    my $inp;

    my $bytesRead = read (INP, $inp, 125000);

    my @inpArr = split (//, $inp);

    my $inpArrLength = $maxNumbers / 8 + 10;
    my $inpStart = $#inpArr+1;

    # --- fill input data with random values up to min length ------------------

    foreach my $i (0..7) {
        $inpArr[$inpArrLength+$i] = '';
    }
    $inpArr[$inpArrLength] = 'end';
    foreach my $i ($inpStart..$inpArrLength) {
        $inpArr[$i] = chr(int(16 + rand() * 200.0));
    }

    # --- now crypt or decrypt data --------------------------------------------

    unless ($crypt) {
        $shuffleArrRef =  &invertShuffle($shuffleArrRef, $maxNumbers);
    }

    my $resultArrRef = &shuffleBits(\@inpArr, $inpArrLength, $shuffleArrRef, $maxNumbers);

    if ($crypt) {
        foreach my $k (@key[0..$keyLength-1]) {
	        print OUTP join ("", chr($k));
        }
        print OUTP "|||";
    }

    my $outputLength = $inpArrLength-1;
    while (! defined $$resultArrRef[$outputLength]) {
        $outputLength--;
        last if $outputLength < 0; # fire exit
    }

    print OUTP join ("", @$resultArrRef[0..$outputLength]);

    close OUTP;

    $actTime = time();
    print " ready\t". ($actTime - $startTime)."\n";

    #$startTime = time();

    #print "\n#--------------------------------------------------------------------------------\n\n";
    #}

}

1;

