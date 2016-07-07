#!/system/bin/sh

perl psc.pl
perl psc.pl a
perl psc.pl a b
perl psc.pl -bla
perl psc.pl -bla a
perl psc.pl -bla a b
perl psc.pl -test -bla testData.txt b

perl psc.pl -h
perl psc.pl -help

perl psc.pl -test -c testData.txt testData.txt.psc
perl psc.pl -test -d testData.txt.psc testData.dec.txt

perl head.pl -chars 180 testData.dec.txt
