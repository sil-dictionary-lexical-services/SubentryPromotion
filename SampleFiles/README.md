# Subentry Promotion Sample Files
This directory contains files for sample runs to illustrate the operation of the Subentry Promotion scripts.

### Sample SFM file

*BearBullMole-complex.db*, the sample SFM file is an initial file with homographs, multiple senses, subentries and sub-sub-entries of different types.

This is the complex form of the database.
It can be simplified in two ways.
The multiple types of subentries can be converted to a single type, and sub-subentries can be converted to subentries.
The first way (multiple to single subentry types) can be done by this one line perl script:
```
perl -pE 's/(^\\(se)*). /$1 /' BearBullMole-complex.db >BearBullMole-single.db
```
The second way (to flatten sub-subentries into subentries) can be done by this one line perl script:
```
perl -pE 's/^\\(se)+/\\se/' BearBullMole-complex.db >BearBullMole-flat.db
```
The scripts can be piped to do both:
```
perl -pE 's/^\\(se)+/\\se/' BearBullMole-complex.db | perl -pE 's/(^\\(se)*). /$1 /' >BearBullMole-simple.db
```

### Sample FLEx Backup file

*BearBullMole-Initial-Empty.fwbackup* is an empty FLEx project with settings for illustrating the Subentry Promotion process.

The complex sample SFM file was imported from Wes Peacock's SampleSFM repository.
