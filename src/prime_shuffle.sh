#!/system/bin/sh

perl prime_shuffle.pl -test -crypt testData.txt testData.txt.psc
perl prime_shuffle.pl -test -decrypt testData.txt.psc testData.dec.txt

perl head.pl -chars 184 testData.dec.txt
