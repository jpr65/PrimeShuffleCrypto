#!/system/bin/sh

perl psc.pl -test -crypt testData.txt testData.txt.psc
perl psc.pl -test -decrypt testData.txt.psc testData.dec.txt

perl head.pl -chars 180 testData.dec.txt
