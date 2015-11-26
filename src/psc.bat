perl psc.pl -crypt testData.txt testData.txt.psc
perl psc.pl -decrypt testData.txt.psc testData.dec.txt
perl head.pl 180 testData.dec.txt
pause
