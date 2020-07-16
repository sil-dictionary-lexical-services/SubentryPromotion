# Subentry Promotion Sample Files
This directory contains files for sample runs to illustrate the operation of the Subentry Promotion scripts.

### Sample SFM file

*BearBullMole-complex.db*, the sample SFM file is an initial file with homographs, multiple senses and sub-entries.

There are two versions of the file, the complex and the simple. The complex version can
be easily converted to the simple by this one line perl script:

```
perl -pE 's/(^\\(se)*)l[^xfv]/$1se/' BearBullMole-complex.db > BearBullMole-simple.db
```

### Sample FLEx Backup file

*BearBullMole-Initial-Empty.fwbackup* is an empty FLEx project with settings for illustrating the Subentry Promotion process.

The complex sample SFM file was imported from Wes Peacock's SampleSFM repository.
