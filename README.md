# Subentry Promotion
This repo contains scripts to process SFM lexical records to promote subentries to full entry records. The promoted entry has a marker (\mn) pointing back to the entry it was under.

FLEx imports subentries only at the entry level.  In order to import a subentry under a sense, it needs to be recast as a variant (rather than as a complex form) in the SFM file, and then imported, and then changed from Variant to Complex Form in the .fwdata file after the import.

This repository contains several scripts needed for that process.  One of the scripts promotes embedded subentries to standalone entries (so they can retain all the fields that Complex Forms can have). Another script looks for these entries in the FLEx .fwdata file and changes them from Variant to Complex Form.  These scripts also include a mechanism to customize the complex form type.

A Windows WSL bash wrapper script runs the Perl script that processes the FLEx database. It extracts the *.fwdata* file from a *.fwbackup* file. It runs the script to make the changes to the FLEx database and updates the *.fwbackup* file with the changed *.fwdata* file. The wrapper script requires the Windows version of the *7-Zip* program be installed on the computer to do the extraction and update.

This repository was migrated from Wes Peacock's Nkonya dictionary Script directory in June 2019.
