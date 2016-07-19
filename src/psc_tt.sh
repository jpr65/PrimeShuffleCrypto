#!/system/bin/sh

perl psc.pl -test -c testData.txt testData.txt.psc
perl psc.pl -test -d testData.txt.psc testData.dec.txt

perl head.pl -chars 180 testData.dec.txt
