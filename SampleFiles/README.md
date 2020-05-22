# Subentry Promotion Sample File
This directory contains a file for sample runs to illustrate the operation of the Subentry Promotion scripts.

There are two versions of the file, the complex and the simple. The complex version can
be easily converted to the simple by this one line perl script:
```
perl -pE 's/(^\\(se)*)l[^x]/$1se/' BearBullMole-complex.db > BearBullMole-simple.db
```

The complex sample file was imported from Wes Peacock's SampleSFM repository.
