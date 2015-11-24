#
# How to use PrimeShuffle
#
# Ralf Peine
#
# 27.11.2006

What you need -----------------------------------------------------------------------------

 - prime_nbrs.pl  OR  prime_nbrs.pl.gz   file with prime numbers
 - prime_shuffle.pl                      file with the algorithm implementation
 - prime_shuffle_crypt.bat               encrypt file testData.txt -->  testData.txt.psc
 - prime_shuffle_decrypt.bat             decrypt file testData.txt.psc --> testData.dec.txt
 - prime_shuffle.bat                     first encrypt and then decrypt
 - testData.txt                          Test data to crypt

 or (without perl)

 - prime_shuffle.exe
 - prime_shuffle_exe_crypt.bat           encrypt file testData.txt -->  testData.txt.psc
 - prime_shuffle_exe_decrypt.bat         decrypt file testData.txt.psc --> testData.dec.txt
 - prime_shuffle_exe.bat                 first encrypt and then decrypt
 - testData.txt                          Test data to crypt

What you get ------------------------------------------------------------------------------

 - testData.txt.psc   (PrimeShuffleCrypted: crypted file)
 - testData.dec.txt   (decrypted file with random data following input text


What you can load -------------------------------------------------------------------------

 - prime_shuffle_continuous_run.pl    add some lines to a file like shuffle_vectors.txt
 - shuffle_vectors.7z                 content: shuffle_vectors.txt
